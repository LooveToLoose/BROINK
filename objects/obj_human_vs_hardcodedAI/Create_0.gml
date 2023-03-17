
// This lets the player play against a specific hardcoded AI
// Now there is a better and improved version of this in the game, so this object is obsolete.

// Start Game
game = new broink_game()
broink_hdvisualizer_ini()
game_running = false
codedAI = new hardcodedAI_lvl_07(game, game.player2, game.player1)
codedAI.StartOrReset()