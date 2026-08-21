extends Control

signal type_animation_finished

const convo_container: PackedScene = preload("res://Scenes/Stages/StageThree/convo_container.tscn")

@export_range(0.00,1.00,0.01) var typed_letter_delay: float = 1.00
@export var my_font: FontFile
@export_range(0,50,1) var my_font_size: int 
@export_range(0,50,1) var my_line_height: int


@onready var my_scroll: ScrollContainer = $ScrollContainer
@onready var my_container: Container = $ScrollContainer/ConvoPresenterMainContainer
@onready var my_controller: Control = get_parent()

var my_rtl: RichTextLabel
var converstaion_is_active: bool = false
var my_text: String

func _ready() -> void:
	if my_controller is Control:
		#connect("type_animation_finished", Callable(my_controller, "_switch_generate_button_disabled"))
		connect("type_animation_finished", Callable(my_controller, "_switch_response_selection_menu_disabled"))

func _set_rtl_text(candidate_text: String):
	my_rtl.text = candidate_text

func _append_rtl_text(candidate_text: String):
	_type_out_characters(candidate_text)

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

func _handle_prompt(candidate_text: String):
	generate_new_rtl()
	if my_rtl.text == "":
		converstaion_is_active = false
	else:
		converstaion_is_active = true
	_append_rtl_text(candidate_text)

func _handle_response(candidate_text: String):
	generate_new_rtl()
	if my_rtl.text == "":
		converstaion_is_active = false
	else:
		converstaion_is_active = true
	if converstaion_is_active:
		candidate_text = "\n\n\n\n" + candidate_text
	_append_rtl_text(candidate_text)
	await type_animation_finished
	my_controller.prompt_manager._launch_new_prompt(my_controller.response_manager.get_next_prompt())
	my_controller._switch_generate_button_disabled()

func _type_out_characters(candidate_text: String):
	var old_count := my_rtl.get_total_character_count()
	my_rtl.visible_characters = old_count
	my_rtl.append_text(candidate_text)
	var new_count := my_rtl.get_total_character_count()
	while my_rtl.visible_characters < new_count:
		my_rtl.visible_characters += 1
		await get_tree().create_timer(typed_letter_delay).timeout
	emit_signal("type_animation_finished")
