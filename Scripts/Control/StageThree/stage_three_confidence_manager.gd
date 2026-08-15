extends Control

@onready var my_rtl: RichTextLabel = $ConfidenceRTL

@export var confidence_requirement: float = 1.00

var confidence_ratings: Array[float] = []


func get_average_confidence_rating():
	var average_confidence_rating: float
	var cumulative_confidence_rating: float = 0.00
	var size_of_set: int = confidence_ratings.size()
	for rating in confidence_ratings:
		cumulative_confidence_rating += rating
	average_confidence_rating = cumulative_confidence_rating / size_of_set
	return average_confidence_rating

func _display_new_confidence(new_confidence: float):
	var new_confidence_string: String = "%.2f" % new_confidence
	var requirement_string: String = str(confidence_requirement)
	my_rtl.text = new_confidence_string + " / " + requirement_string

func _on_word_clicked(word_confidence: float):
	confidence_ratings.append(word_confidence)
	_display_new_confidence(get_average_confidence_rating())

func _on_remove_word_clicked():
	confidence_ratings.pop_back()
	_display_new_confidence(get_average_confidence_rating())

func _on_erase_section(number_of_chosen_words: int):
	for i in number_of_chosen_words:
		confidence_ratings.pop_back()
	_display_new_confidence(get_average_confidence_rating())
