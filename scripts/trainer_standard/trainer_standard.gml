
// Trainer
function gigatrainer(_startSpecies, _startli_brainsPerSpeies) constructor
{
	startli_brainsPerSpeies = _startli_brainsPerSpeies
	startSpecies = _startSpecies
	li_species = ds_list_create()
	for(var i = 0; i < _startSpecies; i++)
		ds_list_add(li_species, new gigaspecies(startli_brainsPerSpeies))
		
	// Add a simple follow AI to the kingslist
	game = new broink_game()
	cacheP1 = game.player1
	cacheP2 = game.player2
	li_kings = ds_list_create()
	
	// Add two simple enemies to train against:
	donothingAI = new gigabrain(0, 0)
	ds_list_add(li_kings, donothingAI)
	justaimatenemyAI = new gigabrain(0, 0)
	justaimatenemyAI.add_connection(3, 10, 100)
	justaimatenemyAI.add_connection(1, 10, -100)
	justaimatenemyAI.add_connection(4, 11, 100)
	justaimatenemyAI.add_connection(2, 11, -100)
	ds_list_add(li_kings, justaimatenemyAI)
	
	bestcontender = li_species[|0].li_brains[|0]
	bestcontender_score = -1000000000
	turns_till_king_is_saved = -1
	turns_till_new_attempt_is_started = 200
		
	function NextGeneration()
	{
		// Each gigabrain must go up against the kingslist to recieve a score
		average_score = 0
		for(sp = 0; sp < ds_list_size(li_species); sp++)
		{
			currentsp = li_species[|sp]
			for(br = 0; br < ds_list_size(currentsp.li_brains); br++)
			{
				currentbr = currentsp.li_brains[|br]
				if (!currentbr.fitness_to_be_determined)
				{
					average_score += currentbr.fitness
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
					for(startsleft = 0; (startsleft <= 0) and currentbr_victory; startsleft++) // Mirror matches currently disabled due to symmetric training
					{
						game.Reset()
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
						if (currentbr_victory)
							currentbr.fitness += 2000
						else
							currentbr.fitness -= game.time
						//currentbr.fitness += game.time * (currentbr_victory ? 1 : -1)  +100*currentbr_victory
					}
				}
				
				currentbr.fitness_to_be_determined = false
				average_score += currentbr.fitness
				if (currentbr.fitness > bestcontender_score)
				{
					turns_till_new_attempt_is_started = 200
					bestcontender_score = currentbr.fitness
					bestcontender = currentbr
					if currentbr_victory
					{
						audio_play_sound(sou_badum, 0.1, false, 0.25)
						turns_till_king_is_saved = 2 // << Currently diabled due to new traing method
						// New King has been crowned
					}
				}
			}
		}
		
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
		}
		
		average_score /= ds_list_size(currentsp.li_brains)
		
		// Each species should eliminate the worst contenders and reproducify
		for(sp = 0; sp < ds_list_size(li_species); sp++)
		{
			currentsp = li_species[|sp]
			currentsp.KillAndReproduce()
		}
		

	}
}