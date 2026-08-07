extends OptionButton

var goals_string_array: Array[String]
var goals_values_array: Array[float]

func _import_items(goals_array: Array):
	for goal in goals_array:
		add_item(goal)

func _brief_disable():
	self.disabled = true
	await get_tree().create_timer(0.05).timeout
	self.disabled = false
