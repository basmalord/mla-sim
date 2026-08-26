extends Node2D

class_name VDTStation

signal new_vdt_word_spawned
signal data_reached_station(station_id: String)

const word_node_scene: PackedScene = preload("res://Scenes/Stages/StageThree/VisualDataTrain/v_d_t_word_ndoe.tscn")
@export var station_id: String
@export_enum("Central","Junction") var station_type: String
@export var exits_editor_dict: Dictionary = {"north": false, "south": false, "east": false, "west": false}
@onready var docker_area: Area2D = $Dockers
@onready var my_manager: Node = get_parent()
@onready var exits_spawner_dict: Dictionary = {"north": $Spawners/north, "south": $Spawners/south, "east": $Spawners/east, "west": $Spawners/west}
@onready var entrance_docker_dict: Dictionary = {"north": $Dockers/north , "south": $Dockers/south, "east": $Dockers/east, "west": $Dockers/west}
var incoming_word: VDTWordNode
var outgoing_word: VDTWordNode
var directions_array: Array[String] = ["north", "south", "east", "west"]

func _ready() -> void:
	connect("data_reached_station", Callable(my_manager,"_end_of_the_line"))

func _set_exits_and_entrances_spawner_dicts():
	for direction in exits_editor_dict:
		if exits_editor_dict[direction]:
			continue
		var target_exit: CollisionShape2D = exits_editor_dict[direction]
		var target_entrance: CollisionShape2D = entrance_docker_dict[direction]
		exits_editor_dict.erase(direction)
		entrance_docker_dict.erase(direction)
		target_exit.queue_free()
		target_entrance.queue_free()


func _on_dockers_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void: #currently no protections against crashes, could do by area type or just rely on masks
	return
	var word_node: VDTWordNode = area.my_manager
	if word_node.starting_station_id == station_id:
		return
	var word_orientation: String = word_node.orientation
	var docker_direction: String = docker_area.get_children()[local_shape_index].name
	if word_orientation != docker_direction: #any train coming in should only be recognised by the docker associated with their orientation.
		return
	if word_node.path.size() <= 1: # checks if this is last station in word's path, this should really come after
		_end_of_the_line_behaviour()
		return
	if word_node != incoming_word:
		word_node = incoming_word
		if word_node.path.size() > 1: #checks if this is last station, does spawning behaviour if not
			var destination: String = word_node.path.front()
			var to_direction_index: int
			var to_array: Array[String] = my_manager.station_to_station_paths_dict[station_id]
			to_direction_index = to_array.find(destination)
			var to_direction: String = directions_array[to_direction_index] #if there are any fuck ups with direction, ehck this line here, make sure that all directions are marked as such and in same index order
			var target_exit: CollisionShape2D = exits_spawner_dict[to_direction]
			_spawn_word1(word_node, target_exit) #now you need to figure out the process for building the word as it comes in (through passing an ever smaller number of characters to the 
			#text, this almost certainly needs to be domne in the word node itself so that it can shift it's front area back, get the area of the word node to be linked to 
			#a pop back function which s all conditioned on whether the area shares its name with the word's orientation and whether the station in question is the starting station

func _spawn_word(word_node_properties_og: Array): #properties: 1. word ; 2. whole path (which you will then pop at the front and covnert the 1st into an orientation based on your manager's path dict) ;
	# 3. (for later) you will need to have some modulation behaviour to continue over, this mod behaviour will be something figured out originally by the manager, with only a string to represent 
	# those calculations within the word node itself, which will define the behaviour of a modulation function
	var word_node_properties = word_node_properties_og.duplicate(true)
	var word_node_word: String = word_node_properties[0]
	var word_node_path: Array = word_node_properties[1]
	word_node_path.pop_front()
	print("this is word node path from station: ", word_node_path)
	if word_node_path.size() == 0: #if path is size 0, then it's just gotten to the last station
		print("doing the thing from spawn func in station", word_node_path)
		my_manager._end_of_the_line(station_id)
		return
	print("immediately after the word node path check: ", word_node_path)
	var next_station: String = word_node_path.front()
	var direction_to_next_station: String 
	var my_paths: Dictionary = my_manager.get_station_paths(station_id) #will crash if there is no entry
	var directions: Array[String] = ["north", "south", "east", "west"]
	for direction in directions:
		if my_paths[direction].has(next_station):
			direction_to_next_station = direction #could put a break here to stop the loop early but unsure how it will effect and dont have time to test
	var spawner_position: Vector2 = exits_spawner_dict[direction_to_next_station].global_position
	var deconstructor_docker_name: String = direction_to_next_station
	var new_vdt_word_node: VDTWordNode = word_node_scene.instantiate()
	new_vdt_word_node.word = word_node_word
	new_vdt_word_node.path = word_node_path
	new_vdt_word_node.target_station_id = next_station
	new_vdt_word_node.starting_station_id = station_id
	new_vdt_word_node.orientation = direction_to_next_station
	new_vdt_word_node.deconstructor_docker_name = deconstructor_docker_name
	new_vdt_word_node.global_position = spawner_position
	my_manager.call_deferred("add_child", new_vdt_word_node)
	#my_manager.add_child(new_vdt_word_node)
	new_vdt_word_node._set_direction_from_orientation()
	new_vdt_word_node.speed = 2
	print("this is the end of the spawn word func in station   ", new_vdt_word_node.orientation, "   ", new_vdt_word_node.word, "   ", word_node_path, "   ", word_node_word, "   ", next_station, )

func _spawn_word1(vdt_word: VDTWordNode, exit: CollisionShape2D):
	var new_vdt_word: VDTWordNode = vdt_word.duplicate() # might have to do some form of hold up here
	add_child(new_vdt_word)
	outgoing_word = new_vdt_word
	emit_signal("new_vdt_word_spawned")
	var direction: String = exit.name #need to use this to set starting point and velocity
	outgoing_word._set_orientation(direction)
	await outgoing_word.orientation_set
	outgoing_word._set_direction_from_orientation()
	await  outgoing_word.direction_set
	var first_letter: String 
	if direction == "east" or direction == "south": #sets text to a single letter, which will need to be added to as it goes on
		var word_length: int = outgoing_word.word.length()
		first_letter = outgoing_word.word[word_length - 1]
	else:
		first_letter = outgoing_word.word[0]
	outgoing_word._set_text_from_orientation(first_letter)

func _end_of_the_line_behaviour():
	print("end of the line")
