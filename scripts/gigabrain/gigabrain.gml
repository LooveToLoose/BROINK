// This is my home made neural evolution tryining system
// It doesn't seem to work particularly well, but it works
// So I thought I'd leave it in the project in case you want to play with it. :)
// Sorry for bad documentation. It's a bit of a mess. :/

#macro giga_inputs 10
#macro giga_outputs 2

// li_species
function gigaspecies(_max_population, _hidden_neurons = 12) constructor
{
	li_brains = ds_list_create()
	pri_brains = ds_priority_create()
	li_anaytics_fitness = ds_list_create()
	li_offspring = ds_list_create()
	max_population = _max_population
	kill_percentage_before_reproduction = choose(0.85, 0.75, 0.5, 0.25)
	kill_percentage_after_reproduction = choose(0, random_range(0, 0.9-kill_percentage_before_reproduction))
	intermingle_chance = choose(0, 0, 0.1)
	mutation_chance = choose(0.01, 0.05, 0.1, 0.2, 0.25, 0.3, 0.4, 0.5, 0.6, 0.75)
	generation = 0
	startconnections = choose(5, 10, 16, 22)
	referencebrain = new gigabrain(_hidden_neurons, startconnections)
	for(var o = 1; o < max_population; o++)
	{
		ds_list_add(li_brains, new gigabrain(_hidden_neurons, startconnections, referencebrain))
	}
		
	function KillAndReproduce()
	{
		generation++
		
		// Sort all brains by fitness
		ds_priority_clear(pri_brains)
		ds_list_clear(li_anaytics_fitness)
		for(br = 0; br < ds_list_size(li_brains); br++)
		{
			currentbr = li_brains[|br]
			ds_priority_add(pri_brains, currentbr, currentbr.fitness)
			ds_list_add(li_anaytics_fitness, currentbr.fitness)
		}
		ds_list_sort(li_anaytics_fitness, false)
		
		// Kill Weakest Before Reprocuding
		brain_kill_count_before_reproduction = ceil(ds_priority_size(pri_brains) * kill_percentage_before_reproduction)
		brain_kill_count_after_reproduction = ceil(ds_priority_size(pri_brains) * kill_percentage_after_reproduction)
		repeat(brain_kill_count_before_reproduction)
		{
			brain_to_kill = ds_priority_delete_min(pri_brains)
			ds_list_delete(li_brains, ds_list_find_index(li_brains, brain_to_kill))
			delete brain_to_kill
		}
		
		// Reprocude
		ds_list_clear(li_offspring)
		while(ds_list_size(li_offspring) < brain_kill_count_before_reproduction + brain_kill_count_after_reproduction)
		{
			parent1index = irandom_range(0, ds_list_size(li_brains)-1)
			parent2index = irandom_range(0, ds_list_size(li_brains)-1)
			child = Intermingle(li_brains[|parent1index], li_brains[|parent2index])
			ds_list_add(li_offspring, child)
		}
		
		// Kill Weakest After Reprocuding
		repeat(brain_kill_count_after_reproduction)
		{
			brain_to_kill = ds_priority_delete_min(pri_brains)
			ds_list_delete(li_brains, ds_list_find_index(li_brains, brain_to_kill))
			delete brain_to_kill
		}
		
		// Add offspring to the pool
		for(os = 0; os < ds_list_size(li_offspring); os++)
			ds_list_add(li_brains, li_offspring[|os])
			
		// Debug
		/*show_message("Brains List: " + string(ds_list_size(li_brains)))
		for(db = 0; db < ds_list_size(li_brains); db++)
			show_message(li_brains[|db])*/
		
	}
	
	function Intermingle(_parent1, _parent2)
	{
		cchild = new gigabrain(_parent1.hidden_neurons, 0)
		for(nrn = giga_inputs; nrn < cchild.neuroncount; nrn++)
		{
			neuronchild = cchild.li_neurons[|nrn]
			neuron1 = _parent1.li_neurons[|nrn]
			neuron2 = _parent2.li_neurons[|nrn]
			if (random(1) < intermingle_chance) // Intermingle both neurons:
			{
				for(con = 0; con < ds_list_size(neuron1.li_inputs); con++)
				{
					if (random(1) < 0.5)
					{
						ds_list_add(neuronchild.li_inputs, cchild.li_neurons[|neuron1.li_inputs[|con].index])
						ds_list_add(neuronchild.li_weights, neuron1.li_weights[|con])
					}
				}
				for(con = 0; con < ds_list_size(neuron2.li_inputs); con++)
				{
					if (random(1) < 0.5)
					{
						ds_list_add(neuronchild.li_inputs, cchild.li_neurons[|neuron2.li_inputs[|con].index])
						ds_list_add(neuronchild.li_weights, neuron2.li_weights[|con])
					}
				}
				neuronchild.AfterBirthCleanup()
			}
			else // Copy one or the other neuron fully:
			{
				if (random(1) < 0.5)
				{
					for(con = 0; con < ds_list_size(neuron1.li_inputs); con++)
					{
						ds_list_add(neuronchild.li_inputs, cchild.li_neurons[|neuron1.li_inputs[|con].index])
						ds_list_add(neuronchild.li_weights, neuron1.li_weights[|con])
					}
				}
				else
				{
					for(con = 0; con < ds_list_size(neuron2.li_inputs); con++)
					{
					
						ds_list_add(neuronchild.li_inputs, cchild.li_neurons[|neuron2.li_inputs[|con].index])
						ds_list_add(neuronchild.li_weights, neuron2.li_weights[|con])
					
					}
				}
			}
			
			// Small Weights Mutation
			if (random(1) < mutation_chance)
			{
				for(con = 0; con < ds_list_size(neuronchild.li_inputs); con++)
				{
					if random(1) < 0.5
						neuronchild.li_weights[|con] *= power(2, 1-random(2))
				}
			}
			
			// Large Weights Mutation
			if (random(1) < mutation_chance)
			{
				for(con = 0; con < ds_list_size(neuronchild.li_inputs); con++)
				{
					if random(1) < 0.25
						neuronchild.li_weights[|con] *= power(2, 5-random(10))
				}
			}
			
			// Delete Connection Mutation
			if (random(1) < mutation_chance)
			{
				for(con = ds_list_size(neuronchild.li_inputs)-1; con >= 0; con--)
				{
					if random(1) < 0.25
					{
						ds_list_delete(neuronchild.li_inputs, con)
						ds_list_delete(neuronchild.li_weights, con)
					}
				}
			}
			
			// Add Connection Mutation
			if (random(1) < mutation_chance)
			{
				repeat(choose(1,2))
				{
					connectto = irandom_range(0, neuronchild.index-1)
					ds_list_add(neuronchild.li_inputs, cchild.li_neurons[|connectto])
					ds_list_add(neuronchild.li_weights, random_range(-1, 1))
				}
				neuronchild.AfterBirthCleanup()
			}
			
			// Rewire Mutation
			if (random(1) < mutation_chance)
			{
				for(con = ds_list_size(neuronchild.li_inputs)-1; con >= 0; con--)
				{
					if random(1) < 0.25
					{
						connectto = irandom_range(0, neuronchild.index-1)
						neuronchild.li_inputs[|con] = cchild.li_neurons[|connectto]
					}
				}
			}
		}

		return cchild;
	}
}

// Brain
function gigabrain(_hidden_neurons, _start_connections, _referencebrain = undefined) constructor
{
	#macro inputoutput_type_regular 0
	#macro inputoutput_type_normalized 1
	inputoutput_type = inputoutput_type_normalized
	hidden_neurons = _hidden_neurons
	li_neurons = ds_list_create()
	neuroncount = giga_inputs + hidden_neurons + giga_outputs
	
	if is_undefined(_referencebrain)
	{
		for(var p = 0; p < giga_inputs; p++)
			ds_list_add(li_neurons, new giganeuron_linear(p))
	
		for(var p = giga_inputs; p < giga_inputs + hidden_neurons; p++)
		{
			if random(1) < 0.5
			{
				if random(1) < 0.33
					ds_list_add(li_neurons, new giganeuron_clamp(p))
				else if random(1) < 0.5
					ds_list_add(li_neurons, new giganeuron_linear(p))
				else
					ds_list_add(li_neurons, new giganeuron_multiply(p))
			}
			else
			{
				if random(1) < 0.33
					ds_list_add(li_neurons, new giganeuron_relu(p))
				else if random(1) < 0.5
					ds_list_add(li_neurons, new giganeuron_bool(p))
				else
					ds_list_add(li_neurons, new giganeuron_sin(p))
			}
		}
	
		for(var p = giga_inputs + hidden_neurons; p < giga_inputs + hidden_neurons + giga_outputs; p++)
			ds_list_add(li_neurons, new giganeuron_linear(p))
	}
	else
	{
		for(var p = 0; p < ds_list_size(_referencebrain.li_neurons); p++)
		{
			switch(_referencebrain.li_neurons[|p].typeID)
			{
				case typeID_linear:
					ds_list_add(li_neurons, new giganeuron_linear(p))
					break;
				case typeID_clamp:
					ds_list_add(li_neurons, new giganeuron_clamp(p))
					break;
				case typeID_null:
					ds_list_add(li_neurons, new giganeuron(p))
					break;
				case typeID_relu:
					ds_list_add(li_neurons, new giganeuron_relu(p))
					break;
				case typeID_sin:
					ds_list_add(li_neurons, new giganeuron_sin(p))
					break;
				case typeID_multiply:
					ds_list_add(li_neurons, new giganeuron_multiply(p))
					break;
				case typeID_bool:
					ds_list_add(li_neurons, new giganeuron_bool(p))
					break;
			}
		}
	}
		
	fitness = 0
	fitness_to_be_determined = true
	
	function add_connection(_aindex, _bindex, _wheight)
	{
		ds_list_add(li_neurons[|_bindex].li_inputs, li_neurons[|_aindex])
		ds_list_add(li_neurons[|_bindex].li_weights, _wheight)
	}
	
	// Initialize random connections:
	repeat(_start_connections)
	{
		endindex = giga_inputs + irandom_range(0, hidden_neurons + giga_outputs -1)
		startindex = irandom_range(0, endindex-1)
		add_connection(startindex, endindex, random_range(-1, 1))
	}
	for(var nrn = giga_inputs; nrn < neuroncount; nrn++)
	{
		li_neurons[|nrn].AfterBirthCleanup()
	}
	
	// Calculate outputs:
	function calculate()
	{
		for(calcstep = giga_inputs; calcstep < neuroncount; calcstep++)
		{
			li_neurons[|calcstep].calculate()
		}
	}
}


// Neuron Base
function giganeuron(_index) constructor
{
	#macro typeID_null 0
	typeID = typeID_null
	li_inputs = ds_list_create()
	li_weights = ds_list_create()
	val = 0
	index = _index
	
	function calculate()
	{
		val = 0
	}
	
	function AfterBirthCleanup()
	{
		for(var istart = ds_list_size(li_inputs)-1; istart >= 0; istart--)
		{
			var input = li_inputs[|istart]
			for(var i = istart-1; i >= 0; i--)
			{
				if li_inputs[|i] == input
				{
					if (random(1) < 0.5)
					{
						if (random(1) < 0.5)
							li_weights[|i] = li_weights[|i]
						else
							li_weights[|i] = li_weights[|istart]
					}
					else
					{
						if (random(1) < 0.5)
							li_weights[|i] = li_weights[|i] + li_weights[|istart]
						else
							li_weights[|i] = lerp(li_weights[|i], li_weights[|istart], random(1))
					}
					
					ds_list_delete(li_inputs, istart)
					ds_list_delete(li_weights, istart)
					break;
				}
			}
		}
	}
}

// Neuron Clamp
function giganeuron_clamp(_index) : giganeuron(_index) constructor
{
	#macro typeID_clamp 1
	typeID = typeID_clamp
	function calculate()
	{
		val = 0
		for(c = 0; c < ds_list_size(li_inputs); c++)
		{
			val += li_inputs[|c].val * li_weights[|c]
		}
		val = clamp(val, -1, 1)
	}
}

// Neuron Linear
function giganeuron_linear(_index) : giganeuron(_index) constructor
{
	#macro typeID_linear 2
	typeID = typeID_linear
	function calculate()
	{
		val = 0
		for(c = 0; c < ds_list_size(li_inputs); c++)
		{
			val += li_inputs[|c].val * li_weights[|c]
		}
	}
}

// Neuron Relu
function giganeuron_relu(_index) : giganeuron(_index) constructor
{
	#macro typeID_relu 3
	typeID = typeID_relu
	function calculate()
	{
		val = 0
		for(c = 0; c < ds_list_size(li_inputs); c++)
		{
			val += li_inputs[|c].val * li_weights[|c]
		}
		val = max(0, val)
	}
}

// Neuron Multiply
function giganeuron_multiply(_index) : giganeuron(_index) constructor
{
	#macro typeID_multiply 4
	typeID = typeID_multiply
	function calculate()
	{
		val = 1
		for(c = 0; c < ds_list_size(li_inputs); c++)
		{
			val *= li_inputs[|c].val * li_weights[|c]
		}
	}
}

// Neuron Bool
function giganeuron_bool(_index) : giganeuron(_index) constructor
{
	#macro typeID_bool 5
	typeID = typeID_bool
	function calculate()
	{
		val = 0
		for(c = 0; c < ds_list_size(li_inputs); c++)
		{
			val += li_inputs[|c].val * li_weights[|c]
		}
		val = (val > 0)
	}
}

// Neuron Sin
function giganeuron_sin(_index) : giganeuron(_index) constructor
{
	#macro typeID_sin 6
	typeID = typeID_sin
	function calculate()
	{
		val = 0
		for(c = 0; c < ds_list_size(li_inputs); c++)
		{
			val += li_inputs[|c].val * li_weights[|c]
		}
		val = sin(val)
	}
}