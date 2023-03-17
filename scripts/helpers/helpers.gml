// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function set_gigabrain_inputs_for_gamestate_black(_gigabrain, _game){
	plself = _game.player1
	plother = _game.player2
	if(_gigabrain.inputoutput_type == inputoutput_type_regular)
	{
		_gigabrain.li_neurons[|0].val = 1
		_gigabrain.li_neurons[|1].val = plself.xpos / 50
		_gigabrain.li_neurons[|2].val = plself.ypos / 50
		_gigabrain.li_neurons[|3].val = plother.xpos / 50
		_gigabrain.li_neurons[|4].val = plother.ypos / 50
		_gigabrain.li_neurons[|5].val = plself.xspeed
		_gigabrain.li_neurons[|6].val = plself.yspeed
		_gigabrain.li_neurons[|7].val = plother.xspeed
		_gigabrain.li_neurons[|8].val = plother.yspeed
		_gigabrain.li_neurons[|9].val = _game.barrier_left / 100
	}
	else
	{
		referencerot = point_direction(0, 0, plself.xpos, plself.ypos)
		
		_gigabrain.li_neurons[|0].val = 1
		
		vectorrot = angle_difference( point_direction(0, 0, plself.xpos, plself.ypos), referencerot)
		vectorlen = point_distance(0, 0, plself.xpos, plself.ypos) / 50
		_gigabrain.li_neurons[|1].val = lengthdir_x(vectorlen, vectorrot)
		_gigabrain.li_neurons[|2].val = lengthdir_y(vectorlen, vectorrot)
		
		vectorrot = angle_difference( point_direction(0, 0, plother.xpos, plother.ypos), referencerot)
		vectorlen = point_distance(0, 0, plother.xpos, plother.ypos) / 50
		_gigabrain.li_neurons[|3].val = lengthdir_x(vectorlen, vectorrot)
		_gigabrain.li_neurons[|4].val = lengthdir_y(vectorlen, vectorrot)
		
		vectorrot = angle_difference( point_direction(0, 0, plself.xspeed, plself.yspeed), referencerot)
		vectorlen = point_distance(0, 0, plself.xspeed, plself.yspeed)
		_gigabrain.li_neurons[|5].val = lengthdir_x(vectorlen, vectorrot)
		_gigabrain.li_neurons[|6].val = lengthdir_y(vectorlen, vectorrot)
		
		vectorrot = angle_difference( point_direction(0, 0, plother.xspeed, plother.yspeed), referencerot)
		vectorlen = point_distance(0, 0, plother.xspeed, plother.yspeed)
		_gigabrain.li_neurons[|7].val = lengthdir_x(vectorlen, vectorrot)
		_gigabrain.li_neurons[|8].val = lengthdir_y(vectorlen, vectorrot)
		
		_gigabrain.li_neurons[|9].val = _game.barrier_left / 100
	}
}

function set_gigabrain_inputs_for_gamestate_white(_gigabrain, _game){
	plself = _game.player2
	plother = _game.player1
	if(_gigabrain.inputoutput_type == inputoutput_type_regular)
	{
		_gigabrain.li_neurons[|0].val = 1
		_gigabrain.li_neurons[|1].val = plself.xpos / 50
		_gigabrain.li_neurons[|2].val = plself.ypos / 50
		_gigabrain.li_neurons[|3].val = plother.xpos / 50
		_gigabrain.li_neurons[|4].val = plother.ypos / 50
		_gigabrain.li_neurons[|5].val = plself.xspeed
		_gigabrain.li_neurons[|6].val = plself.yspeed
		_gigabrain.li_neurons[|7].val = plother.xspeed
		_gigabrain.li_neurons[|8].val = plother.yspeed
		_gigabrain.li_neurons[|9].val = _game.barrier_left / 100
	}
	else
	{
		referencerot = point_direction(0, 0, plself.xpos, plself.ypos)
		
		_gigabrain.li_neurons[|0].val = 1
		
		vectorrot = angle_difference( point_direction(0, 0, plself.xpos, plself.ypos), referencerot)
		vectorlen = point_distance(0, 0, plself.xpos, plself.ypos) / 50
		_gigabrain.li_neurons[|1].val = lengthdir_x(vectorlen, vectorrot)
		_gigabrain.li_neurons[|2].val = lengthdir_y(vectorlen, vectorrot)
		
		vectorrot = angle_difference( point_direction(0, 0, plother.xpos, plother.ypos), referencerot)
		vectorlen = point_distance(0, 0, plother.xpos, plother.ypos) / 50
		_gigabrain.li_neurons[|3].val = lengthdir_x(vectorlen, vectorrot)
		_gigabrain.li_neurons[|4].val = lengthdir_y(vectorlen, vectorrot)
		
		vectorrot = angle_difference( point_direction(0, 0, plself.xspeed, plself.yspeed), referencerot)
		vectorlen = point_distance(0, 0, plself.xspeed, plself.yspeed)
		_gigabrain.li_neurons[|5].val = lengthdir_x(vectorlen, vectorrot)
		_gigabrain.li_neurons[|6].val = lengthdir_y(vectorlen, vectorrot)
		
		vectorrot = angle_difference( point_direction(0, 0, plother.xspeed, plother.yspeed), referencerot)
		vectorlen = point_distance(0, 0, plother.xspeed, plother.yspeed)
		_gigabrain.li_neurons[|7].val = lengthdir_x(vectorlen, vectorrot)
		_gigabrain.li_neurons[|8].val = lengthdir_y(vectorlen, vectorrot)
		
		_gigabrain.li_neurons[|9].val = _game.barrier_left / 100
	}
}

function get_gigabrain_output_x(_gigabrain, _playerself = undefined)
{
	if(_gigabrain.inputoutput_type == inputoutput_type_regular)
		return _gigabrain.li_neurons[|_gigabrain.neuroncount-2].val
	else
	{
		referencerot = point_direction(0, 0, _playerself.xpos, _playerself.ypos)
		varxout = _gigabrain.li_neurons[|_gigabrain.neuroncount-2].val
		varyout = _gigabrain.li_neurons[|_gigabrain.neuroncount-1].val
		vectorrot = point_direction(0, 0, varxout, varyout) + referencerot
		vectorlen = point_distance(0, 0, varxout, varyout)
		return lengthdir_x(vectorlen, vectorrot)
	}
}

function get_gigabrain_output_y(_gigabrain, _playerself = undefined)
{
	if(_gigabrain.inputoutput_type == inputoutput_type_regular)
		return _gigabrain.li_neurons[|_gigabrain.neuroncount-1].val
	else
	{
		referencerot = point_direction(0, 0, _playerself.xpos, _playerself.ypos)
		varxout = _gigabrain.li_neurons[|_gigabrain.neuroncount-2].val
		varyout = _gigabrain.li_neurons[|_gigabrain.neuroncount-1].val
		vectorrot = point_direction(0, 0, varxout, varyout) + referencerot
		vectorlen = point_distance(0, 0, varxout, varyout)
		return lengthdir_y(vectorlen, vectorrot)
	}
}