extends Control

signal new_excerpt_presented(excerpt_entry: Dictionary)

@onready var excerpts_holder: Node = $ExcerptsHolder
@onready var excerpt_label: Label = $ExcerptLabel
@export var blank_indicator: String = "________"
var active_excerpt_id: String
var excerpts_dict: Dictionary
var previous_excerpt_ids: Array[String]
var modified_excerpt: String
var blank_indicator_index_start_dict: Dictionary[int, int] #key is start index, value is difference between word length and blank indicator length
var last_inserted_word_index: int #need to refactor to completely remove reference to these, only using the arrays
var last_inserted_word: String #need to refactor to completely remove reference to these
var inserted_words_indexes: Array[int]
var inserted_words: Array[String]
var current_excerpt_index: int = 0

func _ready() -> void:
	new_excerpt_presented.connect(get_parent()._on_new_excerpt_presented)

func delete_word_input(word_to_delete: String = "moose"): #this works for delete last word functionality, if you pass a word that isn't the last word, it may fuck up because the erase function works on word length (i.e: will fuck up if word length and last word is not equal)
	if get_last_inserted_word() == "":
		return
	if get_last_inserted_word_index() == -1:
		return
	word_to_delete = get_last_inserted_word()
	modified_excerpt = erase_word_from_string(word_to_delete, modified_excerpt)
	inserted_words_indexes.pop_back()
	inserted_words.pop_back()
	$ExcerptLabel.text = modified_excerpt

func _on_failure():
	var iterations: int = inserted_words.size()
	for i in iterations:
		delete_word_input()

func _display_active_excerpt():
	var excerpt_string: String = excerpts_dict[active_excerpt_id]["SentenceString"]
	var words_to_remove: Array = get_removed_words_from_active_excerpt()
	print("got past words to replace")
	for index in words_to_remove.size():
		print("started for loop")
		var word = words_to_remove[index]
		var word_string_index: int = excerpt_string.findn(word)
		excerpt_string = erase_word_from_string(word, excerpt_string, word_string_index)
		print("end of 1 iteration of for loop")
	$ExcerptLabel.text = excerpt_string
	modified_excerpt = excerpt_string
	print("got to emitting excerpts dict")
	emit_signal("new_excerpt_presented", excerpts_dict[active_excerpt_id])



func erase_word_from_string(target_word: String = get_last_inserted_word(), target_excerpt: String = modified_excerpt, target_index: int = get_last_inserted_word_index()):
	if target_word == "":
		return
	if target_index == -1:
		return
	var word_length: int = target_word.length()
	for character in word_length:
		target_excerpt = erase_char(target_excerpt, target_index)
	target_excerpt = insert_blank_indicator(word_length, target_index, target_excerpt)
	return target_excerpt

func erase_blank_indicator_from_string(target_index: int, target_excerpt: String): 
	for character in blank_indicator.length():
		target_excerpt = erase_char(target_excerpt, target_index)
	return target_excerpt

func erase_char(text: String, index: int) -> String:
	if index < 0 or index >= text.length():
		return text
	return text.substr(0, index) + text.substr(index + 1)

func get_last_inserted_word():
	var result = inserted_words.back()
	if result == null:
		return ""
	return inserted_words.back() #returns null if empty

func get_last_inserted_word_index():
	var result = inserted_words_indexes.back()
	if result == null:
		return -1
	return inserted_words_indexes.back() #returns null if empty

func get_next_blank_indicator_index(target_excerpt: String):
	var index: int = target_excerpt.find("_")
	return index

func get_string_length_difference(string_one: String, string_two: String): #For comparing with blank_indicator length, string_one should always = blank_indicator ; negative values are necessary to capture to generate index offsets
	if string_one != blank_indicator:
		var length_one: int = string_one.length()
		var length_two: int = string_two.length()
		var length_array: Array
		length_array.append(maxi(length_one, length_two))
		length_array.append(min(length_one, length_two))
		var difference: int = length_array[0] - length_array[1]
		return difference
	var difference: int = string_one.length() - string_two.length()
	return difference

func get_removed_words_from_active_excerpt() -> Array:
	print("got to get words to replace")
	var removed_words: Array = excerpts_dict[active_excerpt_id]["WordsToReplace"]
	return removed_words

func generate_index_offest():
	var offset: int = 0
	for word in inserted_words:
		offset += get_string_length_difference(blank_indicator, word)
	return offset

func _insert_selected_word(selected_word: String):
	if !modified_excerpt.contains("_"):
		return false
	var blank_indicator_index: int = modified_excerpt.find("_")
	if blank_indicator_index == 0:
		selected_word = selected_word.capitalize()
	var newly_modified_excerpt: String
	newly_modified_excerpt = modified_excerpt
	newly_modified_excerpt = replace_blank_indicator(selected_word, newly_modified_excerpt, blank_indicator_index)
	inserted_words.append(selected_word)
	#if inserted_words.size() > 1:
		#blank_indicator_index += generate_index_offest()
	inserted_words_indexes.append(blank_indicator_index)
	last_inserted_word = selected_word
	last_inserted_word_index = blank_indicator_index
	modified_excerpt = newly_modified_excerpt
	$ExcerptLabel.text = modified_excerpt
	get_parent()._on_excerpt_finished_processing(selected_word)
	return true

func insert_blank_indicator(word_size: int, index_start: int, excerpt_string: String):
	excerpt_string = excerpt_string.insert(index_start, blank_indicator)
	return excerpt_string

func replace_blank_indicator(target_word: String, target_excerpt: String, index_start: int = get_last_inserted_word_index()):
	if index_start == -1:
		return
	target_excerpt = erase_blank_indicator_from_string(index_start, target_excerpt)
	target_excerpt = target_excerpt.insert(index_start, target_word)
	return target_excerpt

func _reset_variable_properties():
	inserted_words_indexes = []
	inserted_words = []
	print("got to the end of reset")

func _set_excerpts_dict(candidate_dict: Dictionary):
	excerpts_dict = candidate_dict
	_setup_active_excerpt()


func _set_active_excerpt():
	#print("at _set_active_excerpt")
	#var index_range = excerpts_dict.size() - 1
	#if index_range < 0:
		#print("stuck at under 0")
		#return false
	#var random_index: int = randi_range(0, index_range)
	var excerpt_id: String = excerpts_dict.keys()[current_excerpt_index]
	#if excerpt_id == active_excerpt_id:
		#return false
	#if previous_excerpt_ids.find(excerpt_id) != -1:
		#return false
	active_excerpt_id = excerpt_id
	previous_excerpt_ids.append(active_excerpt_id)
	current_excerpt_index += 1
	print("got to the end of set")


func _setup_active_excerpt():
	print("got to the start of setup")
	if previous_excerpt_ids.size() == excerpts_dict.keys().size():
		get_parent().confirm_button.disabled = true
		get_parent()._end_stage()
		return
	#var has_set_new_excerpt: bool = false #if rounds exceed excerpts, then this will cause a data leak, either put safeguard in or make sure rounds never exceed
	#while !has_set_new_excerpt:
		#has_set_new_excerpt =
	_set_active_excerpt()
	_reset_variable_properties()
	_display_active_excerpt()
	print("got to the end of setup")


func _mutate_excerpt_themes_values(excerpt_id: String, answers: Array):
	if excerpts_dict.keys().find(excerpt_id) == -1:
		print("unable to find ex id")
		return
	if answers.size() < 1:
		print("answers array too small")
		return
	var my_index: int = -1
	var answer_theme_values: Array
	var excerpt_theme_values: Array
	var general_themes: Array = answers[0]["Themes"].keys()
	var excerpt_dict_entry: Dictionary = excerpts_dict[excerpt_id]
	var mutated_excerpt_dict_entry: Dictionary = excerpt_dict_entry.duplicate(true)
	var mutated_excerpt_themes_dict: Dictionary = mutated_excerpt_dict_entry["Themes"]
	var themes_keys: Array = mutated_excerpt_themes_dict.keys()
	for key in themes_keys:
		excerpt_theme_values.append(mutated_excerpt_themes_dict[key])
	for answer in answers:
		var themes_entry: Dictionary = answer["Themes"]
		for theme_string in general_themes:
			answer_theme_values.append(themes_entry[theme_string])
		for value in answer_theme_values:
			my_index += 1
			var infected_excerpt_theme_value: float = infect_excerpt_themes(excerpt_theme_values[my_index],answer_theme_values[my_index])
			excerpt_theme_values[my_index] = infected_excerpt_theme_value
		my_index = -1
		answer_theme_values = []
	for index in excerpt_theme_values.size():
		var target_theme: String = mutated_excerpt_themes_dict.keys()[index]
		mutated_excerpt_themes_dict[target_theme] = excerpt_theme_values[index]
	excerpts_dict[excerpt_id]["Themes"] = mutated_excerpt_themes_dict

func infect_excerpt_themes(excerpt_value: float, answer_value: float):
	if answer_value < 0.1: #ignores weak relationship
		return excerpt_value
	var controlled_answer_value: float = answer_value * 0.1 #keeps infection rate small
	var new_excerpt_value = excerpt_value + controlled_answer_value
	return new_excerpt_value

func get_active_excerpt_entry():
	var entry_to_send: Dictionary = excerpts_dict[active_excerpt_id]
	return entry_to_send
