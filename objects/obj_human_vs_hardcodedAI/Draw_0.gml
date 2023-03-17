
// Draw Game
broink_hdvisualizer_draw(game)



draw_set_font(font_main)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)

/*draw_set_color(c_black)
draw_text_transformed(960+game.player2.xpos, 540+game.player2.ypos+3, "AI", 0.8, 0.8, 0)
/*
draw_set_color((codedAI.position_score > 0) ? c_white : c_red)
draw_rectangle(960, 10, 960+codedAI.position_score, 20, false) 