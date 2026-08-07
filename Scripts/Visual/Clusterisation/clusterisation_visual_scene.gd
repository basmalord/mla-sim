extends Node2D

@onready var edge_manager: EdgeManager = $EdgeManager
@onready var word_node_manager: WordNodeManager = $WordNodeManager

@export var word_dict: Dictionary

var debug_sim_mat: Array

func _set_graph_ready(value: bool):
	edge_manager = $EdgeManager
	print(edge_manager)
	edge_manager._set_graph_ready(value)

func _hide_edges():
	edge_manager.hide()

func _tell_edge_manager_to_draw(debug_array: Array):
	debug_sim_mat = debug_array
	edge_manager.queue_redraw()
	edge_manager.show()

func _on_answers_given(answers_array: Array, entry_array: Array):
	word_node_manager._on_answers_given(answers_array, entry_array)
