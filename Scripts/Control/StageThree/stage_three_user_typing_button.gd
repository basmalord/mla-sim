extends Button

class_name UserTypingButton

@export var text_speed: float = 0.5
@export var next_prompt: Dictionary
@export var flash_speed: float = 1.0
var tutorial: bool = false

func animate_elipses(): #while loop might cause some lag, come here to change if so
	while true:
		await get_tree().create_timer(text_speed).timeout
		
		# Animate ellipses
		if text.ends_with("..."):
			text = text.trim_suffix("...")
		else:
			text += "."


func _flash_button():
	while true:
		await get_tree().create_timer(flash_speed).timeout
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1.3, 1.3, 1.3), flash_speed * 0.5)
		tween.tween_property(self, "modulate", Color.WHITE, flash_speed * 0.5)

func _on_pressed() -> void:
	if tutorial:
		get_parent().continue_tutorial()
	await get_tree().create_timer(0.05).timeout
	queue_free()
