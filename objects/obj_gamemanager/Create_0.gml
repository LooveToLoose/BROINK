
// This object controls the entire flow of the game at the moment.
// Game, AI and Visualization are 3 different systems in this project and this object glues those systems together into a proper game.

#macro gamemode_pvp 0
#macro gamemode_pve 1
#macro color_black 0
#macro color_white 1

current_gamemode = -1
current_vsAIColor = -1
current_vsAIPoints = 0
current_vsAILevel = 1

game = new broink_game()
broink_hdvisualizer_ini()
pvp_countdown = 3
pve_match_begun = false
pve_match_ended = false
restart_match_after_end = 200