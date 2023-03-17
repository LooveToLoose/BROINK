
// Restart Room:
if keyboard_check_pressed(ord("R"))
or gamepad_button_check_pressed(0, gp_face4)
or gamepad_button_check_pressed(0, gp_face1)
{
	game.Reset()
	game_running = false
	broink_hdvisualizer_ini()
	codedAI.StartOrReset()
}

// Player Input
xinput1 = keyboard_check(vk_right) - keyboard_check(vk_left)
yinput1 = keyboard_check(vk_down) - keyboard_check(vk_up)
xinput1 += abs(gamepad_axis_value(0, gp_axislh)) > 0.15 ? gamepad_axis_value(0, gp_axislh) * 1.25 : 0
yinput1 += abs(gamepad_axis_value(0, gp_axislv)) > 0.15 ? gamepad_axis_value(0, gp_axislv) * 1.25 : 0
if (xinput1 != 0 or yinput1 != 0)
	game_running = true

if game_running
{
	// AI Enemy
	codedAI.Step()
	xinput2 = codedAI.xoutput
	yinput2 = codedAI.youtput
	
	// Set Game Inputs
	game.player1.xinput = xinput1
	game.player1.yinput = yinput1
	game.player2.xinput = xinput2
	game.player2.yinput = yinput2
}

// Simulate Game
if game_running
	game.Step()