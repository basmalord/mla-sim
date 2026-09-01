extends Control

class_name StageTwoController

const end_screen:= preload("res://Scenes/AdHoc/play_test_end_screen.tscn")

@onready var confirm_button: Button= $UIController/ConfirmButton
@onready var excerpt_controller: Control = $ExcerptController
@onready var options_controller: Control = $OptionsController
@onready var points_controller: Control = $PointsController
@onready var associations_handler: Node = $AssociationsHandler
@onready var net_graph_viewport: SubViewportContainer = $ClusterSubViewContainer
@onready var output_label: RichTextLabel = $StageTwoOutputLabel
@onready var dynamic_label_controller: Control = $DynamicLabelController
@onready var success_and_failure_sounds: AudioStreamPlayer = $SuccessAndFailureSounds
@onready var input_sounds: AudioStreamPlayer = $StageTwoAudioManager


func _end_stage():
	var my_root: Node = get_parent()
	print(my_root)
	my_root._play_test_s_2_complete()

func _end_prototype():
	get_tree().change_scene_to_packed(end_screen)

func _failure_behaviour(answers_array: Array, expected_answers: Array):
	dynamic_label_controller._on_failure()
	excerpt_controller._on_failure()
	if success_and_failure_sounds.playing == false:
		success_and_failure_sounds._play_sound_by_id("failure")
	#let the player know they failed and why (i.e: 'answers do not match training data'), let them know that the process is restarting (i.e: 'reprocessing training instance'),
	#then provide space for some animation or something to link the failure to the restarting

func _completed_stage_behaviour():
	pass

func _success_behaviour():
	dynamic_label_controller._on_success()
	if success_and_failure_sounds.playing == false:
		success_and_failure_sounds._play_sound_by_id("success")

func _make_string_array_to_lower(string_array: Array):
	var to_lower_string_array: Array[String]
	for string in string_array:
		to_lower_string_array.append(string.to_lower())
	return to_lower_string_array

func _on_confirm_clicked(): #can keep all of this here, just need a condition to check if they were the correct answers
	var active_id: String = excerpt_controller.active_excerpt_id
	var answers_array: Array = excerpt_controller.inserted_words
	var expected_answers: Array = excerpt_controller.excerpts_dict[active_id]["WordsToReplace"]
	var answers_theme_values_array: Array
	if answers_array.size() != expected_answers.size():
		input_sounds._play_sound_by_id("keyboard_button", true)
		return
	input_sounds._play_sound_by_id("keyboard_button")
	var to_lower_expected_answers: Array[String]
	var to_lower_answers: Array[String]
	for answer in answers_array:
		to_lower_answers.append(answer.to_lower())
	for answer in expected_answers:
		to_lower_expected_answers.append(answer.to_lower())
	for answer in to_lower_answers:
		var index: int = to_lower_answers.find(answer)
		if to_lower_answers[index] != to_lower_expected_answers[index]:
			_failure_behaviour(answers_array, expected_answers)
			return
	for i in answers_array.size():
		answers_array[i] = answers_array[i].to_lower()
	var id_answers_dict: Dictionary = {active_id: answers_array}
	associations_handler._handle_answers(id_answers_dict)
	for answer in answers_array:
		var word_dict_entry: Dictionary = associations_handler.word_dict[answer]
		answers_theme_values_array.append(word_dict_entry)
	excerpt_controller._mutate_excerpt_themes_values(active_id,answers_theme_values_array)
	var excerpt_themes: Dictionary = excerpt_controller.excerpts_dict[active_id]["Themes"]
	_success_behaviour()
	associations_handler._activate_themes(excerpt_themes)
	net_graph_viewport._call_graph(answers_array, answers_theme_values_array) #doesnt add new words generated from most recent confirmation, need to send word data from confirm click
	excerpt_controller._setup_active_excerpt()


func _on_neural_net_clicked():
	pass

func _on_new_excerpt_presented(excerpt: Dictionary):
	print("got to on new presented")
	options_controller._generate_random_word_buttons(excerpt["WordsToReplace"])

func _on_remove_last_clicked():
	var word_to_delete: String = excerpt_controller.last_inserted_word
	if word_to_delete == "":
		input_sounds._play_sound_by_id("back_button", true)
		return
	input_sounds._play_sound_by_id("back_button")
	excerpt_controller.delete_word_input(word_to_delete)

func _on_word_clicked(word_clicked: String):
	var is_space: bool = excerpt_controller._insert_selected_word(word_clicked)
	if is_space == true:
		input_sounds._play_sound_by_id("keyboard_button")
	else:
		input_sounds._play_sound_by_id("keyboard_button", true)


func _on_excerpt_finished_processing(word_clicked: String):
	var active_excerpt_entry: Dictionary = excerpt_controller.get_active_excerpt_entry()
	var active_entry_id: String = excerpt_controller.active_excerpt_id
	var word_entry: Dictionary 
	if associations_handler.word_dict.has(word_clicked):
		word_entry = associations_handler.word_dict[word_clicked]
	else:
		word_entry = {word_clicked: 0}
	output_label._on_word_selection(active_excerpt_entry, word_entry, active_entry_id, word_clicked)

func _on_net_graph_pressed() -> void:
	if net_graph_viewport.is_visible_in_tree():
		net_graph_viewport.hide()
		return
	net_graph_viewport.show()
