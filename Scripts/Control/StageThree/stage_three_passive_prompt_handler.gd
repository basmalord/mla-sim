extends Node

class_name PassivePromptHandler

var passive_prompt_dict: Dictionary

func _set_data_res(data):
	passive_prompt_dict = data

func _generate_passive_prompt(acceptability: String, chosen_words_array: Array[Dictionary], response_id: String, response_section_id: String):
	var original_prompt_entry: Dictionary = passive_prompt_dict[response_id][response_section_id][acceptability]
	var text: String = original_prompt_entry["PromptString"]
	var words_to_replace: Array = original_prompt_entry["WordsToReplace"]
	if words_to_replace.size() == 0:
		return text
	for word_entry in words_to_replace: #this must always work backwards, where words_to_replace must always begin with the last word to replace in the string, or else the target index will be messed up after 1 loop
		var word_to_insert: String = chosen_words_array[words_to_replace.find(word_entry)].keys()[0] #get the chose word from its array
		var word = word_entry.keys()[0] # gets the word to replace
		var target_index: int = word_entry[word] #gets the starting of the word to replace within the string
		text = _replace_word_in_string(text, word, word_to_insert, target_index)
	return text


func _replace_word_in_string(prompt: String, word_to_replace: String, word_to_insert: String, index: int) -> String:
	var replace_length := word_to_replace.length()
	prompt = prompt.substr(0, index) + word_to_insert + prompt.substr(index + replace_length)
	return prompt
