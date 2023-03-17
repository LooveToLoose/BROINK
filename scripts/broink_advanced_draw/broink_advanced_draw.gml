
// If you want a pretty version of Broink, you can use this HD visualizer, which also produces sound.
// Note that you can only have one of these at a time as everything is stored in public variables:
function broink_hdvisualizer_ini()
{
	audio_stop_all()
	global.p1Size = 1
	global.p2Size = 1
	global.slowMoSpeed = 0
	global.barrierfizzle = 0
	global.barrierwidth = 1
	global.collisionFx = ds_list_create()
	global.mapvibrate = 0
	global.time = 0
	global.title_delay = 30
	global.title_size = 0.7
	audio_listener_set_position(0, 0, 0, 400)
	audio_listener_orientation(0, -1, 0, 0, 0, -1)
	global.audioemitball1 = audio_emitter_create()
	global.rollsound1 = audio_play_sound_on(global.audioemitball1, sou_rolling2, true, 1, 0)
	global.audioemitball2 = audio_emitter_create()
	global.rollsound2 = audio_play_sound_on(global.audioemitball2, sou_rolling5, true, 1, 0)
	audio_play_sound(sou_badum, 1, false, 0.3, 0, 0.95+random(0.2))
}

// Call this every frame to draw a pretty version of a broink game (and manage sound as well):
function broink_hdvisualizer_draw(_game)
{
	if _game.time_left == game_duration -1
		audio_play_sound(choose(sou_drum1, sou_drum2), 1, false, 0.3, 0, 1.35+random(0.2))
	global.time++
	
	// Player size:
	playersize = player_radius / 106
	
	// Roll sounds
	audio_emitter_position(global.audioemitball1, _game.player1.xpos, _game.player1.ypos, 0)
	vel = point_distance(0, 0, _game.player1.xspeed, _game.player1.yspeed) / 125
	audio_sound_pitch(global.rollsound1, (0.9+vel/2.5) * (1-global.slowMoSpeed*0.8))
	if (_game.player1_outside_of_circle || (global.p1Size < 1))
		audio_sound_gain(global.rollsound1, 0, 1/60)
	else
		audio_sound_gain(global.rollsound1, vel, 1/60)
	
	audio_emitter_position(global.audioemitball2, _game.player2.xpos, _game.player2.ypos, 0)
	vel = point_distance(0, 0, _game.player2.xspeed, _game.player2.yspeed) / 125
	audio_sound_pitch(global.rollsound2, (0.9+vel/2.5) * (1-global.slowMoSpeed*0.8))
	if (_game.player2_outside_of_circle || (global.p2Size < 1))
		audio_sound_gain(global.rollsound2, 0, 1/60)
	else
		audio_sound_gain(global.rollsound2, vel, 1/60)
	
	// Make player fall:
	if (_game.player1_outside_of_circle || (global.p1Size < 1))
	{
		if global.p1Size == 1
		{
			global.slowMoSpeed = 1
			global.mapvibrate = 1
			pdir = point_direction(0, 0, _game.player1.xpos, _game.player1.ypos)
			f = {
				xpos : lengthdir_x(_game.game_radius, pdir),
				ypos : lengthdir_y(_game.game_radius, pdir),
				size : 0.7,
				rot : random(360),
				time : 300,
				alph : 1,
				size_multi : 0.97,
			}
			hitsound = choose(sou_balldrop1, sou_balldrop2)
			pitch = 0.8 + random(0.2)
			audio_play_sound_at(hitsound, f.xpos, f.ypos, 0, 1700, 7000, 1, false, 0.9, 0.8, 0, pitch)
			ds_list_add(global.collisionFx, f)
		}
		global.p1Size *= 0.99
	}
	if (_game.player2_outside_of_circle || (global.p2Size < 1))
	{
		if global.p2Size == 1
		{
			global.slowMoSpeed = 1
			global.mapvibrate = 1
			pdir = point_direction(0, 0, _game.player2.xpos, _game.player2.ypos)
			f = {
				xpos : lengthdir_x(_game.game_radius, pdir),
				ypos : lengthdir_y(_game.game_radius, pdir),
				size : 0.7,
				rot : random(360),
				time : 300,
				alph : 1,
				size_multi : 0.97,
			}
			hitsound = choose(sou_balldrop1, sou_balldrop2)
			pitch = 0.8 + random(0.2)
			audio_play_sound_at(hitsound, f.xpos, f.ypos, 0, 1700, 7000, 1, false, 0.9, 0.8, 0, pitch)
			ds_list_add(global.collisionFx, f)
		}
		global.p2Size *= 0.99
	}
		
	// Slow-mo effect:
	if _game.game_state != game_state_ongoing
	{
		global.slowMoSpeed *= 0.99
		_game.player1.xpos -= _game.player1.xspeed * global.slowMoSpeed
		_game.player1.ypos -= _game.player1.yspeed * global.slowMoSpeed
		_game.player2.xpos -= _game.player2.xspeed * global.slowMoSpeed
		_game.player2.ypos -= _game.player2.yspeed * global.slowMoSpeed
		_game.player1.xspeed -= _game.player1.xinput * global.slowMoSpeed * player_acceleration
		_game.player1.yspeed -= _game.player1.yinput * global.slowMoSpeed * player_acceleration
		_game.player2.xspeed -= _game.player2.xinput * global.slowMoSpeed * player_acceleration
		_game.player2.yspeed -= _game.player2.yinput * global.slowMoSpeed * player_acceleration
	}
	
	// Players WHEN FALLING
	if global.p1Size < 1
		draw_sprite_ext(spr_ballBlack, 0, 960+_game.player1.xpos, 540+_game.player1.ypos, playersize*global.p1Size, playersize*global.p1Size, 0, c_white, 1)
	if global.p2Size < 1
		draw_sprite_ext(spr_ballWhite, 0, 960+_game.player2.xpos, 540+_game.player2.ypos, playersize*global.p2Size, playersize*global.p2Size, 0, c_white, 1)
	
	// Circle:
	gamerad = _game.game_radius + global.mapvibrate * (sin(global.time)) * 2.5
	global.mapvibrate *= 0.975
	draw_sprite_ext(spr_playingField, 0, 960, 540, gamerad / game_radius_start, gamerad / game_radius_start, 0, c_white, 1)
	
	// Arrows
	if global.p1Size >= 1
	{
		dir = point_direction(0, 0, _game.player1.xinput, _game.player1.yinput)
		vel = (0.4 + 0.6*point_distance(0, 0, _game.player1.xinput, _game.player1.yinput)) * 0.75
		draw_sprite_ext(spr_ballArrow, 0, 960+_game.player1.xpos, 540+_game.player1.ypos, playersize*vel, playersize*vel, dir, c_white, 1)
	}
	if global.p2Size >= 1
	{
		dir = point_direction(0, 0, _game.player2.xinput, _game.player2.yinput)
		vel = (0.4 + 0.6*point_distance(0, 0, _game.player2.xinput, _game.player2.yinput)) * 0.75
		draw_sprite_ext(spr_ballArrow, 0, 960+_game.player2.xpos, 540+_game.player2.ypos, playersize*vel, playersize*vel, dir, c_white, 1)
	}
	
	// Glows
	draw_sprite_ext(spr_glowLayer, 0, 0, 0, 1, 1, 0, c_white, 1)
	
	// Shadows
	shadowxoff = 15
	shadowyoff = 9
	if global.p1Size >= 1
		draw_sprite_ext(spr_ballShadow, 0, 960+_game.player1.xpos+shadowxoff, 540+_game.player1.ypos+shadowyoff, playersize, playersize, 0, c_white, 0.88)
	if global.p2Size >= 1
		draw_sprite_ext(spr_ballShadow, 0, 960+_game.player2.xpos+shadowxoff, 540+_game.player2.ypos+shadowyoff, playersize, playersize, 0, c_white, 0.88)
	
	// Players
	if global.p1Size >= 1
		draw_sprite_ext(spr_ballBlack, 0, 960+_game.player1.xpos, 540+_game.player1.ypos, playersize , playersize, 0, c_white, 1)
	if global.p2Size >= 1
		draw_sprite_ext(spr_ballWhite, 0, 960+_game.player2.xpos, 540+_game.player2.ypos, playersize, playersize, 0, c_white, 1)
	
	// Barrier:
	if _game.barrier_left > -15
	{
		if (_game.player1.xpos == -player_radius-barrier_width)
		if (_game.player1.xspeed < 0)
		{
			global.barrierfizzle = max(global.barrierfizzle, 0.25 + abs(_game.player1.xspeed) / 8)
			f = {
				xpos : -barrier_width,
				ypos : _game.player1.ypos,
				size : _game.player1.xspeed / 20,
				rot : random(360),
				time : 5,
				alph : 0.25,
				size_multi : 0.7,
			}
			ds_list_add(global.collisionFx, f)
			hitsound = choose(sou_bounce1, sou_bounce2, sou_bounce3)
			gain = abs(_game.player1.xspeed) / 15
			pitch = 0.95 + random(0.1)
			audio_play_sound_at(hitsound, f.xpos, f.ypos, 0, 1700, 7000, 1, false, 0.9, gain, 0, pitch)
		}
		if (_game.player2.xpos == player_radius+barrier_width)
		if (_game.player2.xpos > 0)
		{
			global.barrierfizzle = max(global.barrierfizzle, 0.25 + abs(_game.player2.xspeed) / 8)
			f = {
				xpos : barrier_width,
				ypos : _game.player2.ypos,
				size : _game.player2.xspeed / 20,
				rot : random(360),
				time : 5,
				alph : 0.25,
				size_multi : 0.7,
			}
			ds_list_add(global.collisionFx, f)
			hitsound = choose(sou_bounce1, sou_bounce2, sou_bounce3)
			gain = abs(_game.player2.xspeed) / 15
			pitch = 0.95 + random(0.1)
			audio_play_sound_at(hitsound, f.xpos, f.ypos, 0, 1700, 7000, 1, false, 0.9, gain, 0, pitch)
		}
		alph = 1 + (0.5 - random(1)) * global.barrierfizzle 
		global.barrierfizzle *= 0.95
		if _game.barrier_left <= 0
		{
			global.barrierwidth *= 0.85
		}
		draw_sprite_ext(spr_startWall, 0, 960, 540, alph * global.barrierwidth, 1, 0, c_white, alph)
	}
	
	// Collision FX:
	if _game.players_collided
	{
		f = {
			xpos : (_game.player1.xpos + _game.player2.xpos) / 2,
			ypos : (_game.player1.ypos + _game.player2.ypos) / 2,
			size : _game.players_collided_volocity / 50,
			rot : random(360),
			time : 5,
			alph : 0.25,
			size_multi : 0.7,
		}
		ds_list_add(global.collisionFx, f)
		hitsound = sou_hit1
		if (_game.players_collided_volocity) > 3
			hitsound = sou_hit2
		if (_game.players_collided_volocity) > 6
			hitsound = sou_hit3
		if (_game.players_collided_volocity) > 9
			hitsound = sou_hit4
		if (_game.players_collided_volocity) > 12
			hitsound = sou_hit5
		gain = _game.players_collided_volocity/10
		audio_play_sound_at(hitsound, f.xpos, f.ypos, 0, 1700, 7000, 1, false, 0.9, gain)
	}
	for(i = ds_list_size(global.collisionFx)-1; i >= 0; i--)
	{
		f = ds_list_find_value(global.collisionFx, i)
		draw_sprite_ext(spr_hitParticle, 0, f.xpos+960, f.ypos+540, f.size, f.size, f.rot, c_white, f.alph)
		f.size *= f.size_multi
		f.time--
		if (f.time <= 0)
			ds_list_delete(global.collisionFx, i)
	}
	
	// Game State
	if _game.game_state != game_state_ongoing
	{
		if global.title_delay == 30
			audio_play_sound(sou_matchover, 1, false, 0.4)
		global.title_delay--
	}
	if global.title_delay <= 0
	{
		if global.title_delay == 0
		{
			if _game.game_state == game_state_p1_wins
				audio_play_sound(sou_blackwin, 1, false, 0.4)
			if _game.game_state == game_state_p2_wins
				audio_play_sound(sou_whitewin, 1, false, 0.4)
			if _game.game_state == game_state_tie
				audio_play_sound(sou_matchover, 1, false, 0.4)
		}
		global.title_size = lerp(global.title_size, 1, 0.15)
		if _game.game_state == game_state_p1_wins
			draw_sprite_ext(spr_BlackWins, 0, 960, 540, global.title_size, global.title_size, 0, c_white, 1)
		if _game.game_state == game_state_p2_wins
			draw_sprite_ext(spr_WhiteWins, 0, 960, 540, global.title_size, global.title_size, 0, c_white, 1)
		if _game.game_state == game_state_tie
			draw_sprite_ext(spr_tie, 0, 960, 540, global.title_size, global.title_size, 0, c_white, 1)
	}
}