extends Node

@export_range(0.00,1.00,0.01) var immediate_to_long_run_scale: float = 0.10
@export_range(1,10,1) var new_goal_multiplier: int = 3

var user_dict: Dictionary


func _set_data_res(data):
	user_dict = data

func _augment_user_goals(user_name: String, goal_name: String, goal_value: float):
	if !user_dict.has(user_name):
		return
	var user_entry: Dictionary = user_dict[user_name].duplicate()
	var new_value: float
	if user_entry["goals"].has(goal_name):
		var old_value: float = user_entry["goals"][goal_name]
		new_value = old_value + (goal_value * immediate_to_long_run_scale)
	else:
		new_value = goal_value * immediate_to_long_run_scale * new_goal_multiplier
	user_entry["goals"][goal_name] = new_value
	user_dict[user_name] = user_entry
