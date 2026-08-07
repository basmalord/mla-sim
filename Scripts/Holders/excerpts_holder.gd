extends Node

signal excerpts_loaded

@export var excerpt_dict_path: String
var excerpt_dict: Dictionary


func _ready():
	await get_tree().create_timer(0.1).timeout
	connect("excerpts_loaded", Callable(get_parent(), "_set_excerpts_dict"))
	_load_excerpt_dict_from_path()

func _load_excerpt_dict_from_path():
	var my_file = FileAccess.open(excerpt_dict_path, FileAccess.READ)
	var file_contents: String = my_file.get_as_text()
	my_file.close()
	var json := JSON.new()
	var error := json.parse(file_contents)
	if error == OK:
		var data: Dictionary = json.data
	else:
		print("ERROR: EXCERPT DICT CANNOT BE PARSED")
		return
	excerpt_dict = json.data
	emit_signal("excerpts_loaded", excerpt_dict)
