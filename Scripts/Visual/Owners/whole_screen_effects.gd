extends CanvasLayer

@onready var screen_rect: ColorRect = $WholeScreenColorRect

@export var shader_dict: Dictionary[String, ShaderMaterial]

func _ready():
	screen_rect.hide()

func _play_effect(effect_id: String):
	_set_shader_material(effect_id)
	match effect_id:
		"VHS":
			_vhs_behaviour()
		_:
			return

func _set_shader_material(material_id: String):
	var my_shader: ShaderMaterial = shader_dict[material_id]
	screen_rect.material = my_shader

func _vhs_behaviour():
	screen_rect.show()
	for i in 10:
		screen_rect.material.set_shader_parameter("manual_offset", randf_range(-4.0, 4.0))
		await get_tree().create_timer(0.05).timeout 
	screen_rect.hide()


func _reset_self():
	hide()
