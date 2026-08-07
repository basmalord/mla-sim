extends Control

class_name StageThreeController

@onready var convo_presenter: Control = $StageThreeConvoPresenter
@onready var prompt_manager: Node = $StageThreePromptManager
@onready var response_gen_output: Control = $StageThreeResponseGenOutput
@onready var response_manager: Node = $StageThreeResponseManager
@onready var generate_response_button: Button = $GenerateResponseButton
@onready var send_response_button: Button = $SendResponseButton

@export_range(1,10,1) var level: int = 1

func _send_prompt(prompt_entry: Dictionary):
	var prompt_text: String = prompt_entry["PromptString"]
	convo_presenter._handle_prompt(prompt_text)

func _send_response_data(response_entry: Dictionary, goals_array: Array):
	response_gen_output._set_response_entry(response_entry, goals_array)


func _on_send_response_button_pressed() -> void:
	_switch_send_button_disabled()
	var candidate_text: String = response_gen_output.my_rtl.text
	convo_presenter._handle_response(candidate_text)

func _switch_send_button_disabled():
	if send_response_button.disabled:
		send_response_button.disabled = false
	else:
		send_response_button.disabled = true

func _switch_generate_button_disabled():
	if generate_response_button.disabled:
		generate_response_button.disabled = false
	else:
		generate_response_button.disabled = true
