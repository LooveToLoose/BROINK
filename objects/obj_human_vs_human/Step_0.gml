
// Player Input
xinput2 = keyboard_check(vk_right) - keyboard_check(vk_left)
yinput2 = keyboard_check(vk_down) - keyboard_check(vk_up)
xinput2 += abs(gamepad_axis_value(0, gp_axislh)) > 0.1 ? gamepad_axis_value(0, gp_axislh) * 1.25 : 0
yinput2 += abs(gamepad_axis_value(0, gp_axislv)) > 0.1 ? gamepad_axis_value(0, gp_axislv) * 1.25 : 0

// Player 2 Input
xinput1 = keyboard_check(ord("D")) - keyboard_check(ord("A"))
yinput1 = keyboard_check(ord("S")) - keyboard_check(ord("W"))
xinput1 += abs(gamepad_axis_value(1, gp_axislh)) > 0.1 ? gamepad_axis_value(1, gp_axislh) * 1.25 : 0
yinput1 += abs(gamepad_axis_value(1, gp_axislv)) > 0.1 ? gamepad_axis_value(1, gp_axislv) * 1.25 : 0

// Set Game Inputs
game.player1.xinput = xinput1
game.player1.yinput = yinput1
game.player2.xinput = xinput2
game.player2.yinput = yinput2

// Simulate Game:
game_state = game.Step()