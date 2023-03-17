
// Trainer
function gigatrainer_multispecies(_startSpecies, _startli_brainsPerSpeies) constructor
{
	startli_brainsPerSpeies = _startli_brainsPerSpeies
	startSpecies = _startSpecies
	li_species = ds_list_create()
	li_species_beaten_kings = ds_list_create()
	species_beaten_kings_amount = 0
	for(var i = 0; i < _startSpecies; i++)
	{
		ds_list_add(li_species, new gigaspecies(startli_brainsPerSpeies))
		ds_list_add(li_species_beaten_kings, false)
	}
		
	// Add a simple follow AI to the kingslist
	game = new broink_game()
	cacheP1 = game.player1
	cacheP2 = game.player2
	li_kings = ds_list_create()
	
	// Add the Ai that aims directly at you as a first king
	/*justaimatenemyAI = new gigabrain(0, 0)
	justaimatenemyAI.add_connection(3, 10, 100)
	justaimatenemyAI.add_connection(1, 10, -100)
	justaimatenemyAI.add_connection(4, 11, 100)
	justaimatenemyAI.add_connection(2, 11, -100)
	justaimatenemyAI.inputoutput_type = inputoutput_type_regular*/
	justaimatenemyAI = loadbrain("King 1.txt")
	ds_list_add(li_kings, justaimatenemyAI)
	
	bestcontender = li_species[|0].li_brains[|0]
	bestcontender_score = -1000000000
	turns_till_new_attempt_is_started = 200
	currently_proccessing_species = 0
	nowgen = 0
		
	function NextGeneration()
	{
		if (currently_proccessing_species == 0)
			nowgen++
		// Each gigabrain must go up against the kingslist to recieve a score
		currently_proccessing_species = (currently_proccessing_species + 1) mod ds_list_size(li_species)
		
		currentsp = li_species[|currently_proccessing_species]
		for(br = 0; br < ds_list_size(currentsp.li_brains); br++)
		{
			currentbr = currentsp.li_brains[|br]
			if (!currentbr.fitness_to_be_determined)
			{
				if (currentbr.fitness > bestcontender_score)
				{
					bestcontender_score = currentbr.fitness
					bestcontender = currentbr
				}
				continue;
			}
					
			currentbr_victory = true
			currentbr.fitness = 0
			for(ki = ds_list_size(li_kings)-1; (ki >= 0) and currentbr_victory; ki--)
			{
				kingbr = li_kings[|ki]
				startsleft = 0;
				
				game.Reset()
				//cacheP1.xspeed = 1 - random(2)
				//cacheP1.yspeed = 1 - random(2)
				leftpl = startsleft ? currentbr : kingbr
				rightpl = startsleft ? kingbr : currentbr
				while(game.game_state == game_state_ongoing)
				{
					set_gigabrain_inputs_for_gamestate_black(leftpl, game)
					set_gigabrain_inputs_for_gamestate_white(rightpl, game)
					leftpl.calculate()
					rightpl.calculate()
					cacheP1.xinput = get_gigabrain_output_x(leftpl, cacheP1)
					cacheP1.yinput = get_gigabrain_output_y(leftpl, cacheP1)
					cacheP2.xinput = get_gigabrain_output_x(rightpl, cacheP2)
					cacheP2.yinput = get_gigabrain_output_y(rightpl, cacheP2)
					game.Step()
				}
				currentbr_victory = (game.game_state == (startsleft ? game_state_p1_wins : game_state_p2_wins))
				currentbr.fitness += game.time * (currentbr_victory ? 1 : -1)  +100*currentbr_victory
			}
				
			currentbr.fitness_to_be_determined = false
			if currentbr_victory
			{
				// An AI managed to beat all previous kings
				if li_species_beaten_kings[|currently_proccessing_species] == false
				{	
					li_species_beaten_kings[|currently_proccessing_species] = true
					species_beaten_kings_amount++
				}
			}
			if (currentbr.fitness > bestcontender_score) // New highscore
			{
				turns_till_new_attempt_is_started = 200
				bestcontender_score = currentbr.fitness
				bestcontender = currentbr
				audio_play_sound(sou_badum, 0.1, false, 0.25)
			}
		}
		// After evaluation kill and reproduce:
		currentsp.KillAndReproduce()
		
		// Enough species managed to beat all previsou kings so time to TOURNAMENT against each other:
		if (species_beaten_kings_amount >= startSpecies * 0.7) and (nowgen >= 50)
		{
			for(var i = 0; i < ds_list_size(li_species_beaten_kings); i++)
			{
				li_species_beaten_kings[|i] = 0
			}
			for(sspecA = 0; sspecA < ds_list_size(li_species); sspecA++)
			{
				currentspA = li_species[|sspecA]
				for(sspecB = 0; sspecB < ds_list_size(li_species); sspecB++)
				{
					currentspB = li_species[|sspecB]
					
					leftpl = ds_priority_find_max(currentspA.pri_brains)
					rightpl = ds_priority_find_max(currentspB.pri_brains)
					game.Reset()

					while(game.game_state == game_state_ongoing)
					{
						set_gigabrain_inputs_for_gamestate_black(leftpl, game)
						set_gigabrain_inputs_for_gamestate_white(rightpl, game)
						leftpl.calculate()
						rightpl.calculate()
						cacheP1.xinput = get_gigabrain_output_x(leftpl, cacheP1)
						cacheP1.yinput = get_gigabrain_output_y(leftpl, cacheP1)
						cacheP2.xinput = get_gigabrain_output_x(rightpl, cacheP2)
						cacheP2.yinput = get_gigabrain_output_y(rightpl, cacheP2)
						game.Step()
					}
					
					li_species_beaten_kings[|sspecA] += (10000 + game.time) * (game.game_state == game_state_p1_wins)
					li_species_beaten_kings[|sspecB] += (10000 + game.time) * (game.game_state == game_state_p2_wins)
				}
			}
			tournament_best_score = 0
			tournament_winner = ds_priority_find_max(li_species[|0].pri_brains)
			for(var i = 0; i < ds_list_size(li_species_beaten_kings); i++)
			{
				if li_species_beaten_kings[|i] > tournament_best_score
				{
					tournament_best_score = li_species_beaten_kings[|i]
					tournament_winner = ds_priority_find_max(li_species[|i].pri_brains)
				}
			}
			savebrain(tournament_winner, "King "+string(ds_list_size(li_kings)+1)+".txt")
			audio_play_sound(sou_matchover, 0.5, false, 0.75)
			ds_list_add(li_kings, tournament_winner)
				
			ds_list_clear(li_species)
			for(var i = 0; i < startSpecies; i++)
				ds_list_add(li_species, new gigaspecies(startli_brainsPerSpeies))
					
			bestcontender = li_species[|0].li_brains[|0]
			bestcontender_score = -1000000000
			currently_proccessing_species = 0
			nowgen = 0
			species_beaten_kings_amount = 0

			for(var i = 0; i < ds_list_size(li_species_beaten_kings); i++)
			{
				li_species_beaten_kings[|i] = 0
			}
		}
		
		
		
		/*
		if (turns_till_king_is_saved >= 0)
		{
			turns_till_king_is_saved--
			if (turns_till_king_is_saved == -1)
			{
				savebrain(bestcontender, "King "+string(ds_list_size(li_kings)+1)+".txt")
				audio_play_sound(sou_matchover, 0.5, false, 0.75)
				ds_list_add(li_kings, bestcontender)
				
				ds_list_clear(li_species)
				for(var i = 0; i < startSpecies; i++)
					ds_list_add(li_species, new gigaspecies(startli_brainsPerSpeies))
					
				bestcontender = li_species[|0].li_brains[|0]
				bestcontender_score = -1000000000
				turns_till_king_is_saved = -1
				turns_till_new_attempt_is_started = 200
			}
		}
		else if (turns_till_new_attempt_is_started >= 0)
		{
			turns_till_new_attempt_is_started--
			if (turns_till_new_attempt_is_started == -1)
			{
				savebrain(bestcontender, "Failed King "+string(ds_list_size(li_kings)+1)+".txt")
				audio_play_sound(sou_balldrop2, 0.5, false, 0.75)
				
				ds_list_clear(li_species)
				for(var i = 0; i < startSpecies; i++)
					ds_list_add(li_species, new gigaspecies(startli_brainsPerSpeies))
					
				bestcontender = li_species[|0].li_brains[|0]
				bestcontender_score = -1000000000
				turns_till_king_is_saved = -1
				turns_till_new_attempt_is_started = 200
			}
		}*/
		
		

	}
}