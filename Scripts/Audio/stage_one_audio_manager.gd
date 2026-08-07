extends AudioStreamPlayer


@export var sounds_dict: Dictionary[String, AudioStream]

func _play_sound_by_id(id: String):
	_set_stream_by_id(id)
	pitch_scale = 1
	match id:
		"keyboard_button":
			pitch_scale = randf_range(1, 1.05)
		"back_button":
			pitch_scale = randf_range(0.5, 0.55)
	play()

func _set_stream_by_id(id: String):
	var my_stream: AudioStream = sounds_dict[id]
	stream = my_stream
