extends Node

@onready var my_controller: Control = get_parent()

var active_response_id: String
var response_dict: Dictionary
var general_themes: Array


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


func _on_generate_response_button_pressed() -> void:
	my_controller._switch_generate_button_disabled()
	var active_prompt_entry: Dictionary = my_controller.prompt_manager.active_prompt_entry
	var response_id = active_prompt_entry["Response"]
	var response_entry = response_dict[response_id]
	var prompt_goals: Array = active_prompt_entry["Goals"]
	my_controller._send_response_data(response_entry, prompt_goals)

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
