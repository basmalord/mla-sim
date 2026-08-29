extends Node

@export var incorrect_word_type_rate: int = -20
@export var correct_word_type_rate: int = 5
@export var partially_unintelligible_rate: int = -5
@export var unintelligible_rate: int = -10
@export var unacceptable_rate: int = -20
@export var acceptable_rate: int = 20
@export var default_user_satisfaction: int = 50
var user_satisfaction: int = 50

func _reset_user_satisfaction():
	user_satisfaction = 50 # should be some export value but aw well

func _amend_user_satisfaction(acceptability: String, words_array: Array[Dictionary]):
	match acceptability:
		"acceptable":
			user_satisfaction += acceptable_rate
		"unacceptable":
			user_satisfaction += unacceptable_rate
		"unintelligible":
			user_satisfaction += unintelligible_rate
		"partially_unintelligible":
			user_satisfaction += partially_unintelligible_rate
	for entry in words_array: #if the word type matched the word type required, then +, opposite is true
		for value in entry:
			if value:
				user_satisfaction += correct_word_type_rate
			elif !value:
				user_satisfaction += incorrect_word_type_rate
