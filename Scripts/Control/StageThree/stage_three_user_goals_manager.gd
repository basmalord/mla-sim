extends Node

signal goals_handled

@export_range(0.00,1,0.01) var appreciation_rate: float  = 0.15
@export_range(0.00,1,0.01) var depreciation_rate: float
@export var user_goals_dict: Dictionary

func _handle_goals(goals_tally: Dictionary): #so, on erase, just send a dict with sections 1 and the last goal to reverse
	var number_of_sections: int = goals_tally["Sections"]
	goals_tally.erase("Sections")
	for goal in goals_tally:
		var selected: int = goals_tally[goal]
		var not_selected: int = number_of_sections - selected
		for i in selected:
			_add_key_value_pair_to_user_goals_dict(goal, true)
		for i in not_selected:
			_add_key_value_pair_to_user_goals_dict(goal)
	emit_signal("goals_handled")


func _add_key_value_pair_to_user_goals_dict(key: String, selected: bool = false, value: float = appreciation_rate): #want it so that the response generation makes a tally of goal to selected
#then when it hits send it sends that tally here
	if user_goals_dict.has(key):
		_amend_key_value(key)
		return
	user_goals_dict[key] = value

func _amend_key_value(key: String, selected: bool = false):
	var current_value: float = user_goals_dict[key]
	if selected:
		current_value += appreciation_rate
	else:
		current_value -= appreciation_rate
	if current_value > 1:
		current_value = 1
	elif current_value < -1:
		current_value = -1
	user_goals_dict[key] = current_value
