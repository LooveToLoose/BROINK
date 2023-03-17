
if !go
	exit;

function draw_species_analytics(_xstart, _ystart, _xend, _yend, _gigaspecies)
{
	if ds_list_size(_gigaspecies.li_anaytics_fitness) <= 0
		return;
	
	draw_set_font(font_main)
	draw_set_halign(fa_middle)
	draw_set_valign(fa_top)
	draw_text_transformed((_xstart + _xend)/2, _ystart, string(_gigaspecies.li_anaytics_fitness[|0]), 0.3, 0.3, 0)
	draw_text_transformed((_xstart + _xend)/2, _ystart+30, string(_gigaspecies.generation), 0.3, 0.3, 0)
	_ystart += 100
	
	maxfitness = max(0, _gigaspecies.li_anaytics_fitness[|0])
	minfitness = min(0,_gigaspecies.li_anaytics_fitness[|ds_list_size(_gigaspecies.li_anaytics_fitness)-1])
	zeropoint = -minfitness / (maxfitness - minfitness)
	zeropointx = lerp(_xstart, _xend, zeropoint)
	remainingheight = _yend - _ystart
	heightperbar = remainingheight / (ds_list_size(_gigaspecies.li_anaytics_fitness))
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

xbegin = 100
xend = 1820
range = xend - xbegin
xstep = range / (ds_list_size(trainer.li_species))
for(t = 0; t < ds_list_size(trainer.li_species); t++)
{
	xs = xbegin + xstep * t + 10
	xe = xbegin + xstep * (t + 1) - 10
	draw_species_analytics(xs, 100, xe, 980, trainer.li_species[|t])
}