
// The enrie game simulation pretty much runs in a simple struct
// The initial reason for that was performance, so I could run lots of games very quickly or simultaneously for faster machine learning pgrogress.
// So this really just handles the game logic and nothing else.

// Balancing parameters:
#macro game_duration 1800
#macro game_radius_start 500
#macro start_pos_offset 200
#macro player_radius 40
#macro player_acceleration 0.2
#macro collision_solve_interval 0.1
#macro barrier_duration 120
#macro barrier_width 5

// Quick visualization colors:
#macro player1_color c_aqua
#macro player2_color c_lime
#macro bounds_color c_white
#macro direction_color c_black

// Game states:
#macro game_state_ongoing -1
#macro game_state_tie 0
#macro game_state_p1_wins 1
#macro game_state_p2_wins 2

// This is the game struct that handles all of the game logic:
function broink_game() constructor
{
    time_left = game_duration
	game_radius = game_radius_start
	player1 = new broink_player(-start_pos_offset, 0)
	player2 = new broink_player(start_pos_offset, 0)
	game_state = game_state_ongoing
	player_radius_doubled = player_radius*2
	barrier_left = barrier_duration
	player1_outside_of_circle = false
	player2_outside_of_circle = false
	players_collided = false
	players_collided_volocity = 0
	time = game_duration + barrier_duration
	
	// Reset the game (better for garbage collection than creating a new one):
	static Reset = function()
	{
		time_left = game_duration
		game_radius = game_radius_start
		player1.xpos = -start_pos_offset
		player1.ypos = 0
		player2.xpos = start_pos_offset
		player2.ypos = 0
		player1.xspeed = 0
		player1.yspeed = 0
		player2.xspeed = 0
		player2.yspeed = 0
		game_state = game_state_ongoing
		player_radius_doubled = player_radius*2
		barrier_left = barrier_duration
		player1_outside_of_circle = false
		player2_outside_of_circle = false
		players_collided = false
		players_collided_volocity = 0
		time = game_duration + barrier_duration
	}

	// Call this 60 times per second to simulate the game:
    static Step = function()
    {
		// Handle player movement
		time--
		player1.Move()
		player2.Move()
		
		// Barrier handling (bouncing off of barrier):
		if barrier_left > 0
		{
			if (player1.xpos > -player_radius-barrier_width)
			{
				player1.xpos = -player_radius-barrier_width
				player1.xspeed = -abs(player1.xspeed)
			}
			if (player2.xpos < player_radius+barrier_width)
			{
				player2.xpos = player_radius+barrier_width
				player2.xspeed = abs(player2.xspeed)
			}
		}
		
		// Check who is in the Circle:
		game_radius_plus_player_radius = game_radius + player_radius
		player1_outside_of_circle = (point_distance(0, 0, player1.xpos, player1.ypos) > game_radius_plus_player_radius)
		player2_outside_of_circle = (point_distance(0, 0, player2.xpos, player2.ypos) > game_radius_plus_player_radius)
		
		players_collided = false
		if (game_state == game_state_ongoing)
		{
			// Collision handling, check if players collided
			// I wrote my own collision handling system here instead of using GameMaker's built in one, once again for performance reasons, as I only have two objects per game:
			if point_distance(player1.xpos, player1.ypos, player2.xpos, player2.ypos) < player_radius_doubled
			{
				players_collided = true
				
				// Resolve collision:
				while point_distance(player1.xpos, player1.ypos, player2.xpos, player2.ypos) < player_radius_doubled
				{
					player1.xpos -= player1.xspeed * collision_solve_interval
					player1.ypos -= player1.yspeed * collision_solve_interval
					player2.xpos -= player2.xspeed * collision_solve_interval
					player2.ypos -= player2.yspeed * collision_solve_interval
				}
				
				// Transfer momentum:
				impact_direction = point_direction(player1.xpos, player1.ypos, player2.xpos, player2.ypos)
				impact_normal_x = lengthdir_x(1, impact_direction)
				impact_normal_y = lengthdir_y(1, impact_direction)
			
				p1_direction = point_direction(0, 0, player1.xspeed, player1.yspeed)
				p1_energy = point_distance(0, 0, player1.xspeed, player1.yspeed)
				p1_xspeed_normalized = lengthdir_x(1, p1_direction)
				p1_yspeed_normalized = lengthdir_y(1, p1_direction)
			
				p2_direction = point_direction(0, 0, player2.xspeed, player2.yspeed)
				p2_energy = point_distance(0, 0, player2.xspeed, player2.yspeed)
				p2_xspeed_normalized = lengthdir_x(1, p2_direction)
				p2_yspeed_normalized = lengthdir_y(1, p2_direction)
			
				p1_energy_transfer = dot_product(p1_xspeed_normalized, p1_yspeed_normalized, impact_normal_x, impact_normal_y) * p1_energy
				player2.xspeed += lengthdir_x(p1_energy_transfer, impact_direction)
				player2.yspeed += lengthdir_y(p1_energy_transfer, impact_direction)
				player1.xspeed -= lengthdir_x(p1_energy_transfer, impact_direction)
				player1.yspeed -= lengthdir_y(p1_energy_transfer, impact_direction)
			
				p2_energy_transfer = dot_product(p2_xspeed_normalized, p2_yspeed_normalized, -impact_normal_x, -impact_normal_y) * p2_energy
				player2.xspeed += lengthdir_x(p2_energy_transfer+0.1, impact_direction)
				player2.yspeed += lengthdir_y(p2_energy_transfer+0.1, impact_direction)
				player1.xspeed -= lengthdir_x(p2_energy_transfer+0.1, impact_direction)
				player1.yspeed -= lengthdir_y(p2_energy_transfer+0.1, impact_direction)
				
				players_collided_volocity = p1_energy_transfer + p2_energy_transfer
			}
			
			// Time passes
			barrier_left--
			if barrier_left < 0
				time_left--
			game_radius = game_radius_start * (time_left / game_duration)
			
			// Determine victory or lose states
			if (player1_outside_of_circle and player2_outside_of_circle)
				game_state = game_state_tie
			else if (player1_outside_of_circle)
				game_state = game_state_p2_wins
			else if (player2_outside_of_circle)
				game_state = game_state_p1_wins
		}
		return game_state
    }
	
	// This is more or less a quick and dirty debug draw function that is intentionally cheap on performance:
	static Draw = function(_xcenter = 960, _ycenter = 540, _scale = 1)
	{
		xp = _xcenter + player1.xpos * _scale
		yp = _ycenter + player1.ypos * _scale
		draw_circle_color(xp, yp, player_radius * _scale, player1_color, player1_color, false)
		xp += player_radius * player1.xinput * _scale
		yp += player_radius * player1.yinput * _scale
		draw_circle_color(xp, yp, player_radius * _scale * 0.2, direction_color, direction_color, false)
		
		xp = _xcenter + player2.xpos * _scale
		yp = _ycenter + player2.ypos * _scale
		draw_circle_color(xp, yp, player_radius * _scale, player2_color, player2_color, false)
		xp += player_radius * player2.xinput * _scale
		yp += player_radius * player2.yinput * _scale
		draw_circle_color(xp, yp, player_radius * _scale * 0.2, direction_color, direction_color, false)
		
		draw_circle_color(_xcenter, _ycenter, game_radius * _scale, bounds_color, bounds_color, true)
		draw_set_halign(fa_middle)
		draw_set_valign(fa_center)
		draw_set_font(font_main)
		switch game_state
		{
			case game_state_p1_wins:
				draw_text_transformed_color(_xcenter, _ycenter, "Player 1 Wins", _scale, _scale, 0, player1_color, player1_color, player1_color, player1_color, 1)
				break;
			case game_state_p2_wins:
				draw_text_transformed_color(_xcenter, _ycenter, "Player 2 Wins", _scale, _scale , 0, player2_color, player2_color, player2_color, player2_color, 1)
				break;
			case game_state_tie:
				draw_text_transformed_color(_xcenter, _ycenter, "Tie", _scale, _scale, 0, bounds_color, bounds_color, bounds_color, bounds_color, 1)
				break;
		}
		
		if barrier_left > 0
		{
			draw_rectangle_color(_xcenter - 3 * _scale, _ycenter-game_radius*_scale, _xcenter + 3 * _scale, _ycenter+game_radius*_scale, bounds_color, bounds_color, bounds_color, bounds_color, false)
		}
	}
}

// Every broink game struct also ocntains two broink player structs. These handle player input and movement:
function broink_player(_startx, _starty) constructor
{
    xpos = _startx
	ypos = _starty
	xspeed = 0
	yspeed = 0
	xinput = 0
	yinput = 0
	totalinput = 0
	
	static Move = function()
	{
		totalinput = max(1, point_distance(0, 0, xinput, yinput))
		xinput = xinput / totalinput
		yinput = yinput / totalinput
		xspeed += xinput * player_acceleration
		yspeed += yinput * player_acceleration
		xpos += xspeed
		ypos += yspeed
	}
}