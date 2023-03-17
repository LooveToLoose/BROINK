// Save an AI to a file:
function savebrain(_gigabrain, _filename)
{
	var file = file_text_open_write(_filename)
	
	// Neuron Amount and Types:
	file_text_write_string(file, "Input Output Type: "); file_text_writeln(file);
	file_text_write_real(file, _gigabrain.inputoutput_type); file_text_writeln(file);
	for(var i = 0; i < ds_list_size(_gigabrain.li_neurons); i++)
	{
		file_text_write_string(file, "----------------------------------"); file_text_writeln(file);
		var neuron = _gigabrain.li_neurons[|i];
		file_text_write_string(file, "Type: "); file_text_writeln(file);
		file_text_write_real(file, neuron.typeID); file_text_writeln(file);
		file_text_write_string(file, "Connections: "); file_text_writeln(file);
		file_text_write_real(file, ds_list_size(neuron.li_inputs)); file_text_writeln(file);
		for(var o = 0; o < ds_list_size(neuron.li_inputs); o++)
		{
			file_text_write_real(file, neuron.li_inputs[|o].index); file_text_writeln(file);
		}
		file_text_write_string(file, "Weights: "); file_text_writeln(file);
		file_text_write_real(file, ds_list_size(neuron.li_weights)); file_text_writeln(file);
		for(var o = 0; o < ds_list_size(neuron.li_weights); o++)
		{
			file_text_write_real(file, neuron.li_weights[|o]); file_text_writeln(file);
		}
	}
	
	file_text_close(file)
}

// Load an AI from a file:
function loadbrain(_filename)
{
	var file = file_text_open_read(_filename)
	var brainy = new gigabrain(0,0)
	ds_list_clear(brainy.li_neurons)
	var index = 0
	
	file_text_readln(file) //neurons
	brainy.inputoutput_type = file_text_read_real(file); file_text_readln(file) //neuroncount
	while(true)
	{
		if (file_text_read_string(file) != "----------------------------------")
			break;
		file_text_readln(file) // -------------
		file_text_readln(file) // Type
		var type = file_text_read_real(file); file_text_readln(file)
		var neuron
		switch type
		{
			case typeID_linear:
				neuron = new giganeuron_linear(index)
				ds_list_add(brainy.li_neurons, neuron)
				break;
			case typeID_clamp:
				neuron = new giganeuron_clamp(index)
				ds_list_add(brainy.li_neurons, neuron)
				break;
			case typeID_null:
				neuron = new giganeuron(index)
				ds_list_add(brainy.li_neurons, neuron)
				break;
			case typeID_relu:
				neuron = new giganeuron_relu(index)
				ds_list_add(brainy.li_neurons, neuron)
				break;
			case typeID_sin:
				neuron = new giganeuron_sin(index)
				ds_list_add(brainy.li_neurons, neuron)
				break;
			case typeID_multiply:
				neuron = new giganeuron_multiply(index)
				ds_list_add(brainy.li_neurons, neuron)
				break;
			case typeID_bool:
				neuron = new giganeuron_bool(index)
				ds_list_add(brainy.li_neurons, neuron)
				break;
			
		}
		index++
		file_text_readln(file) // Connections
		var listlength = file_text_read_real(file); file_text_readln(file);
		for(var z = 0; z < listlength; z++)
		{
			var value = file_text_read_real(file); file_text_readln(file);
			ds_list_add(neuron.li_inputs, brainy.li_neurons[|value]);
		}
		file_text_readln(file) // Weights
		var listlength = file_text_read_real(file); file_text_readln(file);
		for(var z = 0; z < listlength; z++)
		{
			var value = file_text_read_real(file); file_text_readln(file);
			ds_list_add(neuron.li_weights, value);
		}
	}
	brainy.neuroncount = index
	brainy.hidden_neurons = brainy.neuroncount - giga_inputs - giga_outputs
	file_text_close(file)
	return brainy
}