extends Control

@onready var my_rtl: RichTextLabel = $USRTL
@onready var my_controller: Control = get_parent()
var previous_values: Array[float] #must remember to reset this when send is pressed


func _display_last_value():
	previous_values.pop_back()
	my_rtl.text = str(previous_values.back())

func _display_new_user_satisfaction(goals_tally: Dictionary):
	var estimated_value: float = generate_estimated_satisfaction()
	previous_values.append(estimated_value)
	my_rtl.text = str(estimated_value)

#func generate_estimated_satisfaction(goals_tallyg: Dictionary):
	#var goals_tally: Dictionary = my_controller.goal_tally_controller.goals_tally
	#var my_user_estimated_data: Dictionary = my_controller.user_goals_manager.user_goals_dict.duplicate()
	#var goals_array: Array[String]
	#var estimated_goal_values: Array[float]
	#goals_tally.erase("Sections")
	#for goal in goals_tally:
		#goals_array.append(goal)
		#if my_user_estimated_data.has(goal):
			#estimated_goal_values.append(my_user_estimated_data[goal])
	#if estimated_goal_values.size() != goals_tally.size():
		#print("ERROR: USER GOALS MANAGER DOES NOT CONTAIN GOAL FOR ESTIMATION GENERATION")
		#return
	#var cumulative_estimated_value: float = 0.00
	#for value in estimated_goal_values:
		#cumulative_estimated_value += value
	#var proportions_of_cumulative_value: Array[float] #making an array of proprtions, to know how much est value each tally will represent
	#for value in estimated_goal_values:
		#var proportion: float = value / cumulative_estimated_value
		#proportions_of_cumulative_value.append(proportion)
	#var cumulative_value_by_proportion: float = 0.00
	#for index in proportions_of_cumulative_value.size():
		#var value: float = proportions_of_cumulative_value[index]
		#var target_goal: String = goals_array[index]
		#var tally_amount: int = goals_tally[target_goal]
		#var goal_value: float = value * tally_amount
		#cumulative_value_by_proportion += goal_value
	#var difference: float = abs(cumulative_estimated_value - cumulative_value_by_proportion)
	#return difference

func generate_estimated_satisfaction():
	var goals_tally: Dictionary = my_controller.goal_tally_controller.goals_tally.duplicate()
	print("this is goal tally: ", goals_tally)
	var my_user_estimated_data: Dictionary = my_controller.user_goals_manager.user_goals_dict
	print("this is my user estimated data: ", my_user_estimated_data)
	var goals_array: Array[String] = []
	var estimated_goal_values: Array[float] = []
	for goal in goals_tally: #populating the estimated data from the tally into useable arrays
		if my_user_estimated_data.has(goal):
			goals_array.append(goal)
			estimated_goal_values.append(my_user_estimated_data[goal])
		else:
			print("ERROR: USER GOALS MANAGER DOES NOT CONTAIN GOAL FOR ESTIMATION GENERATION: ", goal)
			return
	# Calculate total estimated importance
	var cumulative_estimated_value: float = 0.0
	for value in estimated_goal_values:
		cumulative_estimated_value += value
	# Calculate total actual tally
	var cumulative_tally: int = 0
	for goal in goals_array:
		cumulative_tally += goals_tally[goal]
	# Compare expected vs actual proportions
	var difference: float = 0.0
	for index in goals_array.size():
		var goal: String = goals_array[index]
		var expected_proportion: float = estimated_goal_values[index] / cumulative_estimated_value
		var actual_proportion: float = float(goals_tally[goal]) / cumulative_tally
		difference += abs(expected_proportion - actual_proportion)
	var satisfaction: float = 1.0 - (difference / 2.0)
	return satisfaction
