
if keyboard_check_pressed(vk_space)
	game_running = true
if keyboard_check_pressed(vk_down)
	quip_kings_and_restart_match()
if keyboard_check_pressed(vk_right)
{
	if (blackKing > whiteKing)
	{
		whiteKing = blackKing
		blackKing = blackKing-1
	}
	else
	{
		blackKing = max(blackKing, whiteKing) + 1
		whiteKing = blackKing - 1
	}
	
	quip_kings_and_restart_match()
}

if game_running
{
	set_gigabrain_inputs_for_gamestate_black(blackAI, game)
	set_gigabrain_inputs_for_gamestate_white(whiteAI, game)
	blackAI.calculate()
	whiteAI.calculate()
	
	// Set Game Inputs
	game.player1.xinput = get_gigabrain_output_x(blackAI, game.player1)
	game.player1.yinput = get_gigabrain_output_y(blackAI, game.player1)
	game.player2.xinput = get_gigabrain_output_x(whiteAI, game.player2)
	game.player2.yinput = get_gigabrain_output_y(whiteAI, game.player2)
	
	// Simulate Game
	game.Step()
}
