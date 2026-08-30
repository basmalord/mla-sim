class_name WordNodeManager

extends Node2D

signal children_generated

const CLUSTER_WORD_SCENE := preload("res://Scenes/UI/Output/StageTwo/cluster_word_label_2d.tscn")
const CLUSTER_THEME_SCENE := preload("res://Scenes/UI/Output/StageTwo/cluster_theme_label.tscn")
const REPULSION := 100.0
const SPRING_STRENGTH := 10.0
const REST_LENGTH := 100.0
const DAMPING := 0.90
const DELTA = (1.0 / 60.0)

@onready var my_manager: Node2D = get_parent()

@export var spawn_radius := 200.0

var test_template: Dictionary = 		{"Themes": {
			"justice": 1.0,
			"order": 0.0,
			"peace": 0.0,
			"equality": 0.0
		},
		"WordType": "noun"}

var array_template: Array = []
var similarity_matirx: Array[Array]
var word_dict_path: String = "res://Data/StageTwo/clusterisation_word_dict.txt"
var test_word_dict
var word_nodes: Array[Node] = []
var theme_nodes: Array[Node] = []

func _ready():
	_load_excerpt_dict_from_path() #first should come generate new word nodes (whenever answers are give) ; it should add those entries into the inherent word dict ; then it should set the similarity matrix with reference to the whole word dict


func _on_answers_given(answers_array: Array, entry_array: Array):
	for index in answers_array.size():
		var answer = answers_array[index]
		var entry = test_template
		#var entry = entry_array[index]
		test_word_dict[answer] = entry
	await get_tree().process_frame
	_set_similarity_matrix(test_word_dict)
	call_deferred("_generate_child_word_nodes", test_word_dict)
	my_manager._hide_edges()
	await children_generated
	_run_graph_sim()

func create_new_word_scene(word: String):
	var new_word_scene = CLUSTER_WORD_SCENE.instantiate()
	add_child(new_word_scene)
	new_word_scene.text = word
	word_nodes.append(new_word_scene)
	return new_word_scene

func create_new_theme_scene(theme: String): #this 
	var new_theme_scene = CLUSTER_THEME_SCENE.instantiate()
	add_child(new_theme_scene)
	new_theme_scene.text = theme
	theme_nodes.append(new_theme_scene)
	return new_theme_scene

func get_cosine_similarity(node_a_theme_value_array: Array, node_b_theme_value_array: Array):
	var dot : float = 0.0
	var magnitude_a : float = 0.0
	var magnitude_b : float = 0.0
	for index in node_a_theme_value_array.size():
		dot += node_a_theme_value_array[index] * node_b_theme_value_array[index]
		magnitude_a += node_a_theme_value_array[index] * node_a_theme_value_array[index]
		magnitude_b += node_b_theme_value_array[index] * node_b_theme_value_array[index]
	if magnitude_a == 0.0 or magnitude_b == 0.0:
		return 0.0
	return dot / (sqrt(magnitude_a) * sqrt(magnitude_b))

func _generate_child_word_nodes(word_dict: Dictionary): #with this, needs to be called only with new entries, in practice can't be repeatedly called with a static word dict saved
	var words: Array = word_dict.keys()
	var no_of_words: int = words.size()
	var no_of_children: int = get_child_count()# - theme_nodes.size() #needs to be called because we only want word nodes
	
	if no_of_words == no_of_children: #I think from here to 68 needs to be removed, and the for loop needs to just reference the word dict size
		return
	var difference = no_of_words - no_of_children #taking a look at everything, there needs to be some refactoring or else the whole word dict will need to be passed every time, then all nodes queue freed at the end and everything regenerated
	if difference < 0:
		return
	var end_index = no_of_words 
	var start_index = end_index - difference
	for index in range(start_index, end_index):
		var word = words[index]
		var value_index: int = 0
		var highest_value_index: int = 0
		var themes_entry: Dictionary = word_dict[word]["Themes"]
		for theme in themes_entry:
			var value = themes_entry[theme]
			if value > themes_entry[themes_entry.keys()[highest_value_index]]:
				highest_value_index = value_index
			value_index += 1
		var associated_theme: String = themes_entry.keys()[highest_value_index]
		var new_word_node = create_new_word_scene(word)
		match word:
			"justice":
				new_word_node.position = Vector2(-150, 150)
				continue
			"order":
				new_word_node.position = Vector2(150, 150)
			"peace":
				new_word_node.position = Vector2(150, -150)
			"equality":
				new_word_node.position = Vector2(-150, -150)
		if word != "justice" and word != "order" and word != "peace" and word != "equality":
			new_word_node.position = generate_spawn_position(associated_theme)
		print("this is node psawn position: ", new_word_node.position)
	emit_signal("children_generated")

func generate_spawn_position(associated_theme: String): #no safeguards against rnadomyl spawning very close, could prove annoying when more and more words are added
	var angle := randf() * TAU
	var distance := sqrt(randf()) * spawn_radius
	var centre: Vector2
	match associated_theme:
		"justice":
			centre = Vector2(-150, 150)
		"order":
			centre = Vector2(150, 150)
		"peace":
			centre = Vector2(150, -150)
		"equality": 
			centre = Vector2(-150, -150)
	var spawn_position = Vector2.from_angle(angle) * distance
	return spawn_position

func _update_all_word_node_positions(delta: float) -> void:
	for node in word_nodes:
		node.force = Vector2.ZERO
	for index in word_nodes.size():
		var node_a: Node2D = word_nodes[index]
		for other_index in range(index + 1, word_nodes.size()):
			var node_b: Node2D = word_nodes[other_index]
			var offset : Vector2 = node_b.position - node_a.position 
			var distance = max(offset.length(), 1.0)
			var direction = offset / distance
			var repulsion = direction * (REPULSION / (distance * distance))
			node_a.force -= repulsion
			node_b.force += repulsion
			var similarity: float
			if other_index > index:
				var offset_other_index = other_index - index - 1
				similarity = similarity_matirx[index][offset_other_index]
			else:
				similarity = similarity_matirx[other_index][index - other_index - 1]
			var spring = direction * (SPRING_STRENGTH * similarity * (distance - REST_LENGTH))
			node_a.force += spring
			node_b.force -= spring
	for node in word_nodes:
		node.velocity += node.force * delta
		node.velocity *= DAMPING
		node.position += node.velocity * delta

func _update_single_word_node_position(word_node: Node2D):
	pass

func _run_graph_sim():
	for i in 100:
		_update_all_word_node_positions(DELTA)
		await get_tree().process_frame
	#print(similarity_matirx)
	my_manager._set_graph_ready(true)
	my_manager._tell_edge_manager_to_draw(similarity_matirx)



func _set_similarity_matrix(word_dict: Dictionary): #maybe this just needs to pass the whole dict every time, but the spawn position and node generation can take just the new ones?
	similarity_matirx = []
	var words = word_dict.keys()
	var word_index: int = -1
	var other_word_index: int = -1
	var no_of_indexes = words.size() - 1 #because size() returns nominal size but we're interested in indexes
	var similarity_value: float
	for word in words:
		word_index += 1
		var word_theme_values_array: Array = array_template.duplicate(true)
		var word_theme_dict_entry: Dictionary = word_dict[word]["Themes"].duplicate(true)
		for theme in word_theme_dict_entry.keys():
			word_theme_values_array.append(word_theme_dict_entry[theme])
		var word_similarity_array: Array = array_template.duplicate(true)
		for other_word in words:
			other_word_index += 1
			if word == other_word: #skips itself, therefore indexes will follow child pattern exactly until own index, at which point similarity array indexes will represent the child_index + 1
				continue
			if other_word_index < word_index: 
				similarity_value = similarity_matirx[other_word_index][word_index - 1] #negative 1 because each array does not include itself and so the 2nd order 0th index of the 1st order 0th index will represent  0th child to 1st child, therefore 1st child wants to get the 0th index rather than the 1st index (which would be the 0th child's relationship to the 2nd child)
			else:
				var other_word_values_array: Array = array_template.duplicate(true)
				var other_word_theme_dict_entry: Dictionary = word_dict[other_word]["Themes"].duplicate(true)
				for theme in other_word_theme_dict_entry.keys():
					other_word_values_array.append(other_word_theme_dict_entry[theme])
				similarity_value = get_cosine_similarity(word_theme_values_array, other_word_values_array)
			word_similarity_array.append(similarity_value)
			if no_of_indexes == other_word_index:
				other_word_index = -1
		similarity_matirx.append(word_similarity_array)


func _load_excerpt_dict_from_path():
	var my_file = FileAccess.open(word_dict_path, FileAccess.READ)
	var file_contents: String = my_file.get_as_text()
	my_file.close()
	var json := JSON.new()
	var error := json.parse(file_contents)
	if error == OK:
		var data: Dictionary = json.data
	else:
		print("ERROR: WORD DICT CANNOT BE PARSED")
		return
	test_word_dict = json.data
