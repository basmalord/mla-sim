extends Control

@onready var my_rtl: RichTextLabel = $ConfidenceRTL
@onready var my_threshold_rtl: RichTextLabel = $ConfidenceThreshold

@export_range(0.4,1,0.01) var positive_flash_timer: float = 0.5
@export_range(0.4,1,0.01) var negative_flash_timer: float = 0.5
@export_range(0,2,0.1) var flash_length: float = 2.5
@export var positive_flash_colour: Color = Color(0.161, 0.824, 0.157, 1.0)
@export var negative_flash_colour: Color = Color(0.933, 0.533, 0.251, 1.0)
@export var confidence_requirement: float = 1.00

var confidence_ratings: Array[float] = []
var last_value: int
var last_threshold_value: int = 100

func _ready():
	pass

func _does_not_meet_confidence_threshold_behaviour():
	_flash_button("negative")
	_flash_button("negative", my_threshold_rtl)

func _negative_indication_behaviour():
	_flash_button("negative")

func _positive_indication_behaviour():
	_flash_button("positive")

func _new_confidence_visual_behaviour(behaviour: String, node: Node):
	_flash_button(behaviour, node)

func _alter_shadow_outline(value: int, target_rtl: RichTextLabel = my_rtl):
	target_rtl.add_theme_constant_override("shadow_outline_size", value)

func _flash_button(behaviour: String, node_to_flash: Node = my_rtl):
	var original_colour: Color = node_to_flash.get_self_modulate()
	var original_font_shadow_colour: Color = Color(0,0,0,0)
	var timer_going: bool = true
	match behaviour:
		"positive":
			node_to_flash.add_theme_color_override("font_shadow_color", positive_flash_colour)
			var timer = get_tree().create_timer(flash_length)
			while timer.time_left > 0:
				await get_tree().create_timer(positive_flash_timer).timeout
				var font_tween = create_tween()
				var shadow_tween = create_tween()
				shadow_tween.tween_method(_alter_shadow_outline, 1, 5 , positive_flash_timer)
				font_tween.tween_property(node_to_flash, "modulate", positive_flash_colour, positive_flash_timer)
				font_tween.tween_property(node_to_flash, "modulate", original_colour, positive_flash_timer)
				await get_tree().process_frame
		"negative":
			node_to_flash.add_theme_color_override("font_shadow_color", negative_flash_colour)
			var timer = get_tree().create_timer(flash_length)
			while timer.time_left > 0:
				await get_tree().create_timer(positive_flash_timer).timeout
				var tween = create_tween()
				var shadow_tween = create_tween()
				shadow_tween.tween_method(_alter_shadow_outline, 1, 5 , negative_flash_timer)
				tween.tween_property(node_to_flash, "modulate", negative_flash_colour, negative_flash_timer)
				tween.tween_property(node_to_flash, "modulate", original_colour, negative_flash_timer)
				await get_tree().process_frame
	node_to_flash.add_theme_color_override("font_shadow_color", Color(0.161, 0.824, 0.157, 0.0))


func get_average_confidence_rating():
	var average_confidence_rating: float
	var cumulative_confidence_rating: float = 0.00
	var size_of_set: int = confidence_ratings.size()
	for rating in confidence_ratings:
		cumulative_confidence_rating += rating
	average_confidence_rating = cumulative_confidence_rating / size_of_set
	return average_confidence_rating

func _display_confidence_threshold():
	var display_threshold_value: int = confidence_requirement * 100
	var threshold_string: String = str(display_threshold_value) + "%"
	my_threshold_rtl.text = threshold_string
	if display_threshold_value > last_threshold_value:
		_new_confidence_visual_behaviour("negative", my_threshold_rtl)
	elif display_threshold_value < last_threshold_value:
		_new_confidence_visual_behaviour("positive", my_threshold_rtl)
	display_threshold_value = last_threshold_value


func _display_new_confidence(new_confidence: float):
	var display_value: int = new_confidence * 100
	var new_confidence_string: String = str(display_value)
	my_rtl.text = new_confidence_string 

func _on_word_clicked(word_confidence: float):
	confidence_ratings.append(word_confidence)
	_display_new_confidence(get_average_confidence_rating())

func _on_remove_word_clicked():
	_display_new_confidence(last_value)
	confidence_ratings.pop_back()

func _on_erase_section(number_of_chosen_words: int):
	for i in number_of_chosen_words:
		confidence_ratings.pop_back()
	if confidence_ratings.size() == 0:
		_display_new_confidence(0.00)
	else:
		_display_new_confidence(get_average_confidence_rating())
