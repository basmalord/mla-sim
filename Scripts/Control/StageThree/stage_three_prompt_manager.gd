extends Node

signal active_prompt_changed
signal active_prompt_entry_changed
signal level_defined

@onready var my_controller: Control = get_parent()


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


func _post_data_receipt_behaviour():
	if !is_level_defined:
		await level_defined
	_set_active_prompt("test_prompt_1")
	my_controller._send_prompt(active_prompt_entry)


func get_prompt_string(prompt_id: String):
	var prompt_string: String = prompt_dict[prompt_id]["PromptString"]
	return prompt_string

func get_prompt_theme_data_array(prompt_id: String):
	var theme_data_dict: Dictionary = prompt_dict[level][prompt_id]["Themes"]
	var theme_data_values_array: Array = []
	for theme in general_themes:
		theme_data_values_array.append(theme_data_dict.get("theme"))
	return theme_data_values_array

func _set_active_prompt(prompt_id: String):
	active_prompt_id = prompt_id
	active_prompt_entry = prompt_dict[level][active_prompt_id]

func _set_data_res(data: Dictionary):
	print("running")
	prompt_dict = data
	_post_data_receipt_behaviour()


func _set_general_themes():
	var example_key = prompt_dict.keys()[0]
	var example_entry: Dictionary = prompt_dict.get(example_key)
	var example_themes_dict: Dictionary = example_entry.get("Themes")
	general_themes = example_themes_dict.keys() #because all themes dicts will have the same keys in the same order
