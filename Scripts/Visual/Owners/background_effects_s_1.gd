extends CanvasLayer

@onready var my_sprite: Sprite2D = $BackgroundSprite

@export_range(0, 1, 0.01) var s_1_alpha_inc: float = 0.25
@export var shader_dict: Dictionary


func _stage_one_correct_effect_behaviour():
	var shader_alpha: float = my_sprite.material.get_shader_parameter("texture_alpha")
	my_sprite.material.set_shader_parameter("texture_alpha", shader_alpha + s_1_alpha_inc)

func _reset_self():
	hide()
