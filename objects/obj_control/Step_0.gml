

// End Game:
if keyboard_check_pressed(vk_escape)
	game_end()
	
// Restart Room:
if keyboard_check_pressed(ord("R"))
or gamepad_button_check_pressed(0, gp_face4)
	room_restart()
	
// Unlimited Framerate Mode:
if keyboard_check_pressed(ord("U"))
{
	global.unlimited_fps = !global.unlimited_fps
	display_reset(8, !global.unlimited_fps)
	show_debug_overlay(global.unlimited_fps)
}
if global.unlimited_fps
	room_speed = 1000000
else
	room_speed = 60