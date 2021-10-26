#!/usr/bin/bash
allIds=(1342 161 1023 1400 219 507 2413 4276 1399 6593 521 33 174 35 103 164 84 11 64317 2554 2130 145 140 1156 5135 18247)
allNames=(pride_and_prejudice sense_and_sensibility bleak_house great_expectations heart_of_darkness adam_bede madame_bovary north_and_south anna_karenina tom_jones robinson_crusoe scarlet_letter picture_of_dorian_grey the_time_machine around_the_world_in_80_days twenty_thousand_leagues_under_the_sea frankenstein alice_in_wonderland great_gatsby crime_and_punishment utopia middlemarch the_jungle babbit the_fortune_of_the_rougons the_last_man)

for i in ${!allIds[@]}; do
	id=${allIds[$i]}
	name=${allNames[$i]}
	name_raw_arg=${name}_raw.txt
	name_clean_arg=${name}_clean.txt
	python -m gutenberg.acquire.text $id $name_raw_arg
	python -m gutenberg.cleanup.strip_headers $name_raw_arg $name_clean_arg

done