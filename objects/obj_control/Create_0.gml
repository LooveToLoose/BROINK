
// This is a little control object I wrote to handle some basic functionality like restarting the room and closing the game.
// It is not really necessary or needed anymore, but should still work if oyu put it into a room.

// Settings
draw_set_circle_precision(64)

// Unlimited Framerate Mode
if !variable_global_exists("unlimited_fps")
	global.unlimited_fps = false
display_reset(8, !global.unlimited_fps)
show_debug_overlay(global.unlimited_fps)
if global.unlimited_fps
	room_speed = 1000000
else
	room_speed = 60