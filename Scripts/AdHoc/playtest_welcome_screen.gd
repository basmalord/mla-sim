extends Control

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("CLOSE"):
		get_tree().change_scene_to_file("res://TestScene/test_scene.tscn")
