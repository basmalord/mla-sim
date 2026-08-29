extends Node

signal active_prompt_changed
signal active_prompt_entry_changed
signal level_defined
signal engineer_prompt_set

@onready var my_controller: Control = get_parent()
@onready var passive_prompt_handler: PassivePromptHandler = $PassivePromptHandler
@onready var engineer_prompt_handler: EngineerPromptHandler = $EngineerPromptHandler


var active_prompt_id: String
var active_prompt_entry: Dictionary
var general_themes: Array
var is_level_defined: bool = false
var level: String
var prompt_dict: Dictionary



func _ready() -> void:
	level = str(my_controller.level)
	emit_signal("level_defined")
	is_level_defined = true

func get_engineering_prompt_entry():
	var engineering_prompt_id: String = active_prompt_entry["UserSatisfaction"]["FailurePromptID"] 
	#var engineering_prompt_entry: Dictionary = engineer_prompt_handler.engineer_prompt_dict[engineering_prompt_id]
	return engineering_prompt_id

func get_end_day_bool():
	return active_prompt_entry["EndDay"] 

func get_time_to_add(): #returns 2 int in an array: minutes, then hours
	var time_to_add_dict: Dictionary = active_prompt_entry["Time"]
	var time_to_add_minutes: int = time_to_add_dict["MinutesToPass"]
	var time_to_add_hours: int = time_to_add_dict["HoursToPass"]
	var hours_in_minutes: int = time_to_add_hours * 60
	time_to_add_minutes += hours_in_minutes
	return time_to_add_minutes

func _generate_passive_prompt(acceptability: String, chosen_words_array: Array[Dictionary], response_id: String, response_section_id: String, chosen_words_acceptability_array: Array[Dictionary]):
	var passive_prompt_string_to_send: String = passive_prompt_handler._generate_passive_prompt(acceptability, chosen_words_array, response_id, response_section_id)
	my_controller._send_passive_prompt(passive_prompt_string_to_send)

func _post_data_receipt_behaviour():
	if !is_level_defined:
		await level_defined
	var next_prompt_id: String = ""
	if !active_prompt_entry.is_empty():
		next_prompt_id = active_prompt_entry["NextPromptID"]
	if !prompt_dict.has(next_prompt_id):
		_set_active_prompt("test_prompt_1")
	else:
		_set_active_prompt(next_prompt_id)
	my_controller._send_prompt(active_prompt_entry)

func _launch_new_prompt(from_failure: bool = false):
	#check end day, if not, do the following:
	if !from_failure:
		var next_prompt_id: String = active_prompt_entry["NextPromptID"]
		_set_active_prompt(next_prompt_id)
		my_controller._send_prompt(active_prompt_entry)
	else:
		var next_prompt_id: String = get_engineering_prompt_entry()
		_set_active_prompt(next_prompt_id, true)
		my_controller._send_prompt(active_prompt_entry, true)

func get_prompt_string(prompt_id: String):
	var prompt_string: String = prompt_dict[prompt_id]["PromptString"]
	return prompt_string

func get_prompt_theme_data_array(prompt_id: String):
	var theme_data_dict: Dictionary = prompt_dict[level][prompt_id]["Themes"]
	var theme_data_values_array: Array = []
	for theme in general_themes:
		theme_data_values_array.append(theme_data_dict.get("theme"))
	return theme_data_values_array

func _set_active_prompt(prompt_id: String, from_failure: bool = false):
	if !from_failure:
		active_prompt_id = prompt_id
		active_prompt_entry = prompt_dict[level][active_prompt_id] #could do some crash check here for if the dict doesnt have
	else:
		active_prompt_id = prompt_id
		active_prompt_entry = engineer_prompt_handler.engineer_prompt_dict[prompt_id]

func _set_data_res(data: Dictionary):
	prompt_dict = data
	_post_data_receipt_behaviour()


func _set_general_themes():
	var example_key = prompt_dict.keys()[0]
	var example_entry: Dictionary = prompt_dict.get(example_key)
	var example_themes_dict: Dictionary = example_entry.get("Themes")
	general_themes = example_themes_dict.keys() #because all themes dicts will have the same keys in the same order
