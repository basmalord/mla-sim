extends Node

signal word_array_set

var word_dict: Dictionary
var word_type_dict: Dictionary
var word_array: Array = []
var cosine_similarity_array: Array[float]

func get_word_to_prompt_similarity_entry_array(number_of_words_to_get: int = -1):
	var word_to_prompt_similarity_entry_array: Dictionary = {}
	for index in word_array.size():
		var target_word: String = word_array[index]
		var target_similarity_value: float = cosine_similarity_array[index]
		if number_of_words_to_get == -1:
			word_to_prompt_similarity_entry_array[target_word] = target_similarity_value
		else:
			if word_to_prompt_similarity_entry_array.keys().size() < number_of_words_to_get:
				word_to_prompt_similarity_entry_array[target_word] = target_similarity_value
			else:
				var lowest_word: String = word_to_prompt_similarity_entry_array.keys()[0]
				for word in word_to_prompt_similarity_entry_array.keys():
					if word_to_prompt_similarity_entry_array[word] < word_to_prompt_similarity_entry_array[lowest_word]:
						lowest_word = word
				if target_similarity_value > word_to_prompt_similarity_entry_array[lowest_word]:
					word_to_prompt_similarity_entry_array.erase(lowest_word)
					lowest_word = target_word
					word_to_prompt_similarity_entry_array[target_word] = target_similarity_value
	return word_to_prompt_similarity_entry_array

func _handle_engineering_changes(word_association_changes: Dictionary):
	word_association_changes = word_association_changes.duplicate_deep()
	var words_array: Array = word_association_changes.keys()
	for word in words_array:
		var word_entry: Dictionary = word_association_changes[word]
		var theme_changes_dict: Dictionary = word_association_changes[word]["Themes"]
		var word_type: String = word_entry["WordType"]
		if word_entry.has("NewWord") and word_dict.has(word) == false:
			for index in theme_changes_dict.size() - 1:
				var key = theme_changes_dict.keys()[index]
				var value = theme_changes_dict[key]
				if value < 0:
					theme_changes_dict[key] = 0
				elif value > 1:
					theme_changes_dict[key] = 1
			var new_entry: Dictionary ={"Themes": theme_changes_dict, "WordType": word_type}
			word_dict[word] = new_entry
		else:
			for index in theme_changes_dict.size() - 1:
				var key = theme_changes_dict.keys()[index]
				var addition = theme_changes_dict[key]
				var old_value = word_dict[word]["Themes"][key]
				var new_value = old_value + addition
				if new_value < 0:
					new_value = 0
				elif new_value > 1:
					new_value = 1
				word_dict[word]["Themes"][key] = new_value

func get_word_type(word: String):
	return word_dict[word]["WordType"]

func _set_data_res(data: Dictionary):
	word_dict = data
	_generate_word_array()

func _generate_word_array():
	word_array = word_dict.keys()
	emit_signal("word_array_set")

func _generate_cosine_similarity_array(prompt_dict_entry: Dictionary):
	if word_array == []:
		await word_array_set
	cosine_similarity_array = []
	var prompt_themes_values_array: Array[float] = get_prompt_theme_values(prompt_dict_entry)
	var target_word_themes_array: Array[float]
	var target_prompt_themes_array_indexes: Array[int]
	var index_marker: int = 0
	for theme_value in prompt_themes_values_array:
		if theme_value == 0.00:
			target_prompt_themes_array_indexes.append(-1) #-1 indicates to skip the theme in generating cosine similarity
		else:
			target_prompt_themes_array_indexes.append(index_marker)
		index_marker += 1
	var mutated_prompt_array: Array[float]
	for index in prompt_themes_values_array.size():
		if target_prompt_themes_array_indexes[index] == -1:
			continue
		mutated_prompt_array.append(prompt_themes_values_array[index])
	var target_themes: Array
	var template_themes: Array = word_dict[word_dict.keys()[0]]["Themes"].keys()
	index_marker = 0
	for theme in template_themes:
		if target_prompt_themes_array_indexes[index_marker] == -1:
			index_marker += 1
			continue
		target_themes.append(template_themes[index_marker])
		index_marker += 1
	for word in word_array:
		target_word_themes_array = []
		for theme in target_themes:
			target_word_themes_array.append(word_dict[word]["Themes"][theme])
		cosine_similarity_array.append(get_cosine_similarity(mutated_prompt_array,target_word_themes_array))


func get_prompt_theme_values(prompt_entry: Dictionary):
	var prompt_theme_values_array: Array[float]
	var prompt_themes: Array = prompt_entry["Themes"].keys()
	for theme in prompt_themes:
		prompt_theme_values_array.append(prompt_entry["Themes"][theme])
	return prompt_theme_values_array

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

func _populate_word_type_dict(): # to be called after setting up word dict, can then be called by options when generating probability values
	for word in word_dict.keys():
		var target_type: String = word_dict[word]["Type"]
		word_type_dict[word] = target_type
