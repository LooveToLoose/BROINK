

function hardcodedAI_lvl_03(_game, _playerSelf, _playerOther) constructor
{
	game = _game
	playerSelf = _playerSelf
	playerOther = _playerOther
	
	enemyspeed_offset = 10
	
	function StartOrReset()
	{
		xoutput = 0
		youtput = 0
		opening_y = 1-random(2)
		current_mode = mode_defensive
		position_score = 0
		playerSelf.xinput = 0
		playerSelf.yinput = 0
		
	}
	
	function Step()
	{
		CalculatePositionScore()
		if game.game_radius < 300
			current_mode = mode_offensive
		
		switch(current_mode)
		{
			case mode_camp_center:
				ModeCampCenter()
				break;
			case mode_offensive:
				ModeOffensive()
				break;
			case mode_defensive:
				ModeDefensive()
				break;
			case mode_opening:
				ModeOpening()
				break;
		}
		
		//OutOfBoundsEmergencyBreak()
	}

	function ModeOpening()
	{
		var opening_dir = point_direction(0, 0, 1, abs(opening_y))
		if (game.barrier_left > barrier_duration-32 + sin(opening_dir/180*pi) * 4)
		{
			xoutput = sign(playerSelf.xpos)
			youtput = opening_y
		}
		else
			ModeOffensive()
	}

	function ModeCampCenter()
	{
		var enemydirfromcenter = point_direction(0, 0, playerOther.xpos, playerOther.ypos)
		var xtarget = lengthdir_x(50, enemydirfromcenter)
		var ytarget = lengthdir_y(50, enemydirfromcenter)
		xoutput = (xtarget-playerSelf.xpos)/10 -playerSelf.xspeed/2
		youtput = (ytarget-playerSelf.ypos)/10 -playerSelf.yspeed/2
		xoutput -= playerOther.xspeed
		youtput -= playerOther.yspeed
		SetOutputsToAchieveTargetVelocity(point_direction(0, 0, xoutput, youtput), 100000)
	}
	
	function ModeOffensive()
	{
		var distance = point_distance(playerSelf.xpos, playerSelf.ypos, playerOther.xpos, playerOther.ypos)
		var xtarget = playerOther.xpos
		var ytarget = playerOther.ypos
		var target_direction = point_direction(playerSelf.xpos, playerSelf.ypos, xtarget, ytarget)
		
		var xtarget_offset = (playerOther.xspeed - playerSelf.xspeed) * distance * 0.2
		var ytarget_offset = (playerOther.yspeed - playerSelf.yspeed) * distance * 0.2
		var offset_direction = point_direction(0, 0, xtarget_offset, ytarget_offset)
		var angledifffactor = (90-abs(abs(angle_difference(target_direction, offset_direction))-90))/90
		xtarget += xtarget_offset * angledifffactor
		ytarget += ytarget_offset * angledifffactor
		
		target_direction = point_direction(playerSelf.xpos, playerSelf.ypos, xtarget, ytarget)
		var enemyspeed = point_distance(playerOther.xspeed, playerOther.yspeed, 0, 0)
		SetOutputsToAchieveTargetVelocity(target_direction, enemyspeed + enemyspeed_offset)
	}
	
	function ModeDefensive()
	{
		var enemy_speed = point_distance(playerOther.xspeed, playerOther.yspeed, 0, 0)
		var otherDirection = point_direction(0, 0, playerOther.xspeed, playerOther.yspeed)
		var otherDirectionToEnemy = point_direction(playerOther.xpos, playerOther.ypos, playerSelf.xpos, playerSelf.ypos)
		var otherDirectionAligned = (180 - (abs(angle_difference(otherDirectionToEnemy, otherDirection))+90)) /90
		/*if (otherDirectionAligned < 0)
		{
			var direction_to_enemy = point_direction(playerSelf.xpos, playerSelf.ypos, playerOther.xpos, playerOther.ypos)
			SetOutputsToAchieveTargetVelocity(direction_to_enemy, enemy_speed + enemyspeed_offset)
		}
		else*/
		{
			var enemy_movedir = point_direction(0, 0, playerOther.xspeed, playerOther.yspeed)
			var own_speed = point_distance(playerSelf.xspeed, playerSelf.yspeed, 0, 0)
			var enemy_distance = point_distance(playerSelf.xpos, playerSelf.ypos, playerOther.xpos, playerOther.ypos)
			var predicted_enemy_pos_x = playerOther.xpos + lengthdir_x(enemy_distance, enemy_movedir)
			var predicted_enemy_pos_y = playerOther.ypos + lengthdir_y(enemy_distance, enemy_movedir)
		
			var mytargetdir = point_direction(predicted_enemy_pos_x, predicted_enemy_pos_y, playerSelf.xpos, playerSelf.ypos)
			var my_direction_from_center = point_direction(0, 0, playerSelf.xpos, playerSelf.ypos)
			var angle_diff = angle_difference(mytargetdir, my_direction_from_center)
			if (angle_diff == 0 or angle_diff == 180 or angle_diff == -180)
				angle_diff = choose(1, -1)
			var outwards_percentage = point_distance(0, 0, playerSelf.xpos, playerSelf.ypos) / game.game_radius
			mytargetdir = my_direction_from_center + (90 + own_speed*4 + outwards_percentage*0) * sign(angle_diff)
			SetOutputsToAchieveTargetVelocity(mytargetdir, enemy_speed + enemyspeed_offset)
		}
	}

	function CalculatePositionScore()
	{
		position_score = 0
		var selfSpeed = point_distance(0, 0, playerSelf.xspeed, playerSelf.yspeed)
		var otherSpeed = point_distance(0, 0, playerOther.xspeed, playerOther.yspeed)
		var selfDirection = point_direction(0, 0, playerSelf.xspeed, playerSelf.yspeed)
		var otherDirection = point_direction(0, 0, playerOther.xspeed, playerOther.yspeed)
		
		// Give points for being closer to the center:
		/*var selfDistFromCenter = point_distance(0, 0, playerSelf.xpos, playerSelf.ypos)
		var otherDistFromCenter = point_distance(0, 0, playerOther.xpos, playerOther.ypos)
		position_score += otherDistFromCenter * 0.3
		position_score -= selfDistFromCenter * 0.3
		
		// Give points for moving towards the center:
		var selfDirectionToCenter = point_direction(playerSelf.xpos, playerSelf.ypos, 0, 0)
		var otherDirectionToCenter = point_direction(playerOther.xpos, playerOther.ypos, 0, 0)
		var selfDirectionAligned = (180 - (abs(angle_difference(selfDirectionToCenter, selfDirection))+90)) /90
		var otherDirectionAligned = (180 - (abs(angle_difference(otherDirectionToCenter, otherDirection))+90)) /90
		position_score += selfDirectionAligned * selfSpeed * 4
		position_score -= otherDirectionAligned * otherSpeed * 4*/
		
		// Give points for moving towards the enemy:
		var selfDirectionToEnemy = point_direction(playerSelf.xpos, playerSelf.ypos, playerOther.xpos, playerOther.ypos)
		var otherDirectionToEnemy = point_direction(playerOther.xpos, playerOther.ypos, playerSelf.xpos, playerSelf.ypos)
		var selfDirectionAligned = (180 - (abs(angle_difference(selfDirectionToEnemy, selfDirection))+90)) /90
		var otherDirectionAligned = (180 - (abs(angle_difference(otherDirectionToEnemy, otherDirection))+90)) /90
		position_score += selfDirectionAligned * selfSpeed * 15
		position_score -= otherDirectionAligned * otherSpeed * 15
		
		position_score *= 800 / game.game_radius
	}
	
	function SetOutputsToAchieveTargetVelocity(_targetDirection, _maxVelocity)
	{
		var currentDirection = point_direction(0, 0, playerSelf.xspeed, playerSelf.yspeed)
		var directionsMatch = ((180 - (abs(angle_difference(currentDirection, _targetDirection))+90)) /90 + 1)/2
		directionsMatch = lerp(directionsMatch, 0, 0.4)
		xoutput = lengthdir_x(100, _targetDirection) * directionsMatch
		youtput = lengthdir_y(100, _targetDirection) * directionsMatch
		xoutput += -lengthdir_x(100, currentDirection) * (1-directionsMatch)
		youtput += -lengthdir_y(100, currentDirection) * (1-directionsMatch)
		var velocity = point_distance(playerSelf.xspeed, playerSelf.yspeed, 0, 0)
		if velocity > _maxVelocity
		{
			xoutput += -lengthdir_x(velocity - _maxVelocity, currentDirection)*50
			youtput += -lengthdir_y(velocity - _maxVelocity, currentDirection)*50
		}
	}
	
	function OutOfBoundsEmergencyBreak()
	{
		var fakexpos = playerSelf.xpos
		var fakeypos = playerSelf.ypos
		var fakexspeed = playerSelf.xspeed
		var fakeyspeed = playerSelf.yspeed
		var fakeradius = game.game_radius - 400
		var fakespeed = point_distance(0, 0, fakexspeed, fakeyspeed)
		var fakedirection = point_direction(0, 0, fakexspeed, fakeyspeed)
		var breakdirection = fakedirection
		var outside = point_direction(0, 0, playerSelf.xpos, playerSelf.ypos)
		var angle = angle_difference(breakdirection, outside)
		if (abs(angle) >= 90)
			breakdirection = outside+(180-abs(angle))*sign(angle)*0.4
		else
			breakdirection = outside+(abs(angle))*sign(angle)*0.4
		
		var must_emergency_break = false
		fakexpos += fakexspeed
		fakeypos += fakeyspeed
		while (fakespeed > 0)
		{
			fakexpos += fakexspeed
			fakeypos += fakeyspeed
			fakespeed -= player_acceleration
			fakexspeed -= lengthdir_x(player_acceleration, breakdirection)
			fakeyspeed -= lengthdir_y(player_acceleration, breakdirection)
			fakeradius -= game_radius_start / game_duration
			if point_distance(0, 0, fakexpos, fakeypos) >= fakeradius + player_radius
			{
				must_emergency_break = true
				break;
			}
		}
		if (must_emergency_break)
		{
			xoutput = -lengthdir_x(10, breakdirection)
			youtput = -lengthdir_y(10, breakdirection)
		}
	}
}