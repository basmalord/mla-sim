extends SubViewportContainer

@onready var my_visual_scene: Node2D = $ClusterSubView/ClusterisationVisualScene

func _call_graph(answers_array: Array, entry_array: Array):
	my_visual_scene._on_answers_given(answers_array, entry_array)
