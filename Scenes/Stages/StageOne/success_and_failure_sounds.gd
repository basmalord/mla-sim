extends AudioStreamPlayer

signal timer_finished

@export var sounds_dict: Dictionary[String, AudioStream]
@export var s1_success_time: float = 2.76
@export var s1_failure_time: float = 2.19

func _play_sound_by_id(id: String):
	_set_stream_by_id(id)
	pitch_scale = 1
	play()
	match id:
		"success":
			_custom_timer(s1_success_time)
			await timer_finished
			stop()
		"failure":
			_custom_timer(s1_failure_time)
			await timer_finished
			stop()

func _set_stream_by_id(id: String):
	var my_stream: AudioStream = sounds_dict[id]
	stream = my_stream

func _custom_timer(time: float):
	await get_tree().create_timer(time).timeout
	timer_finished.emit()
