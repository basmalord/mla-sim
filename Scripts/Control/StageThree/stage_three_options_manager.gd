extends Control

signal _random_words_generated(words: Array)

const response_button_scene = preload("res://Scenes/UI/Input/input_button_base.tscn")

@onready var my_controller: Control = get_parent()

@export var number_of_options: int = 5

var current_words: Array[String]
var current_word_entries: Dictionary
var my_grid_container: Container
var min_size: Vector2 = Vector2(91,81)
var buttons_are_disabled: bool = false
var flash_colour: Color = Color(0.161, 0.824, 0.157, 1.0)
var flash_length: float = 4.00
var flash_timer: float = 0.25

func _alter_shadow_outline(value: int, target_rtl: Button):
	target_rtl.add_theme_constant_override("shadow_outline_size", value)

func _flash_all_buttons():
	for child in my_grid_container:
		if child is Button:
			_flash_button(child)

func _flash_button(node_to_flash: Node):
	var original_colour: Color = node_to_flash.get_self_modulate()
	node_to_flash.add_theme_color_override("font_shadow_color", flash_colour)
	var timer = get_tree().create_timer(flash_length)
	while timer.time_left > 0:
		await get_tree().create_timer(flash_timer).timeout
		var font_tween = create_tween()
		var shadow_tween = create_tween()
		shadow_tween.tween_method(_alter_shadow_outline(1, node_to_flash), 1, 5 , flash_timer)
		font_tween.tween_property(node_to_flash, "modulate", flash_colour, flash_timer)
		font_tween.tween_property(node_to_flash, "modulate", original_colour, flash_timer)
		await get_tree().process_frame

func _on_send_clicked():
	_destroy_all_buttons()

func _show_all_buttons():
	print("showing from stage three options manager")
	if my_grid_container is not Container:
		return
	for child in my_grid_container.get_children():
		child.show()

func _hide_all_buttons():
	if my_grid_container is not Container:
		return
	for child in my_grid_container.get_children():
		child.hide()

func _disable_all_buttons():
	if my_grid_container is not Container:
		return
	for child in my_grid_container.get_children():
		child.disabled = true
	buttons_are_disabled = true

func _enable_all_buttons():
	print("enabling buttons from options man")
	if my_grid_container is not Container:
		return
	for child in my_grid_container.get_children():
		child.disabled = false
	buttons_are_disabled = false

func _destroy_all_buttons():
	if my_grid_container is not Container:
		return
	for child in my_grid_container.get_children():
		child.queue_free()

func _on_word_clicked(word_clicked: String, _sent_sim_value: float):
	var sim_value: float = current_word_entries[word_clicked]
	my_controller._on_word_clicked(word_clicked, sim_value)

func _generate_word_buttons(word_entries: Dictionary):
	var words: Array
	var sim_values: Array
	for word in word_entries.keys():
		words.append(word)
		sim_values.append(word_entries[word])
	if my_grid_container == null:
		my_grid_container = get_children()[0]
	current_words = []
	current_word_entries = {}
	while words.size() > my_grid_container.get_children().size():
		_create_word_button()
	for child in my_grid_container.get_children():
		var random_index: int = randi_range(0, (words.size() - 1))
		child.text = words[random_index]
		child.sim_value = sim_values[random_index]
		words.pop_at(random_index) #think this could actually be the return value but not sure
	current_word_entries = word_entries




func _create_word_button():
	var new_word_button: InputButton = response_button_scene.instantiate()
	my_grid_container.add_child(new_word_button)
	new_word_button.type = "Prompt"
