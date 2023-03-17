
// Unlimited Frame Rate Mode
if (global.unlimited_fps)
{
	draw_set_font(font_main)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_text(10, 10, "FPS: "+string(fps))
}

	