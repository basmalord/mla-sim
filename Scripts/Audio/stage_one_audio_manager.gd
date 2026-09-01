extends AudioStreamPlayer

signal timer_finished

@export var sounds_dict: Dictionary[String, AudioStream]
@export var s1_success_time: float


func _play_sound_by_id(id: String, failed_input: bool = false):
	_set_stream_by_id(id)
	pitch_scale = 1
	match id:
		"keyboard_button":
			if failed_input:
				pitch_scale = 0.3
			else:
				pitch_scale = randf_range(1, 1.05)
		"back_button":
			if failed_input:
				pitch_scale = 0.3
			else:
				pitch_scale = randf_range(0.5, 0.55)
	play()

func _set_stream_by_id(id: String):
	var my_stream: AudioStream = sounds_dict[id]
	stream = my_stream

func _custom_timer(time: float):
	await get_tree().create_timer(time).timeout
	timer_finished.emit()
