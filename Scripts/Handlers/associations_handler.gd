extends Node

var my_controller: Control

@export var word_dict_path: String

var active_themes: Array[String]
var word_dict: Dictionary
var themes_dict_template: Dictionary = {"Themes":
{"city": 0.00,
"children": 0.00,
"men": 0.00,
"violence": 0.00,
"water": 0.00,
"death": 0.00,
"evil": 0.00,
"work": 0.00,
"travel": 0.00,
"wealth": 0.00,
"poverty": 0.00,
"food": 0.00,
"women": 0.00}
}

@export_range(0.01, 1.00) var word_learning_rate: float = 0.10
func _ready() -> void:
	_load_excerpt_dict_from_path()
	my_controller = get_parent()

func _activate_themes(excerpt_themes_dict: Dictionary):
	var unactivated_themes: Array
	var theme_strings: Array = excerpt_themes_dict.keys()
	for theme in theme_strings:
		if active_themes.find(theme) != -1:
			continue
		if excerpt_themes_dict[theme] < 0.10:
			continue
		unactivated_themes.append(theme)
	if unactivated_themes.size() == 0:
		return
	for theme in unactivated_themes:
		active_themes.append(theme)

func word_learn_theme_from_excerpt(word_value: float, excerpt_value: float):
	var additive_weight_value: float = excerpt_value * word_learning_rate
	word_value += additive_weight_value
	return word_value

func calculate_word_associations_from_excerpt(excerpt_themes: Dictionary, target_word_associations: Dictionary):
	var result: Dictionary
	for theme in excerpt_themes.keys():
		var excerpt_value: float = excerpt_themes[theme]
		var word_value: float = target_word_associations[theme]
		var new_word_value = word_learn_theme_from_excerpt(word_value, excerpt_value)
		result[theme] = new_word_value
	return result

func _handle_answers(excert_id_confirmed_word_dict: Dictionary): #excerpt id: array of word_strings for answers
	var excerpt_id: String = excert_id_confirmed_word_dict.keys()[0]
	var answers: Array = excert_id_confirmed_word_dict[excerpt_id]
	var excerpt_themes_dict: Dictionary = my_controller.excerpt_controller.excerpts_dict[excerpt_id]["Themes"]
	var answer_themes: Array[Dictionary]
	for word in answers:
		var words: Array = word_dict.keys()
		var answer_theme_dict: Dictionary
		if words.find(word) == -1:
			var dict_template = themes_dict_template.duplicate(true)
			word_dict[word] = dict_template
			answer_theme_dict = word_dict[word]["Themes"].duplicate(true)
		else:
			answer_theme_dict = word_dict[word]["Themes"].duplicate(true)
		answer_themes.append(answer_theme_dict)
	for word_themes_dict in answer_themes:
		var index: int = answer_themes.find(word_themes_dict) #sloppy can change this so that the for loop is just based on size and find the dict from index
		var result = calculate_word_associations_from_excerpt(excerpt_themes_dict, word_themes_dict)
		answer_themes[index] =  result
	for word in answers:
		var index = answers.find(word)
		var my_themes = answer_themes[index]
		word_dict[word]["Themes"] = my_themes

func _load_excerpt_dict_from_path():
	var my_file = FileAccess.open(word_dict_path, FileAccess.READ)
	var file_contents: String = my_file.get_as_text()
	my_file.close()
	var json := JSON.new()
	var error := json.parse(file_contents)
	if error == OK:
		var data: Dictionary = json.data
	else:
		print("ERROR: WORD DICT CANNOT BE PARSED")
		return
	word_dict = json.data
