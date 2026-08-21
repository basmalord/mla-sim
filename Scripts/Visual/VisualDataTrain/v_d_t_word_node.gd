extends Node2D

class_name VDTWordNode

@onready var my_rtl: RichTextLabel = $VDTRTL
@onready var my_front: CollisionShape2D = $VDTWordNodeFrontArea/VDTBoxFront
@onready var my_back: CollisionShape2D = $VDTWordNodeBackArea/VDTBoxBack


@export_enum("upward", "downward", "leftward", "rightward") var orientation: String 

@export var speed: int

var target_station: Node

func _set_vertical_rtl_text(candidate_text: String):
	var characters: Array[String] = []
	for character in candidate_text:
		characters.append(character)
	my_rtl.text = "\n".join(characters)

func _set_horizontal_rtl_text(candidate_text: String):
	my_rtl.text = candidate_text

func _set_orientation(candidate_orientation: String):
	match candidate_orientation:
		"upward":
			orientation = candidate_orientation
		"downward":
			orientation = candidate_orientation
		"leftward":
			orientation = candidate_orientation
		"rightward":
			orientation = candidate_orientation
		_:
			return
