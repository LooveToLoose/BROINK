
// Wait for the player to complete the main menu:
if current_gamemode == -1
	exit;
if current_gamemode == gamemode_pve
if current_vsAIColor == -1
	exit;
	
// Allow the player(s) to restart the match
if keyboard_check_pressed(ord("R"))
or keyboard_check_pressed(vk_backspace)
or gamepad_button_check_pressed(0, gp_face1)
or gamepad_button_check_pressed(1, gp_face1)
or (restart_match_after_end <= 0)
{
	game.Reset()
	broink_hdvisualizer_ini()
	pvp_countdown = 3
	game.player1.xinput = 0
	game.player1.yinput = 0
	game.player2.xinput = 0
	game.player2.yinput = 0
	
	// If the match hasn't ended yet, restarting is counted as a loss:
	if pve_match_ended == false 
	{
		if game.game_state == game_state_ongoing
			current_vsAIPoints--
		current_vsAIPoints = clamp(current_vsAIPoints, 0, 3)
	}
	
	// If you have enough point you advance to the next level:
	if (current_vsAIPoints >= 3) 
	{
		current_vsAIPoints = 0
		current_vsAILevel++
	}
	
	pve_match_begun = false
	pve_match_ended = false
	restart_match_after_end = 200
}
	
// Count match time:
if game.game_state != game_state_ongoing
	restart_match_after_end--
	
// Handle PvP Mode:
if current_gamemode == gamemode_pvp
{
	// Quick countdown before the match starts:
	if (pvp_countdown > 0)
	{
		pvp_countdown -= 1/30
		if (pvp_countdown == round(pvp_countdown))
			audio_play_sound(sou_drum1, 1, false, 0.4, 0, 1.5-pvp_countdown*0.2)
		exit;
	}
	
	game.player1.xinput = keyboard_check(ord("D")) - keyboard_check(ord("A"))
	game.player1.yinput = keyboard_check(ord("S")) - keyboard_check(ord("W"))
	game.player1.xinput += abs(gamepad_axis_value(0, gp_axislh)) > 0.15 ? gamepad_axis_value(0, gp_axislh) * 1.25 : 0
	game.player1.yinput += abs(gamepad_axis_value(0, gp_axislv)) > 0.15 ? gamepad_axis_value(0, gp_axislv) * 1.25 : 0
	
	game.player2.xinput = keyboard_check(vk_right) - keyboard_check(vk_left)
	game.player2.yinput = keyboard_check(vk_down) - keyboard_check(vk_up)
	game.player2.xinput += abs(gamepad_axis_value(1, gp_axislh)) > 0.15 ? gamepad_axis_value(1, gp_axislh) * 1.25 : 0
	game.player2.yinput += abs(gamepad_axis_value(1, gp_axislv)) > 0.15 ? gamepad_axis_value(1, gp_axislv) * 1.25 : 0
	
	game.Step()
}

// Handle PvE Mode:
if current_gamemode == gamemode_pve
{
	playerPlayer = (current_vsAIColor == color_black) ? game.player1 : game.player2
	aiPlayer = (current_vsAIColor == color_black) ? game.player2 : game.player1
	
	playerPlayer.xinput = keyboard_check(ord("D")) - keyboard_check(ord("A"))
	playerPlayer.yinput = keyboard_check(ord("S")) - keyboard_check(ord("W"))
	playerPlayer.xinput = keyboard_check(vk_right) - keyboard_check(vk_left)
	playerPlayer.yinput = keyboard_check(vk_down) - keyboard_check(vk_up)
	playerPlayer.xinput += abs(gamepad_axis_value(0, gp_axislh)) > 0.15 ? gamepad_axis_value(0, gp_axislh) * 1.25 : 0
	playerPlayer.yinput += abs(gamepad_axis_value(0, gp_axislv)) > 0.15 ? gamepad_axis_value(0, gp_axislv) * 1.25 : 0

	// The match begins as soon as the player gives any kind of input
	// That's also when the correct AI is initialized and started:
	if (playerPlayer.xinput != 0)
	or (playerPlayer.yinput != 0)
	if !pve_match_begun
	{
		pve_match_begun = true
		switch current_vsAILevel
		{
			case 1:
				codedAI = new hardcodedAI_lvl_01(game, aiPlayer, playerPlayer)
				break;
			case 2:
				codedAI = new hardcodedAI_lvl_02(game, aiPlayer, playerPlayer)
				break;
			case 3:
				codedAI = new hardcodedAI_lvl_03(game, aiPlayer, playerPlayer)
				break;
			case 4:
				codedAI = new hardcodedAI_lvl_04(game, aiPlayer, playerPlayer)
				break;
			case 5:
				codedAI = new hardcodedAI_lvl_05(game, aiPlayer, playerPlayer)
				break;
			case 6:
				codedAI = new hardcodedAI_lvl_06(game, aiPlayer, playerPlayer)
				break;
			default:
				codedAI = new hardcodedAI_lvl_07(game, aiPlayer, playerPlayer)
				break;
		}
		
		codedAI.StartOrReset()
	}
		
	// Stop here if the match has not started yet:
	if !pve_match_begun
		exit;
		
	// As soon as the winner has been decided, give points:
	if game.game_state != game_state_ongoing
	if pve_match_ended == false
	{
		pve_match_ended = true
		
		if (game.game_state == game_state_p1_wins and current_vsAIColor == color_black)
		or (game.game_state == game_state_p2_wins and current_vsAIColor == color_white)
			current_vsAIPoints++
		else if game.game_state != game_state_tie
			current_vsAIPoints--
		current_vsAIPoints = clamp(current_vsAIPoints, 0, 3)
	}
	
	codedAI.Step()
	aiPlayer.xinput = codedAI.xoutput
	aiPlayer.yinput = codedAI.youtput
	
	game.Step()
}