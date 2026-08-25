extends Node2D

class_name VDTWordNode

signal orientation_set
signal direction_set
signal text_set
signal area_positions_set
signal finished_waiting_for_text_to_set
signal letter_deconstructed


@onready var my_rtl: RichTextLabel = $VDTRTL
@onready var my_front: CollisionShape2D = $VDTWordNodeFrontArea/Front
@onready var my_back: CollisionShape2D = $VDTWordNodeBackArea/Back


@export_enum("north", "south", "east", "west") var orientation: String 

@export var speed: float = 0
@export var direction: Vector2 = Vector2(0,0)

var target_station_id: String
@export var starting_station_id: String = "" #use this to ignore station dockers of the station you've just spawned in
@export var word: String
var times_word_set: int = 1
@export var path: Array
var test: bool = true
@export var deconstructor_docker_name: String = ""
var deconstructing: bool = false


func _ready() -> void:
	pass
	#print(my_front.position, "   ", my_back.position)
	#_set_orientation("north")
	#_set_text_from_orientation("blahblahblahblah")
	#await get_tree().create_timer(0.1).timeout
	#_set_area_shapes_from_orientation()
	#print(my_front.position, "   ", my_back.position) #all testing stuff atm, 

func testing():
	print("testing")

func _set_deconstructor_docker_name():
	match orientation:
		"north":
			deconstructor_docker_name = "south"
		"south":
			deconstructor_docker_name = "north"
		"east":
			deconstructor_docker_name = "west"
		"west":
			deconstructor_docker_name = "east"
		_:
			return



func _setup_new_text(): #this needs to have some way of building string for orientation, if u just add to the string the same way, then it will only look correct s->n and w->e
	if reverse_vertical_text(my_rtl.text).length() == word.length(): #need to reverse it because the bbc code counts towards length
		return
	_set_text_from_orientation(generate_string_from_word())
	print("just waiting for text set")
	emit_signal("finished_waiting_for_text_to_set")
	await get_tree().create_timer(0.05).timeout #for some unknown reason, an await function here with text set cannot respond to the signal being emitted
	print("just before as of snt, this is my rtl size: ", my_rtl.size)
	_set_area_shapes_from_orientation()
	print("this is pa of snt")
	_set_direction_from_orientation()
	print("this is pd of snt")
	if my_rtl.text.length() == 1:
		_setup_new_text()
	times_word_set += 1

func _deconstruct_text(from_construction: bool = false): #this needs to have some way of building string for orientation, if u just add to the string the same way, then it will only look correct s->n and w->e
	if reverse_vertical_text(my_rtl.text).length() == 0:
		queue_free()
		return
	_set_text_from_orientation(generate_string_from_word(), from_construction)
	print("this is text after deconstruct set text:  ", my_rtl.text)
	emit_signal("finished_waiting_for_text_to_set")
	await get_tree().create_timer(0.05).timeout #for some unknown reason, an await function here with text set cannot respond to the signal being emitted
	print("just before as of snt, this is my rtl size: ", my_rtl.size)
	_set_area_shapes_from_orientation(from_construction)
	print("this is pa of snt")
	_set_direction_from_orientation()
	print("this is pd of snt")
	#if reverse_vertical_text(my_rtl.text).length() == word.length() - 1:
		#_setup_new_text()
	times_word_set -= 1
	emit_signal("letter_deconstructed")
	if reverse_vertical_text(my_rtl.text).length() == 0:
		queue_free()
		return

func generate_string_from_word():
	var new_string: String = ""
	if orientation == "north" or orientation == "west":
		for i in times_word_set:
			new_string += word[i]
	elif orientation == "south" or orientation == "east":
		var word_reversed: String = word.reverse()
		print("this is word reversed: ", word_reversed)
		for i in times_word_set:
			new_string = word_reversed[i] + new_string
	return new_string

func _remove_last_rtl_text():
	var current_text: String = my_rtl.text
	var last_index: int = current_text.length() - 1
	if last_index == -1:
		return
	if orientation == "south":
		current_text = reverse_vertical_text(current_text)
		current_text.erase(last_index)
		_set_vertical_rtl_text(current_text)
		return
	current_text.erase(last_index)
	my_rtl.text = current_text

func _remove_first_rtl_text():
	var current_text: String = my_rtl.text
	if current_text.length() == 0:
		return
	if orientation == "north":
		current_text = reverse_vertical_text(current_text)
		current_text.erase(0)
		_set_vertical_rtl_text(current_text)
		return
	current_text.erase(0)
	my_rtl.text = current_text

func _set_vertical_rtl_text(candidate_text: String, from_construction: bool = true):
	var characters: Array[String] = []
	for character in candidate_text:
		characters.append(character)
	my_rtl.text = "\n".join(characters)
	if my_rtl.text.length() > 1:
		if !from_construction:
			if orientation ==  "south":
				my_rtl.global_position.y += 16.00 #smoothhhh, have to change this if ever you change the font size, dont do that can't be bothered
			elif orientation == "north":
				my_rtl.global_position.y += 22
			return
		if orientation ==  "south":
			my_rtl.global_position.y -= 16.00 #smoothhhh, have to change this if ever you change the font size, dont do that can't be bothered
		elif orientation == "north":
			my_rtl.global_position.y += 1

#func get_vertical_text():
	#var characters: Array[String] = []
	#for character in word:
		#characters.append(character)

func reverse_vertical_text(candidate_text: String) -> String:
	return candidate_text.replace("\n","")

func _set_horizontal_rtl_text(candidate_text: String, from_construction: bool = true):
	print("firing horizontal rtl")
	var this_size = my_rtl.size
	print("this is size before: ", this_size)
	my_rtl.text = candidate_text
	print("this is size after: ", my_rtl.size)
	var difference_y = abs(my_rtl.size.y - this_size.y)
	var difference_x = abs(my_rtl.size.x - this_size.x)
	print("this is diff y and x :   ", difference_y, "   ", difference_x)
	if my_rtl.text.length() > 1:
		if !from_construction:
			if orientation ==  "east":
				global_position.x -= 5
			elif orientation == "west":
				global_position.x += 10
			return
		if orientation ==  "east":
			my_rtl.global_position.x -= 10
		elif orientation == "west":
			my_rtl.global_position.x += 7

func _set_orientation(candidate_orientation: String):
	match candidate_orientation:
		"north":
			orientation = candidate_orientation
		"south":
			orientation = candidate_orientation
		"east":
			orientation = candidate_orientation
		"west":
			orientation = candidate_orientation
		_:
			return
	emit_signal("orientation_set")
	print("just emitted orientation set")

func _set_direction_from_orientation():
	match orientation:
		"north":
			direction = Vector2(0,-1)
		"south":
			direction = Vector2(0,1)
		"east":
			direction = Vector2(1,0)
		"west":
			direction = Vector2(-1,0)
		_:
			return
	emit_signal("direction_set")

func _set_text_from_orientation(candidate_text: String, from_construction: bool = true):
	match orientation:
		"north":
			_set_vertical_rtl_text(candidate_text, from_construction)
		"south":
			_set_vertical_rtl_text(candidate_text, from_construction)
		"east":
			_set_horizontal_rtl_text(candidate_text, from_construction)
		"west":
			_set_horizontal_rtl_text(candidate_text, from_construction)
		_:
			return
	emit_signal("text_set")

func _set_area_shapes_from_orientation(from_constructor: bool = true): # this always needs to be called with an await so that the size of the label can update
	var old_front_position = my_front.position
	var old_back_position = my_back.position
	var front_position: Vector2
	var back_position: Vector2
	var new_rotation: float = 0.0
	var my_rtl_size = my_rtl.size
	print("this is my rtl size from area shapes: ", my_rtl_size)
	var my_rtl_position = my_rtl.position
	match orientation:
		"north":
			front_position.y = my_rtl_position.y 
			if !from_constructor:
				front_position.y += get_deconstructor_offset()
			back_position.y = my_rtl_position.y + my_rtl_size.y
			new_rotation = -90.0
		"south":
			back_position.y = my_rtl_position.y 
			front_position.y = my_rtl_position.y + my_rtl_size.y 
			if !from_constructor:
				front_position.y += get_deconstructor_offset()
			new_rotation = -90.0
		"east":
			back_position.x = my_rtl_position.x - 16
			front_position.x = my_rtl_position.x + my_rtl_size.x 
			if !from_constructor:
				front_position.x += get_deconstructor_offset()
		"west":
			front_position.x = my_rtl_position.x 
			if !from_constructor:
				front_position.x += get_deconstructor_offset()
			back_position.x = my_rtl_position.x + my_rtl_size.x + 4
		_:
			return
	print("this is my front and back pos: ", front_position, back_position)
	my_front.position = front_position
	my_front.rotation_degrees = new_rotation
	my_back.position = back_position
	my_back.rotation_degrees = new_rotation
	emit_signal("area_positions_set")

func get_deconstructor_offset():
	match orientation:
		"north":
			return 16 + (word.length() - times_word_set)
		"south":
			return -16 - (word.length() - times_word_set)
		"east":
			return -16 - (word.length() - times_word_set)
		"west":
			return 16 + (word.length() - times_word_set)
		_:
			return 0

func _physics_process(delta: float) -> void:
	#await get_tree().process_frame
	position += speed * direction

func _deconstruction_behaviour():
	deconstructing = true
	var word_length: int = my_rtl.text.length() + 1
	var time: float
	if orientation == "west" or orientation == "east":
		time = 0.1
	elif orientation == "north" or orientation == "south":
		time = 0.1
	for i in word_length * 5:
		_deconstruct_text()
		if i == word_length:
			var vdt_manager: Node = get_tree().get_first_node_in_group("vdt")
			vdt_manager._end_of_the_line(target_station_id)
			queue_free()
		await get_tree().create_timer(time, true, true).timeout

func _on_area_entered_front_area(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if deconstructing:
		return
	if  deconstructor_docker_name == "":
		return
	if area.name != "Dockers":
		print("firing dockers front")
		return
	var station_node = area.get_parent()
	if area.get_children()[area_shape_index].name != deconstructor_docker_name:
		print("firing deconstructor name front", area.get_parent().name, "  ",area.get_children()[area_shape_index].name )
		return
	if station_node is not VDTStation:
		print("firing vdtstation check front")
		return
	var station_id: String
	station_id = station_node.station_id
	if station_id == starting_station_id: #this is only here so that it doesn't interact with the non-same orientation dockers, this should probably be altered to be a positive condition, so 'if != and orientation'
		print("firing station id vs starting check front")
		return
	if (times_word_set - 1) == reverse_vertical_text(my_rtl.text).length() and path.size() > 1:
		var some_array: Array = [word, path]
		station_node._spawn_word(some_array.duplicate()) #needs to contain the word, needs to contain the node's path, needs to contain some data around modulation that you don't have yet
	times_word_set -= 2
	_deconstruction_behaviour()
	print("reached end of front area word func")


func _on_area_entered_back_area(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if my_rtl.text.length() == word.length() :
		print("dis iiiis:    ", word.length(), my_rtl.text, my_rtl.text.length())
		return
	if area.name != "Dockers":
		print("firing dockers")
		return
	if area.get_children()[area_shape_index].name != orientation:
		return
	print("back after name vs ori, back area")
	var station_node = area.get_parent()
	if station_node is not VDTStation:
		print("firing not vdt, back area")
		return
	var station_id: String
	station_id = station_node.station_id
	if station_id != starting_station_id:
		print("not starting station, back area")
		return
	_setup_new_text()
	print("reached end of back area word func", my_back.position, "   ", my_front.position)

func _adjust_back_pos():
	match orientation:
		"north":
			pass
		"south":
			my_back.position.y -= 100.00
			print("doign the right thing")


#left to do here: deconstruction behaviour, add some indicator for value of data, as well as a function modulating colour to indicate value of data
#then you need to add signal emissions to each end phase in the main manager
#You need to checka nd edit spawning behaviour on the station
