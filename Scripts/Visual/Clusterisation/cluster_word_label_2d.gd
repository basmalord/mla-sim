extends Node2D

@onready var label = $ClusterWordPanel/ClusterWordRTL
@onready var panel = $ClusterWordPanel

var velocity := Vector2.ZERO
var force := Vector2.ZERO
var text: String:
	set(value):
		text = value
		if is_node_ready():
			label.text = value
			#panel.size = label.size
