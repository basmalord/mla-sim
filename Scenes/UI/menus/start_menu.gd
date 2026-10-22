extends Control

var starting: bool = false

@export var main_stage_file_path: String

@onready var my_screen: TextureRect = $BlackScreen
@onready var my_start: Button = $Start
@onready var my_quit: Button = $QuitButton

func _on_start_pressed() -> void:
	starting = true
	my_start.hide()
	my_start.disabled = true
	my_quit.hide()
	my_quit.disabled = true
	var tween = create_tween()
	tween.tween_property(my_screen, "modulate:a",0.0,1.0)
	await tween.finished
	get_tree().change_scene_to_file(main_stage_file_path)
	pass


func _on_quit_button_pressed() -> void:
	if !starting:
		get_tree().quit()
