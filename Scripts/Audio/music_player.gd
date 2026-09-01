extends AudioStreamPlayer

signal fade_out_finished

@export var music_dict: Dictionary[String, AudioStreamWAV]
@export var fade_duration: float = 1.0



func _play_track(track_id: String):
	var track_wav: AudioStreamWAV = music_dict[track_id]
	if playing:
		call_deferred("_fade_out")
		await fade_out_finished
	stream = track_wav
	play()


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_propert(self, "volume_db", -80.0, fade_duration)
	await tween.finished
	stop()
	volume_db = 0.0
	fade_out_finished.emit()
