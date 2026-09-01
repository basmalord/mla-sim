extends AudioStreamPlayer


func play_from_random_position() -> void:
	var random_position := randf_range(0.0, stream.get_length())
	play(random_position)
