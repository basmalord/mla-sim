extends OptionButton

signal _random_words_generated(words: Array)

const response_button_scene = preload("res://Scenes/UI/Input/input_button_base.tscn")

@onready var my_controller: Control = get_parent()

@export var number_of_options: int = 5

var current_words: Array[String]
var current_word_entries: Dictionary
var my_grid_container: Container
var min_size: Vector2 = Vector2(91,81)

var goals_string_array: Array[String]
var goals_values_array: Array[float]

func _import_items(goals_array: Array):
	for goal in goals_array:
		add_item(goal)
	_generate_word_buttons(goals_array)

func _clear_items():
	clear()
	_destroy_all_buttons()

func _brief_disable():
	self.disabled = true
	await get_tree().create_timer(0.05).timeout
	self.disabled = false

#cp from options manager

func _destroy_all_buttons():
	if my_grid_container is not Container:
		return
	for child in my_grid_container.get_children():
		child.queue_free()

func _on_word_clicked(word_clicked: String, _sent_sim_value: float):
	var item_index: int = current_words.find(word_clicked)
	if item_index == -1:
		print("ERROR: GOALS OPTIONS DOES NOT CONTAIN TEXT OF GOALS BUTTON: ", word_clicked)
		return
	select(item_index)
	emit_signal("item_selected", item_index)

func _generate_word_buttons(words: Array):
	if my_grid_container == null:
		my_grid_container = get_children()[0]
	current_words = []
	while words.size() > my_grid_container.get_children().size():
		_create_word_button()
	for index in my_grid_container.get_children().size():
		var child = my_grid_container.get_children()[index]
		child.text = words[index]
	current_words = words

func _create_word_button():
	var new_word_button: InputButton = response_button_scene.instantiate()
	my_grid_container.add_child(new_word_button)
	new_word_button.type = "Prompt"
