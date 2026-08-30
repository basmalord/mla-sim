extends Control

class_name StageOneController

signal correctness_array_generated(correctness_array: Array[String])

var answer_label_og_position: Vector2i
var correct_given: bool = false
var last_guess_wrong: bool = false

@onready var input_present_container: GridContainer = $InputPresentContainer
@onready var answer_manager: Node = $StageOneAnswerManager
@onready var answer_label: Label = $AnswerLabel
@onready var animated_bg_image: ProgressBar = $AnimatedBGImage/TextureProgressBar
@onready var progress_label: Label = $DictProgressIndicatorLabel
@onready var audio_manager: AudioStreamPlayer = $StageOneAudioManager
@onready var history_grid: GridContainer = $ScrollContainer/TokenisationHistoryContainer
@onready var history_grid_two: GridContainer = $ScrollContainer2/TokenisationHistoryContainer

var waiting_to_duplicate: bool = false
var debug: bool = false

func _ready():
	answer_label_og_position = answer_label.position
	print("this is debug:", debug)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("CONFIRM"):
		_confirm_pressed()
		_next_pressed()
	if Input.is_action_just_pressed("DELETE"):
		_letter_removed()

func _switch_waiting_to_duplicate():
	if waiting_to_duplicate:
		waiting_to_duplicate = false
	else:
		waiting_to_duplicate = true

func _letter_clicked(input_button: InputButton):
	input_button._make_self_unclickable()
	var button_text = input_button.text 
	input_present_container._set_active_row_string(button_text)

func _letter_removed():
	input_present_container._remove_last_letter()

func _confirm_pressed():
	await get_tree().create_timer(0.06).timeout
	if input_present_container.get_active_row_string().contains("_"):
		print("cant do this 2")
		return #space for some behaviour to indicate that you need to enter more letters
	if input_present_container.active_row == "Row6" or input_present_container.active_row == "Row7" or input_present_container.active_row == "Row8":
		print("cant do this 3")
		return
	answer_manager._confirm_button_pressed(input_present_container.get_active_row_string())
	var correctness_array: Array[String] = await correctness_array_generated
	if correctness_array.is_empty():
		print("correct_array is empty")
		return
	if correctness_array == ["correct", "correct", "correct", "correct", "correct"]: 
		print("confirm pressed and correct")
		#get_parent()._s1_correct_behaviour()
		#answer_label.text = answer_manager.active_answer.to_upper() + "!"
		correct_given = true
		animated_bg_image.value += 25 #value needs to be added to save data
		$ConfirmButton.hide()
		$ConfirmButton.process_mode = Node.PROCESS_MODE_DISABLED
		$NextButton.show()
		$NextButton.process_mode = Node.PROCESS_MODE_PAUSABLE
		input_present_container._set_row_themes(correctness_array)
		#_switch_waiting_to_duplicate()
		if animated_bg_image.value == 100:
			get_parent()._play_test_s_1_complete()
			get_parent().input_manager.play_test_complete = true
			return
		return
	if waiting_to_duplicate:
		print("confirm pressed in waiting to duplicate")
		input_present_container._duplicate_first_row_and_add_to_history_grid()
		_switch_waiting_to_duplicate()
		return
	#if input_present_container.active_row == "Row5" and correctness_array != ["correct", "correct", "correct", "correct", "correct"]:
		#answer_label.text = "ERR: guess_word() == false" #here for incorrect behaviour
		#answer_label.position.x -= 250
		#last_guess_wrong = true
	#visual manager behaviour to change letter themes; need some behaviour to show when the player guesses the word correctly 
	input_present_container._set_row_themes(correctness_array) 
	_switch_waiting_to_duplicate()
	#input_present_container._set_active_row()# here you need to call a new func that you make in the grid node, whereby it keeps the active row as 1



func _next_pressed():
	var row_string: String = input_present_container.get_active_row_string()
	if row_string.contains("_"):
		return
	if correct_given:
		#waiting_to_duplicate = true
		print("next pressed and correct given!")
		correct_given = false
		answer_manager._reset()
		input_present_container._reset()
		answer_label.text = ""
		for i in 5:
			_letter_removed()
		var some_string_array: Array[String] = ["some_string", "some_string2"]
		input_present_container._set_row_themes(some_string_array, true)
		#get_parent()._s1_correct_behaviour()
	elif last_guess_wrong:
		last_guess_wrong = false
		answer_manager._reset()
		input_present_container._reset()
		answer_label.text = ""
		answer_label.position = answer_label_og_position
		for i in 5:
			_letter_removed()
		var some_string_array: Array[String] = ["some_string", "some_string2"]
		input_present_container._set_row_themes(some_string_array, true)
	#here you need to check if not correct given, if not send the active row to the left side container node for tokenisation history
	$NextButton.hide()
	$NextButton.process_mode = Node.PROCESS_MODE_DISABLED
	$ConfirmButton.show()
	$ConfirmButton.process_mode = Node.PROCESS_MODE_PAUSABLE#



func get_correct_given():
	return correct_given

func flash_label():
	for i in 10:
		await get_tree().create_timer(0.25).timeout
		progress_label.show()
		await get_tree().create_timer(0.25).timeout
		progress_label.hide()
