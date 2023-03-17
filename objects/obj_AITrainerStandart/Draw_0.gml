
if !go
	exit;

function draw_species_analytics(_xstart, _ystart, _xend, _yend, _gigaspecies)
{
	draw_set_font(font_main)
	draw_set_halign(fa_middle)
	draw_set_valign(fa_top)
	draw_text_transformed((_xstart + _xend)/2, _ystart, "Best: "+string(_gigaspecies.li_anaytics_fitness[|0]), 0.6, 0.6, 0)
	draw_text_transformed((_xstart + _xend)/2, _ystart+50, "Generation: "+string(_gigaspecies.generation), 0.6, 0.6, 0)
	_ystart += 100
	
	maxfitness = max(0, _gigaspecies.li_anaytics_fitness[|0])
	minfitness = min(0,_gigaspecies.li_anaytics_fitness[|ds_list_size(_gigaspecies.li_anaytics_fitness)-1])
	zeropoint = -minfitness / (maxfitness - minfitness)
	zeropointx = lerp(_xstart, _xend, zeropoint)
	remainingheight = _yend - _ystart
	heightperbar = remainingheight / (ds_list_size(_gigaspecies.li_anaytics_fitness) + 1)
	for(i = 0; i < ds_list_size(_gigaspecies.li_anaytics_fitness); i++)
	{
		y1 = _ystart + i * heightperbar
		y2 = y1 + heightperbar * 0.6
		x1 = zeropointx
		x2 = (_gigaspecies.li_anaytics_fitness[|i] - minfitness) / (maxfitness - minfitness)
		x2 = lerp(_xstart, _xend, x2)
		coli = (_gigaspecies.li_anaytics_fitness[|i] > 0) ? c_white : c_red
		draw_rectangle_color(x1, y1, x2, y2, coli, coli, coli, coli, false)
	}
}

draw_species_analytics(100, 100, 1820, 980, trainer.li_species[|0])