extends Node

class_name SpecialCommandsHandler

signal prompt_displayed_or_new_passive_prompt_ready

@onready var my_controller: Node = get_parent()

var template: Dictionary = {"SpecialCommands":
	{
		"Word":
			{
				"Add":
					{
						"test":
						{
							"Themes":
								{
									
								},
							"WordType": "noun",
						}
					},
				"Update":
				{
					"lantern": [{"city": 1.00}, {"travel": -0.30}]
				},
			},
		"UpdateModel": [{"law": 0.1}, {"order": 0.2}, {"peace": -0.1}, {"equality": -0.1}],
		"Show":
			{
				"TargetNodes": [{"options": false}, {"goals": true}],
			},
		"Highlight": ["options", "goals"],
		"UpdateProbability": 0.85
	},
	}

func _ready():
	pass

func _on_prompt_displayed_or_new_passive_ready(special_commands_dict: Dictionary):
	call_deferred("_receive_special_commands", special_commands_dict) # testing, insert tested function here
	print("prior to prompt displayed signal from controller bloo", special_commands_dict)
	emit_signal("prompt_displayed_or_new_passive_prompt_ready")

func _receive_special_commands(special_commands_dict: Dictionary):
	print("start of special commands dict, bloo", special_commands_dict)
	var add_dict: Dictionary = {}
	var update_dict: Dictionary = {}
	var update_model_array: Array = []
	var show_array: Array = []
	var highlight_array: Array = []
	var update_probability_threshold_float: float = -1.00
	for key in special_commands_dict.keys():
		match key:
			"Word":
				for word_key in special_commands_dict["Word"]:
					match word_key:
						"Add":
							add_dict = special_commands_dict[key][word_key]
						"Update":
							update_dict = special_commands_dict[key][word_key]
			"UpdateModel":
				update_model_array = special_commands_dict["UpdateModel"]
			"Show":
				show_array = special_commands_dict["Show"]["TargetNodes"]
			"Highlight":
				highlight_array = special_commands_dict["Highlight"]
			"UpdateProbability":
				update_probability_threshold_float = special_commands_dict["UpdateProbability"]
	_handle_add_words(add_dict)
	_handle_update_words(update_dict)
	_handle_update_model_array(update_model_array)
	_handle_show_nodes(show_array)
	_handle_highlight_nodes(highlight_array)
	_handle_update_probability_threshold(update_probability_threshold_float)


func _handle_add_words(add_dict: Dictionary): #unpacks add dict and sends each word inside to the larger word dict
	if add_dict.is_empty():
		return
	var words_array: Array[String]
	for key in add_dict.keys():
		words_array.append(key)
	var word_dict_reference = my_controller.associations_manager.word_dict
	await prompt_displayed_or_new_passive_prompt_ready
	for index in words_array.size():
		word_dict_reference[words_array[index]] = add_dict[words_array[index]] #works
	print("end of add words SC")


func _handle_update_words(update_dict: Dictionary):
	if update_dict.is_empty():
		return
	var word_dict_reference = my_controller.associations_manager.word_dict
	await prompt_displayed_or_new_passive_prompt_ready
	for key in update_dict.keys():
		if word_dict_reference.has(key):
			var theme_changes_array: Array = update_dict[key]
			var theme_strings_array: Array
			var theme_values_array: Array
			var theme_values_reference: Dictionary = word_dict_reference[key]["Themes"]
			for entry in theme_changes_array:
				theme_strings_array.append(entry.keys()[0])
				theme_values_array.append(entry[theme_strings_array.back()])
			for theme in theme_strings_array:
				if theme_values_reference.has(theme):
					print("we did it from special")
					var index: int = theme_strings_array.find(theme)
					theme_values_reference[theme] += theme_values_array[index]
					if theme_values_reference[theme] > 1.00:
						theme_values_reference[theme] = 1.00
					elif theme_values_reference[theme] < 0.00:
						theme_values_reference[theme] = 0.00 #works
	print("end of update words SC")

func _handle_update_model_array(update_model_array: Array):
	if update_model_array.is_empty():
		return
	var model_reference_node: Node = my_controller.user_goals_manager
	var data_reference: Dictionary = model_reference_node.user_goals_dict
	await prompt_displayed_or_new_passive_prompt_ready
	var model_weights_array: Array[String]
	var values_array: Array[float]
	for entry in update_model_array:
		var model_weight: String = entry.keys()[0]
		model_weights_array.append(model_weight)
		var value: float = entry[model_weight]
		values_array.append(value)
	for index in model_weights_array.size():
		var model_weight: String = model_weights_array[index]
		var value: float = values_array[index]
		if data_reference.has(model_weight):
			data_reference[model_weight] += value
		else:
			data_reference[model_weight] = value
		if data_reference[model_weight] < 0.00:
			data_reference[model_weight] = 0.00
	print("end of update model SC")

func _handle_show_nodes(show_dict: Array):
	if show_dict.is_empty():
		return
	var goals_options_reference = my_controller.response_selection_menu
	var input_options_reference = my_controller.options_manager
	await prompt_displayed_or_new_passive_prompt_ready
	goals_options_reference._show_all_word_buttons()
	var is_disabled: bool = show_dict[1][show_dict[1].keys()[0]]
	if is_disabled:
		goals_options_reference._disable_all_word_buttons()
	elif !is_disabled:
		goals_options_reference._enable_all_word_buttons()
	input_options_reference._show_all_buttons()
	is_disabled = show_dict[0][show_dict[0].keys()[0]]
	if is_disabled:
		input_options_reference._disable_all_buttons()
	elif !is_disabled:
		input_options_reference._enable_all_buttons()
	print("end of show nodes SC")


func _handle_highlight_nodes(highlight_array: Array):
	if highlight_array.is_empty():
		return
	var goals_options_reference = my_controller.response_selection_menu
	var input_options_reference = my_controller.options_manager
	await prompt_displayed_or_new_passive_prompt_ready
	goals_options_reference._flash_all_buttons()
	input_options_reference._flash_all_buttons()
	print("end of highlight SC")

func _handle_update_probability_threshold(update_value: float, from_tutorial: bool = false): #works
	if update_value == -1.00:
		return
	var confidence_node_reference = my_controller.confidence_manager
	if !from_tutorial:
		await prompt_displayed_or_new_passive_prompt_ready
	confidence_node_reference.confidence_requirement = update_value
	confidence_node_reference.call_deferred("_display_confidence_threshold") #works
	print("end of update probability threshold SC")
