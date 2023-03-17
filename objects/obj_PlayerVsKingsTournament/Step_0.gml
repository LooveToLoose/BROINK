
// Player Input
xinput2 = keyboard_check(vk_right) - keyboard_check(vk_left)
yinput2 = keyboard_check(vk_down) - keyboard_check(vk_up)
xinput2 += abs(gamepad_axis_value(0, gp_axislh)) > 0.15 ? gamepad_axis_value(0, gp_axislh) * 1.25 : 0
yinput2 += abs(gamepad_axis_value(0, gp_axislv)) > 0.15 ? gamepad_axis_value(0, gp_axislv) * 1.25 : 0
if (xinput2 != 0 or yinput2 != 0)
	game_running = true

// Hotkeys:
if keyboard_check_pressed(ord("R"))
or gamepad_button_check_pressed(0, gp_face1)
{
	if (game.game_state == game_state_p1_wins)
		whiteKing++
	quip_kings_and_restart_match()
}

if game_running
{
	set_gigabrain_inputs_for_gamestate_white(whiteAI, game)
	whiteAI.calculate()
	
	// Set Game Inputs
	game.player1.xinput = xinput2
	game.player1.yinput = yinput2
	game.player2.xinput = get_gigabrain_output_x(whiteAI, game.player2)
	game.player2.yinput = get_gigabrain_output_y(whiteAI, game.player2)
	
	// Simulate Game
	game.Step()
}
