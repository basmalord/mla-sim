extends Control

signal _random_words_generated(words: Array)

@onready var my_controller: Control = get_parent()

var current_words: Array[String]
var my_grid_container: HBoxContainer
var min_size: Vector2 = Vector2(91,81)


func _on_word_clicked(word_clicked: String):
	my_controller._on_word_clicked(word_clicked)

func _generate_random_word_buttons(words: Array):
	if my_grid_container == null:
		my_grid_container = get_children()[0]
	current_words = []
	var word_dict = get_parent().associations_handler.word_dict
	var word_array = word_dict.keys()
	for child in my_grid_container.get_children():
		var word_to_add: String = " "
		var random_index: int = randi_range(0, word_array.size() - 1)
		word_to_add = word_array[random_index]
		while current_words.has(word_to_add):
			random_index = randi_range(0, word_array.size() - 1)
			word_to_add = word_array[random_index]
		current_words.append(word_to_add)
		child.text = word_to_add
		child.custom_minimum_size = min_size
	_generate_word_buttons(words)


func _generate_word_buttons(words: Array): #signal makes this fire currently, needds to make other fire; this one needs to pick random buttons and assign them the text from words to choose
	if my_grid_container == null:
		my_grid_container = get_children()[0]
	if words.size() == 0:
		return
	var buttons: Array[Node] = my_grid_container.get_children()
	var no_of_buttons: int = buttons.size()
	var chosen_indexes: Array[int]
	for word in words:
		var random_index: int = randi_range(0, no_of_buttons - 1)
		while chosen_indexes.has(random_index):
			random_index = randi_range(0, no_of_buttons - 1)
		chosen_indexes.append(random_index)
		var chosen_button: InputButton = buttons[random_index]
		chosen_button.text = word
