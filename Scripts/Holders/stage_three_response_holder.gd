extends Node

signal data_loaded (data)

@export var data_resource_path: String
var data_res

func _ready() -> void:
	var my_control = get_parent()
	connect("data_loaded", Callable(my_control, "_set_data_res"))
	await get_tree().create_timer(0.1).timeout
	_load_res_from_path()

func _load_res_from_path():
	print("STAGE 1 ")
	var my_file = FileAccess.open(data_resource_path, FileAccess.READ)
	var file_contents: String = my_file.get_as_text()
	my_file.close()
	var json := JSON.new()
	var error := json.parse(file_contents)
	if error == OK:
		var data: Dictionary = json.data
	else:
		print("ERROR: EXCERPT DICT CANNOT BE PARSED")
		return
	data_res = json.data
	emit_signal("data_loaded", data_res)
