extends Node

signal goal_added

@onready var my_controller: Control = get_parent()

var goals_tally: Dictionary
var last_goals: Array[String]

func _reset_goals_tally():
	goals_tally.clear()

func _add_goal_tally(goal: String):
	last_goals.append(goal)
	if goals_tally.has(goal):
		var value: int = goals_tally[goal] 
		value += 1
		goals_tally[goal] = value
		emit_signal("goal_added")
		return
	goals_tally[goal] = 1
	emit_signal("goal_added")

func _call_satisfaction_manager():
	my_controller.user_satisfaction_manager._display_last_value()

func _call_goals_manager(last_goal: String):
	var bespoke_tally: Dictionary = {"Sections": 1, last_goal: 0}
	my_controller.user_goals_manager._handle_goals(bespoke_tally)
	get_tree().create_timer(0.06).timeout
	_call_satisfaction_manager()

func _remove_goal_tally():
	var last_goal = last_goals.back()
	last_goals.pop_back()
	var value: int = goals_tally[last_goal] 
	value -= 1
	if value < 0:
		value = 0
	goals_tally[last_goal] = value
	_call_goals_manager(last_goal)
	
