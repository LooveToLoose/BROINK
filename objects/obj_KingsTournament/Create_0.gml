
// This is an object I wrote for testing AIs.
// The script reads AIs from the AppData/Local/BROINK folder and makes them go up against each other.
// There are some hotkeys to skip to the next match, see step event

function quip_kings_and_restart_match()
{
	game = new broink_game()
	broink_hdvisualizer_ini()
	game_running = false
	blackAI = loadbrain("King "+string(blackKing)+".txt")
	whiteAI = loadbrain("King "+string(whiteKing)+".txt")
}


blackKing = 2
whiteKing = 1
quip_kings_and_restart_match()