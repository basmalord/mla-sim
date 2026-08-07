extends GridContainer

@onready var my_controller: Node = get_parent()

var active_column: int = 0

@export_enum("Row1","Row2","Row3","Row4","Row5",) var active_row: String = "Row1"

@export var row_dict: Dictionary[String, Array] = {"Row1": [], "Row2": [], "Row3": [], "Row4": [], "Row5": []}
@export var style_correct: StyleBoxFlat
@export var style_incorrect: StyleBoxFlat
@export var style_partial: StyleBoxFlat
@export var style_nothing: StyleBoxFlat
func _ready() -> void:
	pass

func _set_row_themes(correctness_array: Array[String], reset_all: bool = false):
	if !reset_all:
		var row_dict_active_array: Array = row_dict[active_row]
		for i in 5:
			var button_node = get_node(row_dict_active_array[i])
			var button_theme: String = correctness_array[i]
			_set_button_theme(button_node, button_theme)
			print(correctness_array, button_node.text, button_theme)
	else:
		for child in get_children():
			child.add_theme_stylebox_override("normal", style_nothing)
			child.add_theme_stylebox_override("hover", style_nothing)
			child.add_theme_stylebox_override("hover_mirrored", style_nothing)
			child.add_theme_stylebox_override("hover_pressed", style_nothing)
			child.add_theme_stylebox_override("hover_pressed_mirrored", style_nothing)
			child.add_theme_stylebox_override("pressed", style_nothing)

func _set_button_theme(button_node: Button, theme_string: String):
	match theme_string:
		"correct":
			button_node.add_theme_stylebox_override("normal", style_correct)
			button_node.add_theme_stylebox_override("hover", style_correct)
			button_node.add_theme_stylebox_override("hover_mirrored", style_correct)
			button_node.add_theme_stylebox_override("hover_pressed", style_correct)
			button_node.add_theme_stylebox_override("hover_pressed_mirrored", style_correct)
			button_node.add_theme_stylebox_override("pressed", style_correct)
		"incorrect":
			button_node.add_theme_stylebox_override("normal", style_incorrect)
			button_node.add_theme_stylebox_override("hover", style_incorrect)
			button_node.add_theme_stylebox_override("hover_mirrored", style_incorrect)
			button_node.add_theme_stylebox_override("hover_pressed", style_incorrect)
			button_node.add_theme_stylebox_override("hover_pressed_mirrored", style_incorrect)
			button_node.add_theme_stylebox_override("pressed", style_incorrect)
		"partial":
			button_node.add_theme_stylebox_override("normal", style_partial)
			button_node.add_theme_stylebox_override("hover", style_partial)
			button_node.add_theme_stylebox_override("hover_mirrored", style_partial)
			button_node.add_theme_stylebox_override("hover_pressed", style_partial)
			button_node.add_theme_stylebox_override("hover_pressed_mirrored", style_partial)
			button_node.add_theme_stylebox_override("pressed", style_partial)
		_:
			pass

func _set_active_row_string(letter: String):
	if active_row == "Row6" or active_row == "Row7" or active_row == "Row8":
		return
	var current_row_string: String = get_active_row_string()
	if current_row_string.is_empty():
		return
	var char_index: int = current_row_string.find("_")
	if char_index == -1:
		return
	var blank_number: int = 0
	for index in 5: #5 is the const word length so we good here
		if current_row_string[index] == "_":
			blank_number += 1
	var new_row_string = current_row_string.erase(char_index, blank_number)
	new_row_string += letter
	blank_number -= 1
	for blanks in blank_number:
		new_row_string += "_"
	for button in row_dict[active_row]:
		var index = row_dict[active_row].find(button)
		get_node(button).text = new_row_string[index]
	my_controller.audio_manager._play_sound_by_id("keyboard_button")

func _remove_last_letter():
	if my_controller.correct_given or my_controller.last_guess_wrong:
		return
	var current_row_string: String = get_active_row_string()
	if current_row_string == "_____":
		return
	var blank_number: int = 0
	while current_row_string[current_row_string.length() - 1] == "_":
		blank_number += 1
		current_row_string = erase_char(current_row_string, current_row_string.length() - 1)
	current_row_string = erase_char(current_row_string, current_row_string.length() - 1)
	for blank in blank_number + 1:
		current_row_string += "_"
	for button in row_dict[active_row]:
		var index = row_dict[active_row].find(button)
		get_node(button).text = current_row_string[index]
	my_controller.audio_manager._play_sound_by_id("back_button")

func erase_char(text: String, index: int) -> String:
	if index < 0 or index >= text.length():
		return text
	return text.substr(0, index) + text.substr(index + 1)

func get_active_row_string() -> String:
	if active_row == "Row6" or active_row == "Row7" or active_row == "Row8":
		return ""
	var row: Array = row_dict[active_row]
	var row_string: String = ""
	for button in row:
		var char = get_node(button).text
		row_string += char
	return row_string

func _reset():
	active_row = "Row1"
	for child in get_children():
		child.text = "_"

func _set_active_row():
	var row_int = int(active_row[3])
	row_int += 1
	var row_str = str(row_int)
	active_row = "Row" + row_str #Need something to tell when active row is past 5 in order to being restart process
