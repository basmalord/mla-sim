extends Control

class_name DynamicLabelController

signal dynamic_label_success_process_complete

@onready var my_timer: Timer = $DynamicLabelTimer
@onready var my_other_timer: Timer = $LoadingTimer
@onready var instances_label: RichTextLabel = $InstancesLeftLabel
@onready var in_progress_label: RichTextLabel = $ProgressLabel
@onready var weight_progress_label: RichTextLabel = $WeightProfileLabel
@onready var weight_info_label: RichTextLabel = $StageTwoNetOutput
@export var text_speed: float = 0.5
@export var flash_speed: float = 1.0
@export var negative_flash_time: float = 3.0
@export var positive_flash_time: float = 3.0
@export var positive_flash_colour: Color = Color(0.161, 0.824, 0.157, 1.0)
@export var negative_flash_colour: Color = Color(0.933, 0.533, 0.251, 1.0)
@export var loading_time: float = 2.5
var pause_animation_check: bool = false
var instances_remaining: int = 5
var instances_string_array: Array[String] = [" Instances Remaining (0)"," Instances Remaining (1)"," Instances Remaining (2)"," Instances Remaining (3)"," Instances Remaining (4)"," Instances Remaining (5)"]
var in_progress_string_array: Array[String] = ["Training in progress", "Loading new training instance"]
var in_progress_target_index: int = 0
var weight_progress_string_array: Array[String] =["(gb_govt_weight_profile: 'Justice_wp')","(gb_govt_weight_profile: 'Order_wp')","(gb_govt_weight_profile: 'Peace_wp')","(gb_govt_weight_profile: 'Equality_wp')"]
var weight_progress_index: int = 0

@export var weight_info_string_array: Array[String] #for this, go 'justice', 'order', 'peace', 'equality'

func _ready():
	animate_elipses(in_progress_label)

func _set_weight_info_text(index: int):
	if weight_info_string_array.is_empty() == false:
		weight_info_label.text = weight_info_string_array[index]

func animate_elipses(label_node: RichTextLabel): #while loop might cause some lag, come here to change if so
	while pause_animation_check == false:
		await get_tree().create_timer(text_speed).timeout
		# Animate ellipses
		if label_node.text.ends_with("..."):
			label_node.text = label_node.text.trim_suffix("...")
		else:
			label_node.text += "."

func _update_instances_text():
	instances_remaining -=1
	instances_label.text = instances_string_array[instances_remaining]

func _update_progress_text():
	in_progress_target_index += 1
	if in_progress_target_index > 1:
		in_progress_target_index = 0
	in_progress_label.text = in_progress_string_array[in_progress_target_index]
	_set_weight_info_text(in_progress_target_index)

func _update_weight_progress_label():
	if instances_remaining != 0:
		return
	weight_progress_index += 1
	if weight_progress_index == weight_progress_string_array.size():
		return
	weight_progress_label.text = weight_progress_string_array[weight_progress_index]

func _on_success(): #need to hook this up to main, then have main await for signal to begin next guess
	_update_instances_text()
	_flash_label("positive", instances_label)
	pause_animation_check = true
	await get_tree().process_frame
	_update_progress_text()
	await get_tree().process_frame
	my_other_timer.start(loading_time)
	await my_other_timer.timeout
	_update_weight_progress_label()
	_update_progress_text()
	pause_animation_check = false
	await get_tree().process_frame
	if instances_remaining == 0:
		instances_remaining = 6
		_update_instances_text()
	animate_elipses(in_progress_label)
	emit_signal("dynamic_label_success_process_complete")

func _on_failure():
	_flash_label("negative", instances_label)

func _flash_label(behaviour: String, node: Node):
	var colour: Color = Color(1.3, 1.3, 1.3)
	var time: float = negative_flash_time
	match behaviour:
		"positive":
			colour = positive_flash_colour
			time = positive_flash_time
		"negative":
			colour = negative_flash_colour
	my_timer.start(time)
	while my_timer.time_left > 0:
		var tween = create_tween()
		tween.tween_property(node, "modulate", colour, flash_speed * 0.5)
		tween.tween_property(node, "modulate", Color.WHITE, flash_speed * 0.5)
		await get_tree().create_timer(flash_speed).timeout
