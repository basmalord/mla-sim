extends Control

signal response_set
signal section_displayed(is_last_section: bool)
signal waiting_for_advance
signal new_word_set
signal erasing(words_to_remove: int, goal_removed: String)
signal got_words_to_remove
signal passive_prompt_data_sent

@onready var my_container: Container = $ResponseOutputContainer
@onready var my_rtl: RichTextLabel = $ResponseOutputContainer/ResponseOutputRTL
@onready var intro_generator: Node = $IntroSectionGenerator
@onready var my_controller: Control = get_parent()

@export var section_index: int = 0

var modified_excerpt: String
var response_entry: Dictionary
var prompt_goals: Array
var selected_goal: String
var inserted_words_indexes: Array = []
var inserted_words: Array = []
var inserted_words_match_type_array: Array[bool] = []
var blank_indicator: String = "______"
var last_inserted_word: String
var last_inserted_word_index: int
var number_of_section_indexes: int
var last_sections_length: int = 0


func _ready() -> void:
	if my_controller is Control:
		connect("section_displayed", Callable(my_controller, "_switch_send_button_disabled"))
	#connect("response_set", Callable(self, "_advance_section"))
	#connect("response_set", Callable(self, "_display_section"))

func _reset_all():
	section_index = 0
	modified_excerpt = ""
	response_entry = {}
	prompt_goals = []
	selected_goal = ""
	inserted_words_indexes = []
	inserted_words = []
	inserted_words_match_type_array = []
	last_inserted_word = ""
	last_inserted_word_index = 0
	number_of_section_indexes = 0
	my_rtl.text = ""

func _retract_goal():
	var goal_tally = my_controller.goal_tally_controller
	goal_tally._remove_goal_tally()

func _send_goal():
	var goal: String = selected_goal
	var goal_tally = my_controller.goal_tally_controller
	goal_tally._add_goal_tally(goal)

func _handle_erase_section():
	if section_index > 0: #move from 1
		print("erase is firing from repsonse gen")
		emit_signal("erasing", get_words_to_remove_size(), my_controller.goal_tally_controller.last_goals.back())
		#await got_words_to_remove
		print("erase is firing from repsonse gen")
		_remove_last_section_text()
		_reset_affected_to_last_section()
		_retract_goal()
		if section_index == 0: #move from less than equal 1
			my_controller._switch_erase_button_disabled(false)
		my_controller._switch_send_button_disabled(false)
		if my_controller.generate_response_button.disabled:
			my_controller._switch_generate_button_disabled()
		 #now just need to take away from the probability generator, make sure to do single
		#functions so you can rework if you have time to make it so they can remove single words at a time

func get_acceptability_and_acceptability_array():
	var response_sections_dict: Dictionary = response_entry["ResponseSections"]
	var current_section_id: String = response_sections_dict.keys()[section_index - 1] #moved down from 2
	var current_section_entry: Dictionary = response_sections_dict[current_section_id]
	var hidden_goal_conditions_entry: Dictionary = current_section_entry["HiddenGoalConditions"]
	var number_of_entry_indexes: int = hidden_goal_conditions_entry.keys().size() - 1
	var chosen_words_acceptability_array = get_acceptability_array(hidden_goal_conditions_entry, number_of_entry_indexes)
	var acceptability: String = get_acceptability(chosen_words_acceptability_array)
	var data_array: Array 
	data_array.append(acceptability)
	data_array.append(chosen_words_acceptability_array)
	return data_array


func get_acceptability_array(hidden_goals_conditions_entry: Dictionary, number_of_entry_indexes: int):
	var chosen_words_acceptability_array: Array[Dictionary]
	for i in number_of_entry_indexes:
		var new_entry: Dictionary
		var inserted_word: String = inserted_words[i]
		var word_entry: Dictionary = hidden_goals_conditions_entry[hidden_goals_conditions_entry.keys()[i]]
		var unacceptable_word_array: Array = word_entry["unacceptable"]
		for word in unacceptable_word_array:
			if word == inserted_word:
				new_entry = {inserted_word: "unacceptable"}
				chosen_words_acceptability_array.append(new_entry)
		var acceptable_word_array: Array = word_entry["acceptable"]
		for word in acceptable_word_array:
			if word == inserted_word:
				new_entry = {inserted_word: "acceptable"}
				chosen_words_acceptability_array.append(new_entry)
		if new_entry.is_empty():
			new_entry = {inserted_word: "unintelligible"}
			chosen_words_acceptability_array.append(new_entry)
	return chosen_words_acceptability_array

func get_acceptability(chosen_word_acceptability_array: Array[Dictionary]):
	var values: Array
	for entry in chosen_word_acceptability_array:
		for value in entry:
			if value == "unacceptable":
				return "unacceptable"
			values.append(value)
	if !values.has("acceptable"):
		return "unintelligible"
	if !values.has("unintelligible"):
		return "acceptable"

func get_words_to_remove_size():
	var number_of_words_to_remove: int
	var response_sections_dict: Dictionary = response_entry["ResponseSections"]
	var current_section_id: String = response_sections_dict.keys()[section_index - 1] #moved down from 2
	var current_section_entry: Dictionary = response_sections_dict[current_section_id]
	var current_words_to_remove_entry_array: Array = current_section_entry["WordsToRemove"]
	number_of_words_to_remove = current_words_to_remove_entry_array.size()
	emit_signal("got_words_to_remove")
	return number_of_words_to_remove

func get_word_to_remove_type(index: int):
	var response_sections_dict: Dictionary = response_entry["ResponseSections"]
	var current_section_id: String = response_sections_dict.keys()[section_index - 1] #moved down from 2
	var current_section_entry: Dictionary = response_sections_dict[current_section_id]
	var current_words_to_remove_entry_array: Array = current_section_entry["WordsToRemove"]
	print("this is current_words_to_remove_entry_array: ", current_words_to_remove_entry_array)
	var entry: Dictionary = current_words_to_remove_entry_array[index]
	var value: String = entry[entry.keys()[0]]
	return value

func _reset_affected_to_last_section():
	print("this is sec index before erase: ", section_index)
	section_index -= 1
	print("this is sec index after erase: ", section_index)
	var number_of_words_to_remove: int
	var response_sections_dict: Dictionary = response_entry["ResponseSections"]
	var current_section_id: String = response_sections_dict.keys()[section_index - 1]
	var current_section_entry: Dictionary = response_sections_dict[current_section_id]
	var current_words_to_remove_entry_array: Array = current_section_entry["WordsToRemove"]
	var current_section_string: String = current_section_entry["ResponseString"]
	var current_section_string_length: int = current_section_string.length()
	var total_length: int = my_rtl.text.length()
	var differance: int = total_length - current_section_string_length
	last_sections_length = differance
	number_of_words_to_remove = current_words_to_remove_entry_array.size()
	for word in number_of_words_to_remove:
		inserted_words_indexes.pop_back()
		inserted_words.pop_back()
		inserted_words_match_type_array.pop_back()
	#if !inserted_words.size() == 0:
		#last_inserted_word = inserted_words.back()
	#if !inserted_words_indexes.size() == 0:
		#last_inserted_word_index = inserted_words_indexes.back()


func _remove_last_section_text():
	var current_length: int = my_rtl.text.length()
	var length_difference: int = current_length - last_sections_length
	var new_text: String = my_rtl.text
	for i in length_difference:
		new_text = erase_char(new_text, new_text.length() - 1)
	my_rtl.text = new_text
	print("this is curr leng: ", current_length, "  This is length dif: ", length_difference, "this is new_text: ", new_text)

func _handle_word_clicked(word:String):
	if !my_rtl.text.contains("_"):
		print("returning from repsonse gen output")
		return
	_insert_selected_word(word)
	emit_signal("new_word_set")
	#if section_index - 1 != number_of_section_indexes:
		#print("firing hereeeee", section_index, "    ", number_of_section_indexes)
		#
		#return
	if !my_rtl.text.contains("_"):
		if section_index < number_of_section_indexes: #need to recall how the latter is calculated, changed from less than or equal to 
			if my_controller.generate_response_button.disabled == true:
				my_controller.generate_response_button.disabled = false
			if my_controller.send_response_button.disabled == false:
				my_controller.send_response_button.disabled = true
		if section_index == number_of_section_indexes:
			print("switched send from _handle word clicked")
			my_controller._switch_send_button_disabled()

func get_ready_for_word():
	if my_rtl.text.contains("_"):
		return true
	return false

func _advance_section():
	if section_index >= 0: #moved from 1
		my_controller._switch_erase_button_disabled(true)
	_display_section()
	emit_signal("waiting_for_advance")
	await section_displayed
	section_index += 1

func _display_section():
	last_sections_length = my_rtl.text.length() 
	number_of_section_indexes = response_entry["ResponseSections"].keys().size()
	my_rtl.text += get_response_string() #need a different animation compared to the prompt output
	modified_excerpt = my_rtl.text
	await waiting_for_advance
	await get_tree().create_timer(0.06).timeout
	if section_index == number_of_section_indexes:
		emit_signal("section_displayed", false)
		return
	emit_signal("section_displayed", false)
	if section_index == 1: #equals 1 because by here it will always be 1+ what it is
		my_controller._switch_generate_button_disabled() #this makes a slight flash, but you're going to add a loading animation over the button

func get_response_string() -> String:
	var new_text: String
	#if section_index == 0:
		#new_text = intro_generator.generate_intro_string(prompt_goals)
		#return new_text
	if !response_entry.has("ResponseSections"):
		return ""
	var response_sections_array: Array = response_entry["ResponseSections"].keys()
	if (response_sections_array.size()) < section_index:
		return ""
	var target_section: Dictionary = response_entry["ResponseSections"][response_sections_array[section_index]]
	new_text = target_section["ResponseString"]
	var words_to_remove_array: Array = target_section["WordsToRemove"]
	var words_to_remove: Array
	for entry in words_to_remove_array:
		words_to_remove.append(entry.keys()[0])
	for index in words_to_remove.size() - 1:
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
		return target_excerpt
	if target_index == -1:
		return target_excerpt
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
	return result #returns null if empty

func get_last_inserted_word_index():
	var result = inserted_words_indexes.back()
	if result == null:
		return -1
	return result #returns null if empty

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

func send_data_for_passive_prompt_generation():
	var chosen_words_array: Array[Dictionary] = generate_chosen_words_array()
	var response_sections_dict: Dictionary = response_entry["ResponseSections"]
	var current_section_id: String = response_sections_dict.keys()[section_index - 1] #moved down from 2, could be remove altogether
	var acceptability_data: Array = get_acceptability_and_acceptability_array()
	var data_array: Array = []
	data_array.append(acceptability_data[0])
	data_array.append(chosen_words_array)
	data_array.append(current_section_id)
	data_array.append(acceptability_data[1])
	emit_signal("passive_prompt_data_sent") #use this to generate the passive prompt
	return data_array

func generate_chosen_words_array(chosen_words: Array = inserted_words, match_type_array: Array[bool] = inserted_words_match_type_array):
	var chosen_words_array: Array[Dictionary]
	var mutatable_chosen_words: Array = chosen_words.duplicate()
	mutatable_chosen_words.reverse()
	var mutatable_matches_values = match_type_array.duplicate()
	mutatable_matches_values.reverse()
	for index in mutatable_chosen_words.size():
		var word: String = mutatable_chosen_words[index]
		var matches_value: bool = mutatable_matches_values[index]
		var new_entry: Dictionary = {word: matches_value}
		chosen_words_array.append(new_entry)
	return chosen_words_array

func _insert_selected_word(selected_word: String):
	if !modified_excerpt.contains("_"):
		return
	var blank_indicator_index: int = modified_excerpt.find("_")
	if blank_indicator_index == 0: #checks the string to see if the word to replace falls at the start, and capitalises if so
		selected_word = selected_word.capitalize()
	elif modified_excerpt[blank_indicator_index - 1] == "." or modified_excerpt[blank_indicator_index - 1] == "!" or modified_excerpt[blank_indicator_index - 1] == "?": #checks the string for punctuation and whether to capitalise.
		selected_word = selected_word.capitalize()
	var newly_modified_excerpt: String
	newly_modified_excerpt = modified_excerpt
	newly_modified_excerpt = replace_blank_indicator(selected_word, newly_modified_excerpt, blank_indicator_index)
	inserted_words.append(selected_word)
	print("I've just appended an inserted word", inserted_words)
	var inserted_word_type: String = my_controller.associations_manager.get_word_type(selected_word)
	var removed_word_type: String = get_word_to_remove_type(inserted_words.size() - 1)
	var matches: bool = false
	if inserted_word_type == removed_word_type:
		matches = false #need to get words to replace and find index, check type of index and compare to the word's type by reference to the associations dict
		inserted_words_match_type_array.append(matches)
	#if inserted_words.size() > 1:
		#blank_indicator_index += generate_index_offest()
	inserted_words_indexes.append(blank_indicator_index)
	last_inserted_word = selected_word
	last_inserted_word_index = blank_indicator_index
	modified_excerpt = newly_modified_excerpt
	my_rtl.text = modified_excerpt



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
