extends OptionButton

signal _random_words_generated(words: Array)
signal next_button_shown
signal word_buttons_generated

const response_button_scene = preload("res://Scenes/UI/Input/input_button_base.tscn")

@onready var my_controller: Control = get_parent()

@export var number_of_options: int = 5

var current_words: Array
var current_word_entries: Dictionary
var my_grid_container: Container = null
var min_size: Vector2 = Vector2(91,81)
var button_node_array: Array[InputButton]
var invisible_button_count: int = 0
var goals_string_array: Array[String]
var goals_values_array: Array[float]
var buttons_are_disabled: bool = false
var flash_colour: Color = Color(0.161, 0.824, 0.157, 1.0)
var flash_length: float = 4.00
var flash_timer: float = 0.25


#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("B"):
		#_enable_all_word_buttons()

func _import_items(goals_array: Array):
	for goal in goals_array:
		add_item(goal)
	_generate_word_buttons(goals_array)
	_hide_all_word_buttons()
	_disable_all_word_buttons()

func _clear_items():
	clear()

func _alter_shadow_outline(value: int, target_rtl: Button):
	target_rtl.add_theme_constant_override("shadow_outline_size", value)

func _flash_all_buttons():
	if my_grid_container == null:
		return
	if my_grid_container.get_children().is_empty():
		return
	if my_grid_container.get_children()[0].disabled:
		return
	if my_grid_container.get_children()[0].visible == false:
		return
	for child in my_grid_container.get_children():
		if child is Button:
			print("this is the button that the options handler is flashing: ", child)
			_flash_button(child)

func _flash_button(node_to_flash: Node):
	var original_colour: Color = node_to_flash.get_self_modulate()
	node_to_flash.add_theme_color_override("font_shadow_color", flash_colour)
	var timer = get_tree().create_timer(flash_length)
	if node_to_flash == null:
		return
	while timer.time_left > 0:
		await get_tree().create_timer(flash_timer).timeout
		var font_tween = create_tween()
		var shadow_tween = create_tween()
		shadow_tween.tween_method(_alter_shadow_outline(1, node_to_flash), 1, 5 , flash_timer)
		font_tween.tween_property(node_to_flash, "modulate", flash_colour, flash_timer)
		font_tween.tween_property(node_to_flash, "modulate", original_colour, flash_timer)
		await get_tree().process_frame


func _brief_disable():
	self.disabled = true
	await get_tree().create_timer(0.05).timeout
	self.disabled = false

func _show_all_word_buttons(first: bool = true):
	if first:
		await word_buttons_generated
	for word_button in button_node_array:
		word_button.show()


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
	print("disabling from selection menu")
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
	my_controller._play_standard_input_sound()
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
	emit_signal("word_buttons_generated")


func _create_word_button():
	var new_word_button: InputButton = response_button_scene.instantiate()
	my_grid_container.add_child(new_word_button)
	new_word_button.add_theme_font_size_override("font_size", 16)
	new_word_button.type = "Prompt"
