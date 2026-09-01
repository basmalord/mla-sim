extends RichTextLabel

@onready var my_controller: Control = get_parent()

var is_active: bool = false

func _ready() -> void:
	text = ""

func _on_word_selection(excerpt_entry: Dictionary, word_entry: Dictionary, entry_id: String, word_id: String):
	var expected_answers_array: Array = my_controller.excerpt_controller.excerpts_dict[my_controller.excerpt_controller.active_excerpt_id]["WordsToReplace"]
	var to_lower_array: Array = my_controller._make_string_array_to_lower(expected_answers_array)
	if to_lower_array.find(word_id.to_lower()) != -1:
		text += generate_string_output("99%", entry_id, word_id)
		return
	else:
		var random_int: int = randi_range(5,35)
		var random_string: String = str(random_int)
		text += generate_string_output(random_string, entry_id, word_id)
		return
	var excerpt_theme_values_array = get_theme_values_array(excerpt_entry)
	var word_theme_values_array = get_theme_values_array(word_entry)
	var similarity_value = get_cosine_similarity(excerpt_theme_values_array, word_theme_values_array)
	var p_value = generate_p_value(similarity_value)
	text += generate_string_output(p_value, entry_id, word_id)

func get_theme_values_array(dict_entry: Dictionary):
	var themes_dict = dict_entry["Themes"]
	var target_themes: Array = themes_dict.keys()
	var themes_values_array: Array
	for key in target_themes:
		themes_values_array.append(themes_dict[key])
	return themes_values_array

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

func generate_string_output(p_value: String, entry_id: String, word_id: String):
	var new_line: String = ""
	if text != "":
		new_line = "\n"
	var string_output: String = new_line + "Generating probability from word(" + word_id +") and training data instance(" + entry_id + ")...\nGeneration complete...\nProbability = " + p_value
	return string_output #here we have to make sure that the words given do not give 99% other than the chosen words

func generate_p_value(similarity_value: float) -> String:
	var p_value: String
	if similarity_value >= 1.00:
		p_value = "100%"
	else:
		var string_sim = str(similarity_value)
		if string_sim.length() >= 4:
			string_sim = string_sim[2] + string_sim[3]
		else:
			string_sim = string_sim[2] + "0"
		p_value = string_sim + "%"
	return p_value
