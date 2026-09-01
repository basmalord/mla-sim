extends Node

@onready var my_controller: Control = get_parent()

var active_response_id: String = ""
var response_dict: Dictionary
var general_themes: Array
var active_response_entry: Dictionary
var prompt_goals: Array

func _post_data_receipt_behaviour():
	pass

func get_response_string(response_id: String):
	var response_string: String = response_dict[response_id]["ResponseString"]
	return response_string

func get_response_theme_data_array(response_id: String):
	var theme_data_dict: Dictionary = response_dict[response_id]["Themes"]
	var theme_data_values_array: Array = []
	for theme in general_themes:
		theme_data_values_array.append(theme_data_dict.get("Theme"))
	return theme_data_values_array

func get_next_prompt():
	var next_prompt_id: String = active_response_entry["NextPrompt"]
	return next_prompt_id

func _on_generate_response_button_pressed() -> void:
	my_controller._switch_generate_button_disabled()
	if active_response_id == "":
		var active_prompt_entry: Dictionary = my_controller.prompt_manager.active_prompt_entry
		var active_goal: String = my_controller.selected_goal
		var response_id: String = ""
		if active_prompt_entry.keys().has("Goals") == false:
			my_controller.input_sounds._play_sound_by_id("keyboard_button", true)
			my_controller.begin_tutorial_sequence()
			return
		my_controller.input_sounds._play_sound_by_id("keyboard_button")
		for entry in active_prompt_entry["Goals"]:
			if entry.keys()[0] == active_goal:
				response_id = entry[active_goal]
		if response_id == "":
			print("ERROR: RESPONSE MANAGER CANNOT FIND SELECTED GOAL IN RESPONSE SECTIONS DICT", active_goal)
			return
		print("this is resp id: ", response_id)
		active_response_entry = response_dict[response_id]
		prompt_goals = active_prompt_entry["Goals"]
		my_controller._send_response_data(active_response_entry, prompt_goals)
		var goals_array: Array[String]
		for entry in prompt_goals:
			goals_array.append(entry.keys()[0])
		my_controller._receive_goals(prompt_goals, 1, true)
		active_response_id = response_id
	else:
		my_controller.input_sounds._play_sound_by_id("keyboard_button")
		my_controller._send_response_data(active_response_entry, prompt_goals)
		var sections: int = active_response_entry["ResponseSections"].size()
		my_controller._receive_goals(prompt_goals, sections)
		print("this is else on gen pressed: ", prompt_goals, "   ", sections)
	


func _select_response():
	pass

func _set_active_response(response_id: String):
	active_response_id = response_id

func _set_data_res(data: Dictionary):
	response_dict = data
	_post_data_receipt_behaviour()

func _set_general_themes():
	var example_key = response_dict.keys()[0]
	var example_entry: Dictionary = response_dict.get(example_key)
	var example_themes_dict: Dictionary = example_entry.get("Themes")
	general_themes = example_themes_dict.keys() #because all themes dicts will have the same keys in the same order


#Todo: write strcuture / logic for response producing next prompt ; and strcture for prompt producing the array of responses
