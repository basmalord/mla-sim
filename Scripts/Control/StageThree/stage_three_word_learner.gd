extends Node

@export_range(0.01, 1.00) var word_learning_rate: float = 0.10


func word_learn_theme_from_excerpt(word_value: float, prompt_value: float):
	var additive_weight_value: float = prompt_value * word_learning_rate
	word_value += additive_weight_value
	return word_value
