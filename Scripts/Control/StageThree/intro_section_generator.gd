extends Node

@export var intro_string_entries: Array[Dictionary] #These are always something like: 'Ah, I get you, you want to:'
@export var intro_part_two_string_array: Array[String] #These are awlways something like: 'Sounds totally doable, we got this!'


func generate_intro_string(goals: Array) -> String:
	var string_entries_size: int = intro_string_entries.size() - 1
	var random_index: int = randi_range(0,string_entries_size)
	var selected_string_entry: Dictionary = intro_string_entries[random_index]
	var selected_string = selected_string_entry.keys()[0]
	var goals_string: String = generate_goals_string(goals)
	random_index = randi_range(0,intro_part_two_string_array.size() - 1)
	var part_two_string: String = intro_part_two_string_array[random_index]
	var output_string: String = selected_string + " " + goals_string + " " + part_two_string
	return output_string


func generate_goals_string(goals: Array) -> String:
	var goals_size: int = goals.size()
	var last_index: int = goals_size - 1
	var goals_string: String = ""
	var goal_modified: String
	var punctuation_array: Array[String] = [".","!"]
	for index in goals_size:
		var goal: String = goals[index].keys()[0]
		if index == 0:
			goals_string += goal
			if index == last_index:
				goals_string += punctuation_array[randi_range(0,1)]
			continue
		if index == last_index:
			goal_modified = ", and " + goal + punctuation_array[randi_range(0,1)]
			goals_string += goal_modified
			continue
		goal_modified = ", " + goal
		goals_string += goal_modified
	return goals_string
