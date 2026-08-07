extends Node

class_name InputManager

@onready var scene_control: SceneController = get_parent()
var play_test_complete: bool = false


func _input(event: InputEvent) -> void:
	if !play_test_complete:
		if Input.is_action_just_pressed("PAUSE"):
			if scene_control.is_paused == false:
				scene_control.pause_menu.show()
				scene_control.is_paused = true
				scene_control.stage_controller.process_mode = Node.PROCESS_MODE_DISABLED
			else:
				scene_control.pause_menu.hide()
				scene_control.is_paused = false
				scene_control.stage_controller.process_mode = Node.PROCESS_MODE_PAUSABLE
	if Input.is_action_just_pressed("SKIP"):
		scene_control._play_test_s_1_complete()
	#else:
		#if Input.is_action_just_pressed("CLOSE"):
			#scene_control.stage_controller.process_mode = Node.PROCESS_MODE_DISABLED
			#scene_control.pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
			#get_tree().quit()
