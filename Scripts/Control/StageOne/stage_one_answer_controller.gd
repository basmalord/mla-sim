extends Node

signal correctness_array_generated(correctness_array: Array[String])

var active_answer: String #information to save
var active_answer_char_count_dict: Dictionary
var active_answer_multiple_char_array: Array[String]
var is_first_game: bool = true #ITS
var answer_dict: Array[String] = load_lines("res://Data/StageOne/answer_dict.txt")
var previous_answers: Array[String] #ITS

func _confirm_button_pressed(candidate_answer: String):
	candidate_answer = candidate_answer.to_lower()
	print("this is candidate answer: ", candidate_answer)
	var candidate_char_array: Array[String] = generate_character_array(candidate_answer)
	var active_answer_char_array: Array[String] = generate_character_array(active_answer)
	print("this is can array: ", candidate_char_array, " This is act array: ", active_answer_char_array)
	compare_string_arrays(active_answer_char_array, candidate_char_array)

func check_against_active_answer(candidate_answer: String):
	if candidate_answer == active_answer:
		return true 
	return false

func compare_string_arrays(example: Array[String], compared: Array[String]) -> Array[String]: #glitch in here where partially correct is showing up twice sometimes
	var correctness_dict: Array[Dictionary]
	var my_array: Array[String]# if the amount correct of x letter is equal to the amount of x letter in the active_answer_count, and if there are partially correct entries with that letter, go through all those partial corrects and change them to incorrects
	var candidate_answer_count_dict: Dictionary = generate_character_count_dict("".join(compared)) #IF THE AMOUNT OF A GIVEN CHARACTER IN THE CANDIDATE ANSWER IS GREATER THAN THE AMOUNT OF THE SAME CHARACTER IN THE ACTIVE ANSWER COUNT DICT, THEN WE NEED TO LOOK AT THAT CHARACTER SPECIFICALLY
	for character in candidate_answer_count_dict.keys():
		if active_answer_char_count_dict.get(character, 0) == 0:
			continue
		my_array.append(character)
	print("this is my_array: ", my_array)
	var candidate_answer_correct_count_dict: Dictionary
	var candidate_answer_partial_count_dict: Dictionary
	var example_size: int = example.size()
	var compared_size: int = compared.size()
	var index_range: int = min(example_size, compared_size)
	for i in index_range:
		if example[i] == compared[i]:
			correctness_dict.append({compared[i]: "correct"})
			var correct_int_value = candidate_answer_correct_count_dict.get(compared[i], 0) + 1
			candidate_answer_correct_count_dict[compared[i]] = correct_int_value
			continue
		elif example.find(compared[i]) != -1:
			print("this is when partial: ", compared[i], " ",i, " ", example[i])
			correctness_dict.append({compared[i]: "partial"})
			var partial_int_value = candidate_answer_partial_count_dict.get(compared[i], 0) + 1
			candidate_answer_partial_count_dict[compared[i]] = partial_int_value
			continue
		correctness_dict.append({compared[i]: "incorrect"})
	if !my_array.is_empty():
		for character in my_array:
			if candidate_answer_correct_count_dict.get(character, 0) == 0:
				continue
			if active_answer_char_count_dict[character] == candidate_answer_correct_count_dict[character]:
				if candidate_answer_partial_count_dict.get(character, 0) == 0:
					continue
				for dict in correctness_dict:
					if dict.keys()[0] == character:
						if dict[character] == "partial":
							dict[character] = "incorrect"
	var correctness_array: Array[String]
	for dict in correctness_dict:
		var key = dict.keys()[0]
		var result = dict[key]
		correctness_array.append(result)
	await get_tree().create_timer(0.05).timeout
	get_parent().correctness_array_generated.emit(correctness_array)
	return correctness_array

func generate_character_array(my_string: String):
	var string_length: int = my_string.length()
	var character_array: Array[String]
	for character_index in string_length:
		var character: String = my_string[character_index]
		character_array.append(character)
	return character_array

func load_lines(path: String) -> Array[String]:
	var lines: Array[String] = []
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: " + path)
		return lines
	while not file.eof_reached():
		lines.append(file.get_line())
	return lines

func _set_active_answer():
	print("sactive answer has been called")
	active_answer_char_count_dict = {}
	active_answer_multiple_char_array = []
	var new_active_answer: String = active_answer
	var index_range: int
	var random_index: int 
	while new_active_answer == active_answer or previous_answers.find(new_active_answer) != -1:
		index_range = answer_dict.size() 
		random_index = randi()%index_range
		if random_index > index_range:
			return
		new_active_answer = answer_dict[random_index]
	for character_index in new_active_answer.length():
		var char_string: String = new_active_answer[character_index] #get character, +1 character count, erase character, check string with find(), if -1 return, if not then +1 character count, check string with find() repeat until -1
		_populate_character_count_dict(new_active_answer, char_string)
	active_answer = new_active_answer
	previous_answers.append(new_active_answer)
	print(active_answer, " ", active_answer_char_count_dict)

func _populate_character_count_dict(candidate_string: String, character_string: String):
	var index: int = candidate_string.find(character_string)
	var candidate_string_editable: String
	var character_count: int = 0
	candidate_string_editable = candidate_string
	while index != -1:
		character_count += 1
		candidate_string_editable = erase_char(candidate_string_editable, index)
		index = candidate_string_editable.find(character_string)
	active_answer_char_count_dict[character_string] = character_count
	if character_count > 1:
		active_answer_multiple_char_array.append(character_string)

func generate_character_count_dict(candidate_string: String):
	var count_dict: Dictionary
	for character in candidate_string.length():
		if count_dict.keys().find(character) != -1:
			continue
		var character_string = candidate_string[character]
		var index: int = candidate_string.find(character_string)
		var candidate_string_editable: String
		var character_count: int = 0
		candidate_string_editable = candidate_string
		while index != -1:
			character_count += 1
			candidate_string_editable = erase_char(candidate_string_editable, index)
			index = candidate_string_editable.find(character_string)
		count_dict[character_string] = character_count
	return count_dict


func erase_char(text: String, index: int) -> String:
	if index < 0 or index >= text.length():
		return text
	return text.substr(0, index) + text.substr(index + 1)

func _reset():
	print("THIS RESET HAS BEEN CALLED")
	_set_active_answer()

func _ready() -> void:
	if is_first_game:
		is_first_game = false #Information to save
		_set_active_answer()
