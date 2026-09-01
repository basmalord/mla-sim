extends Node

class_name SceneController

@onready var pause_menu: Control = $PauseMenu
@onready var stage_controller: Control = get_children()[0]
@onready var playtest_complete_manager: Control = $PlaytestCompleteManager
@onready var input_manager: Node = $InputManager
@onready var transition_manager: TransitionManager = $TransitionManger
@onready var black_screen: TextureRect = $BlackScreen
@onready var music_manager: AudioStreamPlayer = $MusicPlayer

var s1_finished_wait_time: float = 3.00
var is_paused: bool = false

func _restart_behaviour():
	pause_menu.set_process_input(false)
	transition_manager.set_process_input(false)
	black_screen.show()
	await get_tree().process_frame
	#transition_manager._remove_scene(pause_menu)
	#pause_menu = transition_manager.load_scene_from_path_not_stage(transition_manager.PAUSE_SCREEN_PATH)
	transition_manager._remove_scene(stage_controller)
	pause_menu.hide()
	is_paused = false
	await get_tree().process_frame
	transition_manager.load_scene_from_path(transition_manager.STAGE_ONE_PATH)
	await get_tree().process_frame
	move_child(stage_controller, 0)
	await get_tree().process_frame
	transition_manager.set_process_input(true)
	pause_menu.set_process_input(true)
	black_screen.hide()

func _stage_one_started():
	music_manager.play_track("S1")

func _play_test_s_1_complete():
	if get_children()[0].name == "StageOneController":
		await get_tree().create_timer(s1_finished_wait_time).timeout
		transition_manager._handle_transition(stage_controller)
	#background_screen_effects._reset_self()
	#whole_screen_effects._reset_self()
	#await get_tree().create_timer(0.5).timeout
	#playtest_complete_manager.show()
	#for i in range(101):
		#playtest_complete_manager.modulate.a = i / 100.0
		#await get_tree().create_timer(0.02).timeout

func _play_test_s_2_complete():
	stage_controller.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(s1_finished_wait_time).timeout
	transition_manager._handle_transition(stage_controller)

func _s1_correct_behaviour():
	pass
	#if !background_screen_effects.is_visible():
		#background_screen_effects.show()
		#return
	#background_screen_effects.hide()
