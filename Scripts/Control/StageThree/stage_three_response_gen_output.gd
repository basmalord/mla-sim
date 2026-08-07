extends Control

signal response_set
signal section_displayed


@onready var my_container: Container = $ResponseOutputContainer
@onready var my_rtl: RichTextLabel = $ResponseOutputContainer/ResponseOutputRTL
@onready var intro_generator: Node = $IntroSectionGenerator
@onready var my_controller: Control = get_parent()

@export_range(0,4,1) var section_index: int = 0

var response_entry: Dictionary
var prompt_goals: Array

func _ready() -> void:
	if my_controller is Control:
		connect("section_displayed", Callable(my_controller, "_switch_send_button_disabled"))
	#connect("response_set", Callable(self, "_advance_section"))
	#connect("response_set", Callable(self, "_display_section"))

func _advance_section():
	_display_section()
	await section_displayed
	if section_index == 4:
		section_index = 0
		return
	section_index += 1

func _display_section():
	my_rtl.text = get_response_string() #need a different animation compared to the prompt output
	emit_signal("section_displayed")

func get_response_string() -> String:
	var new_text: String
	if section_index == 0:
		new_text = intro_generator.generate_intro_string(prompt_goals)
		return new_text
	if !response_entry.has(str(section_index)):
		return ""
	new_text = response_entry[str(section_index)]["ResponseString"]
	return new_text

func _set_response_entry(candidate_entry: Dictionary, goals_array: Array):
	response_entry = candidate_entry
	prompt_goals = goals_array
	emit_signal("response_set")
	_advance_section()
