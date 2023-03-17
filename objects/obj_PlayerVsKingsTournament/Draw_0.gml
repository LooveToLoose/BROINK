
// Draw Game
broink_hdvisualizer_draw(game)

draw_set_font(font_main)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)

draw_set_color(c_black)
draw_text(960+game.player2.xpos+3-4, 540+game.player2.ypos+3+3, whiteKing)

draw_set_color(c_white)
draw_text(960+game.player2.xpos-4, 540+game.player2.ypos+3, whiteKing)