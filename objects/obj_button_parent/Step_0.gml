if !visible
	exit;
	
hover_over = position_meeting(mouse_x, mouse_y, id)
image_xscale = lerp(image_xscale, 1+hover_over*0.1, 0.4)
image_yscale = image_xscale
inactive_timer--

if mouse_check_button_pressed(mb_left) and hover_over and (inactive_timer <= 0)
{
	audio_play_sound(sou_drum1, 1, false, 0.6)
	event_user(0)
}