extends GridContainer

@onready var my_scroll: ScrollContainer = get_parent()
var children_added: int = 0
var rows: int = 0


func _on_child_entered_tree(node: Node) -> void:
	await get_tree().process_frame
	my_scroll.scroll_vertical = my_scroll.get_v_scroll_bar().max_value
	#children_added += 1
	#if children_added == 5:
		#rows += 1
		#children_added = 0
		#print("this is rows: ", rows)
	#if rows < 13:
		#return
	#if rows == 13:
		#my_scroll.scroll_vertical = my_scroll.get_v_scroll_bar().max_value
	#if children_added == 5:
		#print("lotsmoney")
		#var my_scroll_value = my_scroll.scroll_vertical
		#var new_value = my_scroll_value + 80
		#my_scroll.scroll_vertical = new_value
