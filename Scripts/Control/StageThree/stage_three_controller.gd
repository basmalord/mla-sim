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
@onready var user_goals_manager: Node = $UserGoalsManager
@onready var user_satisfaction_manager: Control = $UserSatisfactionManager
@onready var confidence_manager: Control = $ConfidenceManager
@onready var goal_tally_controller: Node = $GoalsTally
@onready var user_profile_manager: Node = $StageThreeUserManager
@onready var erase_button: Button = $EraseSectionButton


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
	var selected_index: int = response_selection_menu.selected
	var selected_generation_goal: String = response_selection_menu.get_item_text(selected_index)
	goal_tally_controller._add_goal_tally(selected_generation_goal)
	response_gen_output._set_response_entry(response_entry, goals_array)
	options_manager._generate_word_buttons(associations_manager.get_word_to_prompt_similarity_entry_array(number_of_options))

#func _continue_response():
	#response_gen_output

func _on_send_response_button_pressed() -> void:
	goal_tally_controller._reset_goals_tally()
	_switch_send_button_disabled()
	if !erase_button.disabled:
		_switch_erase_button_disabled()
	var candidate_text: String = response_gen_output.my_rtl.text
	convo_presenter._handle_response(candidate_text)
	response_gen_output._reset_all()
	options_manager._on_send_clicked()
	response_selection_menu._clear_items()

func _on_word_clicked(word: String, sim_value: float):
	response_gen_output._handle_word_clicked(word)
	await response_gen_output.new_word_set
	confidence_manager._on_word_clicked(sim_value)

func _switch_response_selection_menu_disabled():
	if response_selection_menu.disabled:
		response_selection_menu.disabled = false
	else:
		response_selection_menu.disabled = true

func _switch_send_button_disabled(is_last_section: bool = true):
	if !is_last_section:
		send_response_button.disabled = true
		return
	if send_response_button.disabled:
		send_response_button.disabled = false
	else:
		send_response_button.disabled = true

func _flash_switch_generate_button_disabled():
	_switch_generate_button_disabled()
	await get_tree().create_timer(1).timeout
	_switch_generate_button_disabled()

func _switch_generate_button_disabled():
	if generate_response_button.disabled:
		generate_response_button.disabled = false
	else:
		generate_response_button.disabled = true

func _switch_erase_button_disabled(enable: bool = false):
	if !enable:
		erase_button.disabled = true
	else:
		erase_button.disabled = false

func _receive_goals(goals: Array, number_of_sections: int, from_prompt: bool = false):
	if from_prompt:
		print("introduce goals firing from controller")
		user_goals_manager._introduce_goals(goals)
	else:
		var new_goals_dict: Dictionary
		new_goals_dict["Sections"] = number_of_sections
		var goal_tally = goal_tally_controller.goals_tally
		for entry in goals:
			var goal = entry.keys()[0]
			if goal_tally.has(goal):
				new_goals_dict[goal] = goal_tally_controller.goals_tally[goal]
			else:
				new_goals_dict[goal] = 0
		user_goals_manager._handle_goals(new_goals_dict)
		await user_goals_manager.goals_handled
		user_satisfaction_manager._display_new_user_satisfaction(new_goals_dict)
		return

func _on_response_options_item_selected(index: int) -> void:
	response_gen_output.selected_goal = response_selection_menu.get_item_text(index)
	selected_goal = response_selection_menu.get_item_text(index)
	if generate_response_button.disabled == true:
		_switch_generate_button_disabled()


func _on_erase_section_button_pressed() -> void:
	response_gen_output._handle_erase_section()
	var remove_words_goal_array: Array[Variant] = await response_gen_output.erasing
	var number_of_words_to_remove: int = remove_words_goal_array[0]
	var goal_removed: String = remove_words_goal_array[1]
	confidence_manager._on_erase_section(number_of_words_to_remove)
	print("ERASE WORKED")
