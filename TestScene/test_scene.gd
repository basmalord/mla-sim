extends Node

class_name SceneController

@onready var pause_menu: Control = $PauseMenu
@onready var stage_controller: Control = get_children()[0]
@onready var playtest_complete_manager: Control = $PlaytestCompleteManager
@onready var input_manager: Node = $InputManager
@onready var whole_screen_effects: CanvasLayer = $WholeScreenEffects
@onready var background_screen_effects: CanvasLayer = $BackgroundLayer
@onready var transition_manager: TransitionManager = $TransitionManger

var is_paused: bool = false

func _play_test_s_1_complete():
	if get_children()[0].name == "StageOneController":
		transition_manager._handle_transition(stage_controller)
	#background_screen_effects._reset_self()
	#whole_screen_effects._reset_self()
	#await get_tree().create_timer(0.5).timeout
	#playtest_complete_manager.show()
	#for i in range(101):
		#playtest_complete_manager.modulate.a = i / 100.0
		#await get_tree().create_timer(0.02).timeout

func _play_test_s_2_complete():
	transition_manager._handle_transition(stage_controller)

func _s1_correct_behaviour():
	pass
	#if !background_screen_effects.is_visible():
		#background_screen_effects.show()
		#return
	#background_screen_effects.hide()
