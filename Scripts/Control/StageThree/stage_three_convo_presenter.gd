extends Control

signal type_animation_finished

const convo_container: PackedScene = preload("res://Scenes/Stages/StageThree/convo_container.tscn")

@export_range(0.00,1.00,0.01) var typed_letter_delay: float = 1.00

@onready var my_container: Container = $ScrollContainer/ConvoPresenterMainContainer
@onready var my_texture_rect: TextureRect = $TextureRect
@onready var my_controller: Control = get_parent()

var my_rtl: RichTextLabel
var converstaion_is_active: bool = false
var my_text: String

func _ready() -> void:
	if my_controller is Control:
		connect("type_animation_finished", Callable(my_controller, "_switch_generate_button_disabled"))

func _set_rtl_text(candidate_text: String):
	my_rtl.text = candidate_text

func _append_rtl_text(candidate_text: String):
	_type_out_characters(candidate_text)

func generate_new_rtl():
	var new_container = convo_container.instantiate()
	my_container.add_child(new_container)
	my_rtl = new_container.my_rtl

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

func _type_out_characters(candidate_text: String):
	var old_count := my_rtl.get_total_character_count()
	my_rtl.visible_characters = old_count
	my_rtl.append_text(candidate_text)
	var new_count := my_rtl.get_total_character_count()
	while my_rtl.visible_characters < new_count:
		my_rtl.visible_characters += 1
		await get_tree().create_timer(typed_letter_delay).timeout
	emit_signal("type_animation_finished")
