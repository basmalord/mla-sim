extends OptionButton

signal _random_words_generated(words: Array)
signal next_button_shown


const response_button_scene = preload("res://Scenes/UI/Input/input_button_base.tscn")

@onready var my_controller: Control = get_parent()

@export var number_of_options: int = 5

var current_words: Array[String]
var current_word_entries: Dictionary
var my_grid_container: Container
var min_size: Vector2 = Vector2(91,81)
var button_node_array: Array[InputButton]
var invisible_button_count: int = 0
var goals_string_array: Array[String]
var goals_values_array: Array[float]
var buttons_are_disabled: bool = false

func _import_items(goals_array: Array):
	for goal in goals_array:
		add_item(goal)
	_generate_word_buttons(goals_array)
	_hide_all_word_buttons()
	_disable_all_word_buttons()

func _clear_items():
	clear()


func _brief_disable():
	self.disabled = true
	await get_tree().create_timer(0.05).timeout
	self.disabled = false

func _hide_all_word_buttons():
	for word_button in button_node_array:
		word_button.hide()
		invisible_button_count += 1
		print("this is invisible word count: ", invisible_button_count)

func get_next_invisible_word():
	for word_button in button_node_array:
		if word_button.visible == false:
			print("this is invisible word text: ", word_button.text)
			return word_button.text
	return ""

#func _show_next_word_button():
	#var cut_off: bool = false
	#for word_button in button_node_array:
		#if cut_off:
			#break
		#if word_button.visible == false:
			#word_button.show()
			#invisible_button_count -= 1
			#cut_off = true
			#emit_signal("next_button_shown")
	#if invisible_button_count == 0:
		#_enable_all_word_buttons()

func _show_word_by_text(target_text: String):
	var cut_off: bool = false
	for word_button in button_node_array:
		if cut_off:
			break
		if word_button.text == target_text:
			word_button.show()
			invisible_button_count -= 1
			print("this is negative invisible button count: ", invisible_button_count)
			emit_signal("next_button_shown")
	if invisible_button_count == 0:
		_enable_all_word_buttons()


func _run_show_animation(word_button: InputButton):
	pass

func _disable_all_word_buttons():
	for word_button in button_node_array:
		word_button.disabled = true
	buttons_are_disabled = true

func _enable_all_word_buttons():
	print("enabling buttons from response opts")
	for word_button in button_node_array:
		word_button.disabled = false
		print("this is enable func in repsonse opts: ", word_button, word_button.disabled)
	buttons_are_disabled = false

func _enable_word_button(word_button: InputButton):
	word_button.disabled = false

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
		button_node_array.append(child)
	current_words = words


func _create_word_button():
	var new_word_button: InputButton = response_button_scene.instantiate()
	my_grid_container.add_child(new_word_button)
	new_word_button.type = "Prompt"
