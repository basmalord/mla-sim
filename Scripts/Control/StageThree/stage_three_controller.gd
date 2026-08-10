extends Control

class_name StageThreeController

@onready var convo_presenter: Control = $StageThreeConvoPresenter
@onready var prompt_manager: Node = $StageThreePromptManager
@onready var response_gen_output: Control = $StageThreeResponseGenOutput
@onready var response_manager: Node = $StageThreeResponseManager
@onready var generate_response_button: Button = $GenerateResponseButton
@onready var send_response_button: Button = $SendResponseButton
@onready var response_selection_menu: OptionButton = $ResponseOptions
@onready var associations_manager: Node = $AssociationsManager
@onready var options_manager: Control = $OptionsManager
var selected_goal: String

@export_range(1,10,1) var level: int = 1
@export var number_of_options: int = 5

func _send_prompt(prompt_entry: Dictionary):
	var prompt_text: String = prompt_entry["PromptString"]
	var prompt_goals_entries: Array = prompt_entry["Goals"]
	var prompt_goals_strings: Array[String]
	associations_manager._generate_cosine_similarity_array(prompt_entry)
	for entry in prompt_goals_entries:
		prompt_goals_strings.append(entry.keys()[0])
	response_selection_menu._import_items(prompt_goals_strings)
	convo_presenter._handle_prompt(prompt_text)

func _send_response_data(response_entry: Dictionary, goals_array: Array):
	response_gen_output._set_response_entry(response_entry, goals_array)
	options_manager._generate_word_buttons(associations_manager.get_word_to_prompt_similarity_entry_array(number_of_options))

#func _continue_response():
	#response_gen_output

func _on_send_response_button_pressed() -> void:
	_switch_send_button_disabled()
	var candidate_text: String = response_gen_output.my_rtl.text
	convo_presenter._handle_response(candidate_text)

func _on_word_clicked(word: String, sim_value: float):
	print(word, sim_value)

func _switch_response_selection_menu_disabled():
	if response_selection_menu.disabled:
		response_selection_menu.disabled = false
	else:
		response_selection_menu.disabled = true

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


func _on_response_options_item_selected(index: int) -> void:
	if index == 0:
		return
	else:
		if generate_response_button.disabled == true:
			response_gen_output.selected_goal = response_selection_menu.get_item_text(index)
			selected_goal = response_selection_menu.get_item_text(index)
			_switch_generate_button_disabled()
