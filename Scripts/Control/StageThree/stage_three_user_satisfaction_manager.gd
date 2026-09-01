extends Control

@onready var my_rtl: RichTextLabel = $USRTL
@onready var my_controller: Control = get_parent()
var previous_values: Array[float] #must remember to reset this when send is pressed
@export_range(0.4,1,0.01) var positive_flash_timer: float = 0.5
@export_range(0.4,1,0.01) var negative_flash_timer: float = 0.5
@export_range(0,2,0.1) var flash_length: float = 2.5
@export var positive_flash_colour: Color = Color(0.161, 0.824, 0.157, 1.0)
@export var negative_flash_colour: Color = Color(0.933, 0.533, 0.251, 1.0)

func _negative_indication_behaviour():
	_flash_button("negative")
	my_controller._play_success()

func _positive_indication_behaviour():
	_flash_button("positive")
	my_controller._play_failure()

func _alter_shadow_outline(value: int, target_rtl: RichTextLabel = my_rtl):
	target_rtl.add_theme_constant_override("shadow_outline_size", value)

func _flash_button(behaviour: String, node_to_flash: Node = my_rtl):
	var original_colour: Color = node_to_flash.get_self_modulate()
	match behaviour:
		"positive":
			node_to_flash.add_theme_color_override("font_shadow_color", positive_flash_colour)
			var timer = get_tree().create_timer(flash_length)
			while timer.time_left > 0:
				await get_tree().create_timer(positive_flash_timer).timeout
				var font_tween = create_tween()
				var shadow_tween = create_tween()
				shadow_tween.tween_method(_alter_shadow_outline, 1, 5 , positive_flash_timer)
				font_tween.tween_property(node_to_flash, "modulate", positive_flash_colour, positive_flash_timer)
				font_tween.tween_property(node_to_flash, "modulate", original_colour, positive_flash_timer)
				await get_tree().process_frame
		"negative":
			node_to_flash.add_theme_color_override("font_shadow_color", negative_flash_colour)
			var timer = get_tree().create_timer(flash_length)
			while timer.time_left > 0:
				await get_tree().create_timer(positive_flash_timer).timeout
				var tween = create_tween()
				var shadow_tween = create_tween()
				shadow_tween.tween_method(_alter_shadow_outline, 1, 5 , negative_flash_timer)
				tween.tween_property(node_to_flash, "modulate", negative_flash_colour, negative_flash_timer)
				tween.tween_property(node_to_flash, "modulate", original_colour, negative_flash_timer)
				await get_tree().process_frame
	node_to_flash.add_theme_color_override("font_shadow_color", Color(0.161, 0.824, 0.157, 0.0))

func _display_last_value():
	previous_values.pop_back()
	var display_value
	if previous_values.size() == 0:
		display_value = 0
	else:
		display_value = previous_values.back() * 100
	var display_string_value: String = str(display_value) + "%"
	my_rtl.text = str(display_string_value)

func _display_new_user_satisfaction(goals_tally: Dictionary):
	var estimated_value: float = generate_estimated_satisfaction()
	previous_values.append(estimated_value)
	var display_value = estimated_value * 100
	var display_string_value: String = str(display_value) + "%"
	my_rtl.text = str(display_string_value)
	if previous_values.size() == 1:
		_positive_indication_behaviour()
	else:
		var last_value: float = previous_values[previous_values.size() - 2]
		var last_display_value: int = last_value * 100
		if last_display_value < display_value:
			_positive_indication_behaviour()
		elif last_display_value > display_value:
			_negative_indication_behaviour()

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
