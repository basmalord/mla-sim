extends Node

@onready var word_learner: Node = $WordLearner

var word_dict: Dictionary

func _set_data_res(data):
	word_dict = data

func generate_word_associations(theme_array: Array):
	if word_dict.is_empty():
		return
	var words: Array = word_dict.keys()
	var themes: Dictionary = word_dict[0]["Themes"].keys()
	var valued_indexes: Array
	var theme_array_values: Array
	for index in theme_array.size():
		if theme_array[index] == 0:
			continue
		valued_indexes.append(index)
		theme_array_values.append(theme_array[index])
	for word in words:
		var word_themes_entry: Dictionary = word_dict[word]["Themes"]
		var relevant_theme_values: Array
		for index in valued_indexes:
			var relevant_theme: String = themes[index]
			var relevant_value: float = word_themes_entry[relevant_theme]
			if relevant_value != 0.00:
				relevant_theme_values.append(relevant_value)
		if relevant_theme_values.is_empty():
			words.erase(word)
			continue
		words[word] = relevant_theme_values
	for word in words:
		var cosine_similarity: float = get_cosine_similarity(theme_array, theme_array_values)
		words[word] = cosine_similarity
	return words



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
