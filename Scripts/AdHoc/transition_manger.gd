extends Node

class_name TransitionManager

@onready var my_manager: SceneController = get_parent()

const STAGE_ONE_PATH: String = "res://Scenes/Stages/StageOne/stage_one_controller.tscn"
const STAGE_TWO_PATH: String = "res://Scenes/Stages/StageTwo/StageTwoController.tscn"
const STAGE_THREE_PATH: String = "res://Scenes/Stages/StageThree/stage_three_controller.tscn"
const PAUSE_SCREEN_PATH: String = "res://Scenes/UI/menus/pause_menu.tscn"


func _handle_transition(current_scene: Node):
	var current_stage_name = current_scene.name
	var new_stage
	_remove_scene(current_scene)
	match current_stage_name:
		"StageOneController":
			new_stage = load_scene_from_path(STAGE_TWO_PATH)
		"StageTwoController":
			print("stage 2 finished from match func")
			new_stage = load_scene_from_path(STAGE_THREE_PATH)
		_:
			return
	my_manager.stage_controller = new_stage

func _remove_scene(scene_for_removal: Node):
	var nodes = my_manager.get_children()
	for node in nodes:
		if node == scene_for_removal:
			node.queue_free()

func load_scene_from_path_not_stage(scene_path: String):
	var scene: PackedScene = load(scene_path)
	if scene == null:
		push_error("Failed to load scene: " + scene_path)
		return null
	var instance = scene.instantiate()
	my_manager.add_child(instance)
	return instance

func load_scene_from_path(scene_path: String):
	var scene: PackedScene = load(scene_path)
	if scene == null:
		push_error("Failed to load scene: " + scene_path)
		return null
	var instance = scene.instantiate()
	my_manager.add_child(instance)
	my_manager.stage_controller = instance
	return instance
