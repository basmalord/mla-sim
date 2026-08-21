extends Node

signal benchmark_finished

var hours: int = 0
var minutes: int = 0
var days: int = 0
var day_clock_benchmark_time_ms: int 
var benchmark_start: int = 0
var control: String


func _ready():
	pass
	#_start_benchmark_time()
	#for i in 1440:
		#_increase_minutes_by_one()
		#control = "blah"
		#await get_tree().process_frame
	#print("this is benchmark time in ms: ", day_clock_benchmark_time_ms)

func _start_benchmark_time():
	benchmark_start = Time.get_ticks_msec()

func _stop_benchmark():
	var elapsed = Time.get_ticks_msec() - benchmark_start
	return elapsed

func _increase_days_by_one():
	days += 1
	if days > 31:
		#await months_augmented
		days = 0
	day_clock_benchmark_time_ms = _stop_benchmark()

func _increase_hours_by_one():
	hours += 1
	if hours > 23:
		_increase_days_by_one()
		#await days_augmeneted
		hours = 0

func _increase_minutes_by_one():
	minutes += 1
	if minutes > 59:
		_increase_hours_by_one()
		#await hours_augmented
		minutes = 0
