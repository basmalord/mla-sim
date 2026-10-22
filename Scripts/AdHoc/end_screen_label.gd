extends RichTextLabel

@export var my_string_array: Array[String]

signal faded_in
signal faded_out

@export var fade_in_time: float = 1.0
@export var fade_out_time: float = 0.5
@export var between_fade_time: float = 5.0

@onready var my_timer: Timer = $Timer

func _ready() -> void:
	_display()

func _display():
	modulate.a = 0
	for string in my_string_array:
		text = string
		fade_in()
		await faded_in
		my_timer.wait_time = between_fade_time
		my_timer.start()
		await my_timer.timeout
		fade_out()
		await faded_out
	get_tree().change_scene_to_file("res://Scenes/UI/menus/start_menu.tscn")

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_time)
	await tween.finished
	faded_in.emit()


func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_out_time)
	await tween.finished
	faded_out.emit()
