extends Control

class_name StageThreeController

signal button_state_dict_set
signal to_vdt_manager

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
@onready var vdt_manager: VDTManager = $VDTLayer/VisualDataTrainManager
@onready var real_user_satisfaction_manager = $RealUserSatisfactionManager
@onready var in_game_clock = $ClockLayer/AnimationPlayer/Clock
@onready var special_commands_handler: SpecialCommandsHandler = $SpecialCommandsHandler


var selected_goal: String
var button_state_dictionary: Dictionary 

@export_range(1,10,1) var level: int = 1
@export var number_of_options: int = 5

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("A"):
		_relay_to_vdt_manager("generator to prompt", "testing")

func _ready():
	pass

func _relay_between_convo_pres_and_special_actions():
	special_commands_handler._on_prompt_displayed_or_new_passive_ready()

func get_real_user_satisfaction():
	return real_user_satisfaction_manager.user_satisfaction

func get_user_satisfaction_threshold():
	var active_prompt: Dictionary = prompt_manager.active_prompt_entry
	print(active_prompt)
	var user_sat_dict = active_prompt["UserSatisfaction"]
	var user_sat: float = user_sat_dict["Threshold"]
	if active_prompt.has("UserSatisfaction") == false: #this condition doesnt work, change to set the prompt to a variable
		print(active_prompt)
		return null
	return user_sat #will cause crashes if called where there is none

func get_passed_user_satisfaction():
	var real_user_satisfaction: int = get_real_user_satisfaction()
	if real_user_satisfaction == null:
		return true # if there is no user satisfaction entry, most likely is a non-end day prompt using this, will just continue on
	print("this is active prompt: ", prompt_manager.active_prompt_entry)
	var user_satisfaction_threshold: float = get_user_satisfaction_threshold()
	user_satisfaction_threshold = user_satisfaction_threshold * 100
	print("this is r user sat vs user sat xp: ", real_user_satisfaction, "< ", user_satisfaction_threshold)
	if real_user_satisfaction < user_satisfaction_threshold:
		return false
	else:
		return true

func _on_prompt_response_prompt_end():
	var is_end_day: bool = prompt_manager.get_end_day_bool()
	var time_to_add_minutes: int = prompt_manager.get_time_to_add()
	if is_end_day:
		if get_passed_user_satisfaction() == true:
			real_user_satisfaction_manager._reset_user_satisfaction()
			in_game_clock._end_day()
			await in_game_clock.time_passed
			convo_presenter._clear_prompts()
			await in_game_clock.day_ended
		else:
			in_game_clock._let_time_pass("minute", 120) #just some random amount of time to the review
			await in_game_clock.time_passed
			prompt_manager._launch_new_prompt(true) 
			return
	elif !is_end_day:
		in_game_clock._let_time_pass("minute", time_to_add_minutes)
		await in_game_clock.time_passed
	prompt_manager._launch_new_prompt()

func _set_button_state_dict():
	for child in get_children():
		if child is Button:
			var button_name: String = child.name
			button_state_dictionary[button_name] = child.disabled
	button_state_dictionary["OptionsManager"] = options_manager.buttons_are_disabled
	button_state_dictionary["ResponseOptions"] = response_selection_menu.buttons_are_disabled
	print("this is controller's button dict: ", button_state_dictionary)
	emit_signal("button_state_dict_set")

func _disable_all_buttons():
	_set_button_state_dict()
	await button_state_dict_set
	generate_response_button.disabled = true
	erase_button.disabled = true
	send_response_button.disabled = true
	options_manager._disable_all_buttons()
	response_selection_menu._disable_all_word_buttons() #just enabling and disabling these may cause sequence issues, you've saved og in the dict, but dont want to use as reference because definite sequence break

func _return_all_buttons_to_state():
	for child in get_children():
		if child is Button:
			var button_name: String = child.name
			child.disabled = button_state_dictionary[button_name]
	options_manager._enable_all_buttons()
	response_selection_menu._enable_all_word_buttons()


func _on_prompt_displayed():
	var all_goals: Array = response_selection_menu.button_node_array
	for i in all_goals.size():
		var relaying_string: String = response_selection_menu.get_next_invisible_word()
		if relaying_string == "":
			print("returning from on prompt displayed function: ", i)
			return
		_relay_to_vdt_manager("prompt to goals", relaying_string)
		await vdt_manager.end_of_the_line_prompt_to_goals
		print("post end of line prompt to goals received by s3 cont")
		response_selection_menu._show_word_by_text(relaying_string)

func _relay_to_vdt_manager(target_path: String, relaying_string_data: String):
	vdt_manager._handle_relay(target_path, relaying_string_data)

func _send_prompt(prompt_entry: Dictionary, from_failure: bool = false):
	var prompt_text: String = prompt_entry["PromptString"]
	if !from_failure:
		var prompt_goals_entries: Array = prompt_entry["Goals"]
		var prompt_goals_strings: Array[String]
		associations_manager._generate_cosine_similarity_array(prompt_entry)
		for entry in prompt_goals_entries:
			prompt_goals_strings.append(entry.keys()[0])
		response_selection_menu._import_items(prompt_goals_strings) # can just test this out with the text for the goals sent
	else:
		
		var booty #here you need to unpack all of the engineering special commands via their entry
	convo_presenter._handle_prompt(prompt_text)

func _handle_engineering_prompt(prompt_entry: Dictionary):
	var word_association_changes: Dictionary = prompt_entry["WordAssociationChanges"]
	associations_manager._handle_engineering_changes(word_association_changes)

func _send_response_data(response_entry: Dictionary, goals_array: Array):
	var selected_index: int = response_selection_menu.selected
	var selected_generation_goal: String = response_selection_menu.get_item_text(selected_index)
	goal_tally_controller._add_goal_tally(selected_generation_goal) 
	response_gen_output._set_response_entry(response_entry, goals_array)
	var text: String = "decoding..."
	call_deferred("_relay_to_vdt_manager", "generator to options1", text)
	await vdt_manager.end_of_the_line_generator_to_options1
	options_manager._generate_word_buttons(associations_manager.get_word_to_prompt_similarity_entry_array(number_of_options))
	options_manager._enable_all_buttons()
	erase_button.disabled = false

#func _continue_response():
	#response_gen_output

func _on_send_response_button_pressed() -> void:
	var threshold: int = confidence_manager.confidence_requirement * 100
	var current_confidence: int = int(confidence_manager.my_rtl.text)
	if current_confidence < threshold:
		confidence_manager._does_not_meet_confidence_threshold_behaviour()
		return
	goal_tally_controller._reset_goals_tally()
	_switch_send_button_disabled()
	if !erase_button.disabled:
		_switch_erase_button_disabled()
	var candidate_text: String = response_gen_output.my_rtl.text
	var data_for_passive_prompt: Array = response_gen_output.send_data_for_passive_prompt_generation()
	prompt_manager._generate_passive_prompt(data_for_passive_prompt[0],data_for_passive_prompt[1],response_manager.active_response_id, data_for_passive_prompt[2],data_for_passive_prompt[3])
	call_deferred("_relay_to_vdt_manager", "generator to prompt", "to_user") #above doesnt need to be deferred because it takes time for vdt word node to get to station
	await vdt_manager.end_of_the_line_generator_to_prompt
	convo_presenter._handle_response(candidate_text)
	response_gen_output._reset_all()
	options_manager._on_send_clicked()
	response_selection_menu._clear_items()
	erase_button.disabled = true

func _send_passive_prompt(passive_prompt: String):
	convo_presenter.passive_prompt_text = passive_prompt

func _on_word_clicked(word: String, sim_value: float):
	call_deferred("_relay_to_vdt_manager", "options2 to probability label", word)
	await vdt_manager.end_of_the_line_options2_to_probability_label
	response_gen_output.call_deferred("_handle_word_clicked", word)  #_handle_word_clicked(word)
	await response_gen_output.new_word_set
	print("this is s3 controller end of word clicked func")
	confidence_manager._on_word_clicked(sim_value)
	print("this is get ready for word: ", response_gen_output.get_ready_for_word())
	erase_button.disabled = false
	if response_gen_output.get_ready_for_word():
		options_manager._enable_all_buttons()

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

func _receive_hidden_goal_values(acceptability: String, chosen_words_array: Array[Dictionary], response_id: String, response_section_id: String): 
	match acceptability: #covers for any flaw in the acceptability logic to progress game forward
		"acceptable":
			acceptability = acceptability
		"unacceptable":
			acceptability = acceptability
		"unintelligible":
			acceptability = acceptability
		"partially_unintelligible":
			acceptability = acceptability
		_:
			acceptability = "acceptable"
	real_user_satisfaction_manager._amend_user_satisfaction(acceptability, chosen_words_array)
	prompt_manager._generate_passive_prompt(acceptability, chosen_words_array, response_id, response_section_id)

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
	var item_text: String = response_selection_menu.get_item_text(index)
	call_deferred("_relay_to_vdt_manager","goals1 to generator", item_text)
	call_deferred("_relay_to_vdt_manager", "goals2 to US label", item_text)
	await vdt_manager.end_of_the_line_goals1_to_generator
	response_gen_output.selected_goal = item_text
	selected_goal = response_selection_menu.get_item_text(index)
	response_selection_menu._enable_all_word_buttons()
	if generate_response_button.disabled == true:
		_switch_generate_button_disabled()


func _on_erase_section_button_pressed() -> void:
	response_gen_output.call_deferred("_handle_erase_section")
	var remove_words_goal_array: Array[Variant] = await response_gen_output.erasing
	print(remove_words_goal_array)
	var number_of_words_to_remove: int = remove_words_goal_array[0]
	var goal_removed: String = remove_words_goal_array[1]
	confidence_manager._on_erase_section(number_of_words_to_remove)
	print("ERASE WORKED")
