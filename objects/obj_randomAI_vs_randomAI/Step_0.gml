



// Simple AI Enemy
set_gigabrain_inputs_for_gamestate(randombrain1, game)
set_gigabrain_inputs_for_gamestate(randombrain2, game)
randombrain1.calculate()
randombrain2.calculate()
	
// Set Game Inputs
game.player1.xinput = randombrain1.li_neurons[|randombrain1.neuroncount-2].val
game.player1.yinput = randombrain1.li_neurons[|randombrain1.neuroncount-1].val
game.player2.xinput = randombrain2.li_neurons[|randombrain2.neuroncount-2].val
game.player2.yinput = randombrain2.li_neurons[|randombrain2.neuroncount-1].val

game.Step()