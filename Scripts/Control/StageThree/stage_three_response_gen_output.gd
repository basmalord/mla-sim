extends Control

signal response_set
signal section_displayed
signal waiting_for_advance

@onready var my_container: Container = $ResponseOutputContainer
@onready var my_rtl: RichTextLabel = $ResponseOutputContainer/ResponseOutputRTL
@onready var intro_generator: Node = $IntroSectionGenerator
@onready var my_controller: Control = get_parent()

@export_range(0,4,1) var section_index: int = 0

var modified_excerpt
var response_entry: Dictionary
var prompt_goals: Array
var selected_goal: String
var inserted_words_indexes
var inserted_words
var blank_indicator: String = "______"
var last_inserted_word
var last_inserted_word_index

func _ready() -> void:
	if my_controller is Control:
		connect("section_displayed", Callable(my_controller, "_switch_send_button_disabled"))
	#connect("response_set", Callable(self, "_advance_section"))
	#connect("response_set", Callable(self, "_display_section"))

func _advance_section():
	_display_section()
	emit_signal("waiting_for_advance")
	print("WAITING FIRED")
	await section_displayed
	print("POST WAITING FIRED")
	if section_index == 4:
		section_index = 0
		return
	section_index += 1
	print("BOGOOSOSOS", section_index)

func _display_section():
	my_rtl.text = get_response_string() #need a different animation compared to the prompt output
	print("WANT WAITING FIRED TO FIRE")
	await waiting_for_advance
	await get_tree().create_timer(0.06).timeout
	emit_signal("section_displayed")

func get_response_string() -> String:
	var new_text: String
	if section_index == 0:
		new_text = intro_generator.generate_intro_string(prompt_goals)
		return new_text
	if !response_entry.has("ResponseSections"):
		return ""
	var response_sections_array: Array = response_entry["ResponseSections"].keys()
	if (response_sections_array.size() - 1) < section_index:
		return ""
	var target_section: Dictionary = response_entry["ResponseSections"][response_sections_array[section_index]]
	new_text = target_section["ResponseString"]
	var words_to_remove_array: Array = target_section["WordsToRemove"]
	var words_to_remove: Array
	for entry in words_to_remove_array:
		words_to_remove.append(entry.keys()[0])
	for index in words_to_remove.size():
		var word = words_to_remove[index]
		var word_string_index: int = new_text.findn(word)
		new_text = erase_word_from_string(word, new_text, word_string_index)
	return new_text

func _set_response_entry(candidate_entry: Dictionary, goals_array: Array):
	response_entry = candidate_entry
	prompt_goals = goals_array
	emit_signal("response_set")
	_advance_section()

#reused funcs

func delete_word_input(word_to_delete: String): #this works for delete last word functionality, if you pass a word that isn't the last word, it may fuck up because the erase function works on word length (i.e: will fuck up if word length and last word is not equal)
	if get_last_inserted_word() == "":
		return
	if get_last_inserted_word_index() == -1:
		return
	word_to_delete = get_last_inserted_word()
	modified_excerpt = erase_word_from_string(word_to_delete, modified_excerpt)
	inserted_words_indexes.pop_back()
	inserted_words.pop_back()
	my_rtl.text = modified_excerpt

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
	var removed_words: Array = my_controller.response_manager.active_response_entry["ResponseSections"][str(section_index)]["WordsToRemove"]
	return removed_words

func generate_index_offest():
	var offset: int = 0
	for word in inserted_words:
		offset += get_string_length_difference(blank_indicator, word)
	return offset

func _insert_selected_word(selected_word: String):
	if !modified_excerpt.contains("_"):
		return
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
	my_rtl.text = modified_excerpt
	get_parent()._on_excerpt_finished_processing(selected_word)

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
