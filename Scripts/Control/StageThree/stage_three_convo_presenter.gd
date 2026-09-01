extends Control

signal type_animation_finished
signal prompt_displayed
signal passive_prompt_displayed
signal passive_prompt_about_to_be_handled
signal just_before_typing
signal tutorial_marker 


const convo_container: PackedScene = preload("res://Scenes/Stages/StageThree/convo_container.tscn")
const user_typing_button: PackedScene = preload("res://Scenes/Stages/StageThree/user_typing_button.tscn")

var response_type_letter_delay: float = 0.05
@export_range(0.00,1.00,0.01) var typed_letter_delay: float = 0.05
@export var my_font: FontFile
@export_range(0,50,1) var my_font_size: int 
@export_range(0,50,1) var my_line_height: int
@export_range(0,1,0.1) var user_disconnected_timing: float = 1.00
@export_range(0,1,0.1) var user_typing_timing: float = 1.00

@onready var my_scroll: ScrollContainer = $ScrollContainer
@onready var my_container: Container = $ScrollContainer/ConvoPresenterMainContainer
@onready var my_controller: Control = get_parent()

var my_rtl: RichTextLabel
var converstaion_is_active: bool = false
var my_text: String
var passive_prompt_text: String = ""
var typing: bool = false
var tutorial_active: bool = false


func _ready() -> void:
	if my_controller is Control:
		#connect("type_animation_finished", Callable(my_controller, "_switch_generate_button_disabled"))
		connect("type_animation_finished", Callable(my_controller, "_switch_response_selection_menu_disabled"))
		connect("prompt_displayed", Callable(my_controller, "_on_prompt_displayed"))


func _clear_prompts():
	for child in my_container.get_children():
		child.queue_free()
	my_scroll.scroll_vertical = my_scroll.get_v_scroll_bar().max_value

func _set_rtl_text(candidate_text: String):
	my_rtl.text = candidate_text

func _append_rtl_text(candidate_text: String, from_tutorial: bool = false, from_response: bool = false):
	_type_out_characters(candidate_text, from_tutorial, from_response)

func generate_new_rtl():
	var new_container = convo_container.instantiate()
	my_container.add_child(new_container)
	my_rtl = new_container.my_rtl
	my_rtl.add_theme_font_override("normal_font", my_font)
	my_rtl.add_theme_font_size_override("normal_font_size", my_font_size)
	my_rtl.add_theme_constant_override("line_separation", my_line_height)
	print("this is my font: ", my_rtl.get_theme_font("normal_font"))
	await get_tree().process_frame
	my_scroll.scroll_vertical = my_scroll.get_v_scroll_bar().max_value

func _handle_prompt(candidate_text: String, passive_prompt: bool = false):
	if !passive_prompt:
		var new_user_typing_button = await generate_user_typing_button("User typing", true, true, false)
		my_scroll.scroll_vertical = my_scroll.get_v_scroll_bar().max_value
		await new_user_typing_button.pressed
	await get_tree().create_timer(0.08).timeout
	generate_new_rtl()
	if my_rtl.text == "":
		converstaion_is_active = false
	else:
		converstaion_is_active = true
	emit_signal("just_before_typing")
	typing = true
	_append_rtl_text(candidate_text)
	await type_animation_finished
	typing = false
	if passive_prompt:
		print("passive prompt baby")
		emit_signal("passive_prompt_about_to_be_handled")
		#my_controller._relay_between_convo_pres_and_special_actions()
		_handle_passive_prompt()
		return
	my_controller._relay_between_convo_pres_and_special_actions()
	emit_signal("prompt_displayed")
	#_handle_passive_prompt()
	#my_controller._relay_to_vdt_manager()

func _handle_passive_prompt():
	var is_end_day: bool = my_controller.prompt_manager.get_end_day_bool()
	var new_user_typing_button 
	if is_end_day:
		print("handling passive prompt via generating typing button for disconnect")
		new_user_typing_button = await generate_user_typing_button("User disconnected")
	elif !is_end_day:
		print("handling passive prompt via generating typing button for user typing")
		new_user_typing_button = await generate_user_typing_button()


func _call_prompt_manager_for_next_prompt():
	print("waiting from the call prompt manager for next from the convo presenter")
	
	if my_controller.final_tutorial_step == false:
		await just_before_typing#need to go to prompt manager to redefine the launch new prompt function so that it goes from the prompt itself, eliminating friction now that we have the passive prompt from the response sections.
	if typing:
		await type_animation_finished
	my_controller._on_prompt_response_prompt_end()

func proceed_with_tutorial(typing_button_reference: UserTypingButton):
	print("start of the tutorial proceed func")
	await typing_button_reference.pressed
	generate_new_rtl()
	await get_tree().create_timer(0.08).timeout
	_type_out_characters(passive_prompt_text)
	emit_signal("tutorial_marker")

func generate_user_typing_button(text_to_add: String = "", animate: bool = true, flash: bool = true, prompt_launchable: bool = true):
	var new_typing_button = user_typing_button.instantiate()
	my_container.add_child(new_typing_button)
	if tutorial_active:
		proceed_with_tutorial(new_typing_button)
		tutorial_active = false
	if text_to_add != "":
		new_typing_button.text = text_to_add
	await get_tree().process_frame
	my_scroll.scroll_vertical = my_scroll.get_v_scroll_bar().max_value
	if animate:
		new_typing_button.animate_elipses()
	if flash:
		new_typing_button._flash_button()
	if prompt_launchable:
		print("this new typing button is connected")
		new_typing_button.connect("pressed", Callable(self, "_call_prompt_manager_for_next_prompt"))
	return new_typing_button

func _handle_response(candidate_text: String):
	if my_controller.generate_response_button.disabled == false:
		my_controller._switch_generate_button_disabled()
	generate_new_rtl()
	if my_rtl.text == "":
		converstaion_is_active = false
	else:
		converstaion_is_active = true
	if converstaion_is_active:
		candidate_text = "\n\n\n\n" + candidate_text
	emit_signal("just_before_typing")
	typing = true
	_append_rtl_text(candidate_text, false, true)
	await type_animation_finished
	typing = false
	if passive_prompt_text != "":
		_handle_prompt(passive_prompt_text, true)
	else:
		generate_user_typing_button("User disconnected") # strange catch here, not really sure what to do if there isnt the passive prompt

func _type_out_characters(candidate_text: String, from_tutorial: bool = false, from_response: bool = false):
	var letter_delay = typed_letter_delay
	if from_response:
		letter_delay = response_type_letter_delay
	if !from_response:
		my_controller._play_keyboard()
	var old_count
	if from_tutorial:
		old_count = 0
	else:
		old_count = my_rtl.get_total_character_count()
	my_rtl.visible_characters = old_count
	my_rtl.append_text(candidate_text)
	var new_count := my_rtl.get_total_character_count()
	while my_rtl.visible_characters < new_count:
		my_rtl.visible_characters += 1
		await get_tree().create_timer(letter_delay).timeout
	emit_signal("type_animation_finished")
	if !from_response:
		my_controller._stop_keyboard()
