
// Draw the game:
broink_hdvisualizer_draw(game)

// Draw the countdown in the PvP mode:
if current_gamemode == gamemode_pvp
if pvp_countdown > 0
{
	if pvp_countdown > 2
		draw_sprite(spr_3, 0, 960, 540)
	else if pvp_countdown > 1
		draw_sprite(spr_2, 0, 960, 540)
	else
		draw_sprite(spr_1, 0, 960, 540)
}

// Draw the level and score counter in PvE mode:
if current_gamemode == gamemode_pve
if current_vsAIColor != -1
{
	circles_x = (current_vsAIColor == color_black) ? 60 : (1920-60)
	cups_x = (current_vsAIColor == color_white) ? 60 : (1920-60)
	
	ydist = 110
	ydraw = 540 - 2 * ydist * 0.5
	for (var i = 0; i < 3; i++)
	{
		draw_sprite_ext((current_vsAIPoints > i) ? spr_winsFilled : spr_winsEmpty, 0, circles_x, ydraw, 0.7, 0.7, 0, c_white, 1)
		ydraw += ydist
	}
	
	ydist = 100
	ydraw = 540 - 6 * ydist * 0.5
	for (var i = 0; i < 7; i++)
	{
		draw_sprite_ext((current_vsAILevel > i+1) ? spr_cupFilled : spr_cupEmpty, 0, cups_x, ydraw, 0.25, 0.25, 0, c_white, 1)
		ydraw += ydist
	}
}