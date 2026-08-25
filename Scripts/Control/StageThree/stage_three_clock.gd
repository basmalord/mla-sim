extends Control

signal hours_augmented
signal days_augmeneted
signal months_augmented
signal time_passed
signal day_ended
signal end_day_started

const animation_time_ms: int = 5000
const time_per_visual_change_ms: int = 38

@onready var my_time_rtl: RichTextLabel = $TimeRTL
@onready var my_date_rtl: RichTextLabel = $DateRTL
var my_animation_player: AnimationPlayer 

@export_range(1.00,10.00,0.10) var animation_time: float
@export var time_spacing: int = 0
@export var date_spacing: int = 0
@export var end_day_wait_time: int = 4


var default_hours: String = "00"
var default_minutes: String = "00"
var default_days: String = "01"
var default_months: String = "07"
var default_years: String = "2025"

var time_conversion_dict: Dictionary = {"minute": 1, "hour": 60, "day": 1440, "week": 10080, "month": 44640}
var texture_rect: TextureRect 
var hours: int = 0
var minutes: int = 0
var days: int = 0
var months: int = 0
var years: int

var original_positions: Array[Vector2]
var original_sizes: Array[Vector2]
var original_font_sizes: Array[int]

var amount_of_minutes_to_animate: int = 0

func _ready() -> void:
	texture_rect = get_parent().get_children()[0]
	my_animation_player = get_parent()
	_set_original_data_arrays()
	_set_date_label_text()
	_set_time_label_text()
	connect("days_augmeneted", Callable(self, "_set_date_label_text"))
	connect("end_day_started", Callable(my_animation_player, "play"))
	#_end_day()

func _end_day():
	_let_time_pass("minute", get_minutes_from_current_to_target_next(), true, true)
	await time_passed
	my_animation_player.current_animation = "clock_animation"
	emit_signal("end_day_started")
	await my_animation_player.animation_finished
	await get_tree().create_timer(end_day_wait_time).timeout
	my_animation_player.play_backwards("clock_animation")
	emit_signal("day_ended")

func get_minutes_from_current_to_target_next(target_hour: int = 10):
	var minute_difference: int = 60 - minutes
	minute_difference = 60 - minute_difference
	var hour_difference: int = 0
	var hour_marker: int = hours
	while hour_marker != target_hour:
		hour_marker += 1
		hour_difference += 1
		if hour_marker == 24:
			hour_marker = 0
	var hours_in_minutes = hour_difference * time_conversion_dict["hour"]
	var total_minutes: int = hours_in_minutes - minute_difference
	var random_multiplier: int = 0
	while random_multiplier == 0:
		random_multiplier = randi_range(-1,1)
	var total_minutes_randomised: int = total_minutes + ( randi_range(1,10) * random_multiplier )
	return total_minutes_randomised

func _set_original_data_arrays():
	for child in get_children():
		var child_position: Vector2 = child.position
		var child_size: Vector2 = child.size
		var child_font_size: int = child.get_theme_font_size("normal_font_size")
		original_positions.append(child_position)
		original_sizes.append(child_size)
		original_font_sizes.append(child_font_size)

func _increase_months_by_one():
	months += 1
	emit_signal("months_augmented")

func _increase_days_by_one():
	days += 1
	if days > 31:
		_increase_months_by_one()
		#await months_augmented
		days = 0
	emit_signal("days_augmeneted")

func _increase_hours_by_one():
	hours += 1
	if hours > 23:
		_increase_days_by_one()
		#await days_augmeneted
		hours = 0
	emit_signal("hours_augmented")

func _increase_minutes_by_one():
	minutes += 1
	if minutes > 59:
		_increase_hours_by_one()
		#await hours_augmented
		minutes = 0

func _set_date_label_text():
	my_date_rtl.text = stringify_date()

func _set_time_simply(candidate_hours: int, candidate_minutes: int):
	hours = candidate_hours
	minutes = candidate_minutes
	_set_time_label_text()

func _let_time_pass(unit_type: String, amount_of_unit: int, is_animated: bool, is_end_day: bool = false):
	var minutes_per_unit: int = time_conversion_dict[unit_type]
	var total_minutes: int = amount_of_unit * minutes_per_unit
	if !is_end_day:
		for minute in total_minutes:
			_increase_minutes_by_one()
			if is_animated:
				_set_time_label_text()
				await get_tree().process_frame
		if !is_animated:
			_set_time_label_text()
	else:
		var ratio: int = get_time_to_add_to_animation_time_ratio(total_minutes)
		print("this is ratio: ",ratio)
		var start: int = Time.get_ticks_msec()
		print("this is start: ", start)
		var elapsed: int = 0
		var show_change_timer: int = time_per_visual_change_ms - 1
		var next_update: int = 0
		while total_minutes > 0:
			elapsed = Time.get_ticks_msec() - start
			if elapsed % ratio == 0:
				#next_update += ratio
				_increase_minutes_by_one()
				_set_time_label_text()
				total_minutes -= 1
				show_change_timer += 1
				if show_change_timer == time_per_visual_change_ms:
					show_change_timer = 0
					var randomiser: int = randi_range(0,3)
					for i in randomiser:
						_increase_minutes_by_one()
						total_minutes -= 1
						show_change_timer += 1
					_increase_minutes_by_one()
					await get_tree().process_frame
	emit_signal("time_passed")

func get_time_to_add_to_animation_time_ratio(time_to_add: int):
	print("this is time to add: ", time_to_add, "this is animation_time_ms: ", animation_time_ms)
	var time_to_add_float: float = float(time_to_add)
	var animation_time_ms_float: float = float(animation_time_ms)
	var ratio_float: float = time_to_add_float / animation_time_ms_float
	print("this is ratio float before multiplication: ", ratio_float)
	ratio_float = ratio_float * 1000.00
	print("this is ratio float: ", ratio_float)
	var ratio_int: int = int(ratio_float)
	return ratio_int

func stringify_date():
	var new_date_string: String
	var days_string: String = str(days)
	var months_string: String = str(months)
	var years_string: String = str(years)
	if years == 0:
		years_string = default_years
	if days_string.length() < 2 and days_string.length() > 0:
		days_string = "0" + days_string
	if months_string.length() < 2 and months_string.length() > 0:
		months_string = "0" + months_string
	var spacing: String = ""
	for space in date_spacing:
		spacing += " "
	new_date_string = days_string + spacing + "/" + spacing + months_string + spacing + "/" + spacing + years_string
	return new_date_string

func stringify_time():
	var new_time_string: String
	var hours_string: String = str(hours)
	if hours_string.length() < 2 and hours_string.length() > 0:
		hours_string = "0" + hours_string
	var minutes_string: String = str(minutes)
	if minutes_string.length() < 2 and minutes_string.length() > 0:
		minutes_string = "0" + minutes_string
	var spacing: String = ""
	for space in time_spacing:
		spacing += " "
	new_time_string = hours_string + spacing + ":" + spacing + minutes_string
	return new_time_string

func _set_time_label_text():
	my_time_rtl.text = stringify_time()
