
// This is an object I wrote for testing AIs against the player
// The script reads AIs from the AppData/Local/BROINK folder and let's the player fight them.
// R restarts the match or moves on to the next one if you won the previous one.

function quip_kings_and_restart_match()
{
	game = new broink_game()
	broink_hdvisualizer_ini()
	game_running = false
	whiteAI = loadbrain("King "+string(whiteKing)+".txt")
}


whiteKing = 1
quip_kings_and_restart_match()