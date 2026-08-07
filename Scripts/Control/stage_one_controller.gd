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


func _ready():
	answer_label_og_position = answer_label.position

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("CONFIRM"):
		_confirm_pressed()
		_next_pressed()
	if Input.is_action_just_pressed("DELETE"):
		_letter_removed()

func _letter_clicked(input_button: InputButton):
	input_button._make_self_unclickable()
	var button_text = input_button.text 
	input_present_container._set_active_row_string(button_text)

func _letter_removed():
	input_present_container._remove_last_letter()

func _confirm_pressed():
	if input_present_container.get_active_row_string().contains("_"):
		return #space for some behaviour to indicate that you need to enter more letters
	if input_present_container.active_row == "Row6" or input_present_container.active_row == "Row7" or input_present_container.active_row == "Row8":
		return
	answer_manager._confirm_button_pressed(input_present_container.get_active_row_string())
	var correctness_array: Array[String] = await correctness_array_generated
	if correctness_array.is_empty():
		print("correct_array is empty")
		return
	if correctness_array == ["correct", "correct", "correct", "correct", "correct"]: 
		get_parent()._s1_correct_behaviour()
		answer_label.text = answer_manager.active_answer.to_upper() + "!"
		correct_given = true
		animated_bg_image.value += 20 #value needs to be added to save data
		$ConfirmButton.hide()
		$ConfirmButton.process_mode = Node.PROCESS_MODE_DISABLED
		$NextButton.show()
		$NextButton.process_mode = Node.PROCESS_MODE_PAUSABLE
		if animated_bg_image.value == 100:
			get_parent()._play_test_s_1_complete()
			get_parent().input_manager.play_test_complete = true
			return
	else:
		get_parent().whole_screen_effects._play_effect("VHS")
	if input_present_container.active_row == "Row5" and correctness_array != ["correct", "correct", "correct", "correct", "correct"]:
		answer_label.text = "ERR: guess_word() == false" #here for incorrect behaviour
		answer_label.position.x -= 250
		last_guess_wrong = true
	#visual manager behaviour to change letter themes; need some behaviour to show when the player guesses the word correctly 
	input_present_container._set_row_themes(correctness_array) #this must come before below because this references actie_row, which below changes.
	input_present_container._set_active_row()



func _next_pressed():
	if correct_given:
		correct_given = false
		answer_manager._reset()
		input_present_container._reset()
		answer_label.text = ""
		for i in 5:
			_letter_removed()
		var some_string_array: Array[String] = ["some_string", "some_string2"]
		input_present_container._set_row_themes(some_string_array, true)
		get_parent()._s1_correct_behaviour()
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
		get_parent().whole_screen_effects._play_effect("VHS")
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
