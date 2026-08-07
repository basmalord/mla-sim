extends Control

signal response_set
signal section_displayed
signal waiting_for_advance

@onready var my_container: Container = $ResponseOutputContainer
@onready var my_rtl: RichTextLabel = $ResponseOutputContainer/ResponseOutputRTL
@onready var intro_generator: Node = $IntroSectionGenerator
@onready var my_controller: Control = get_parent()

@export_range(0,4,1) var section_index: int = 0

var response_entry: Dictionary
var prompt_goals: Array
var selected_goal: String

func _ready() -> void:
	if my_controller is Control:
		connect("section_displayed", Callable(my_controller, "_switch_send_button_disabled"))
	#connect("response_set", Callable(self, "_advance_section"))
	#connect("response_set", Callable(self, "_display_section"))

func _advance_section():
	_display_section()
	emit_signal("waiting_for_advance")
	print("WAITING FIRED")
	await section_displayed
	print("POST WAITING FIRED")
	if section_index == 4:
		section_index = 0
		return
	section_index += 1
	print("BOGOOSOSOS", section_index)

func _display_section():
	my_rtl.text = get_response_string() #need a different animation compared to the prompt output
	print("WANT WAITING FIRED TO FIRE")
	await waiting_for_advance
	await get_tree().create_timer(0.06).timeout
	emit_signal("section_displayed")

func get_response_string() -> String:
	var new_text: String
	if section_index == 0:
		new_text = intro_generator.generate_intro_string(prompt_goals)
		print("NANNY", section_index)
		return new_text
	if !response_entry.has("ResponseSections"):
		print("BOOOO")
		return ""
	var response_sections_array: Array = response_entry["ResponseSections"].keys()
	if (response_sections_array.size() - 1) < section_index:
		print("BOZO")
		return ""
	var target_section: Dictionary = response_entry["ResponseSections"][response_sections_array[section_index]]
	new_text = target_section["ResponseString"]
	return new_text

func _set_response_entry(candidate_entry: Dictionary, goals_array: Array):
	response_entry = candidate_entry
	prompt_goals = goals_array
	emit_signal("response_set")
	_advance_section()
