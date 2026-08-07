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

func _end_prototype():
	get_tree().change_scene_to_packed(end_screen)

func _on_confirm_clicked(): #sloppy should probably refactor but aw well
	var active_id: String = excerpt_controller.active_excerpt_id
	var answers_array: Array = excerpt_controller.inserted_words
	var expected_answers: Array = excerpt_controller.excerpts_dict[active_id]["WordsToReplace"]
	var answers_theme_values_array: Array
	if answers_array.size() != expected_answers.size():
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
	associations_handler._activate_themes(excerpt_themes)
	net_graph_viewport._call_graph(answers_array, answers_theme_values_array) #doesnt add new words generated from most recent confirmation, need to send word data from confirm click
	excerpt_controller._setup_active_excerpt()

func _on_neural_net_clicked():
	pass

func _on_new_excerpt_presented(excerpt: Dictionary):
	options_controller._generate_random_word_buttons(excerpt["WordsToReplace"])

func _on_remove_last_clicked():
	var word_to_delete: String = excerpt_controller.last_inserted_word
	if word_to_delete == "":
		return
	excerpt_controller.delete_word_input(word_to_delete)

func _on_word_clicked(word_clicked: String):
	excerpt_controller._insert_selected_word(word_clicked)


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
