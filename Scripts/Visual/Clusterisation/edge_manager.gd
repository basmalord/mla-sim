class_name EdgeManager

extends Node2D

@onready var my_manager: Node2D = get_parent()

var graph_ready: bool = false

func _draw():
	if graph_ready:
		var word_nodes = my_manager.word_node_manager.get_children()
		for i in word_nodes.size():
			for j in range(i + 1, word_nodes.size()):
				var similarity: float = my_manager.debug_sim_mat[i][j - i - 1]
				# Ignore weak relationships
				if similarity < 0.80:
					continue
				var colour := Color.WHITE
				colour.a = similarity
				draw_line(
					word_nodes[i].position,
					word_nodes[j].position,
					colour,
					similarity * 1.0
				)


func _set_graph_ready(value: bool):
	graph_ready = value
