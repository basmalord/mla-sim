extends Control

@onready var my_controller = get_parent()
@onready var continue_button: Button = $ContinueButton
@onready var restart_button: Button = $RestartButton
@onready var quit_button: Button = $QuitButton
@onready var sure_rect: TextureRect =$SureRect
var from_quit: bool = false
var from_restart: bool = false

func _reset_bools():
	from_quit = false
	from_restart = false

func _disable_all_big_buttons():
	continue_button.disabled = true
	restart_button.disabled = true
	quit_button.disabled = true

func _enable_all_big_buttons():
	continue_button.disabled = false
	restart_button.disabled = false
	quit_button.disabled = false

func _show_sure_rect():
	sure_rect.show()
	_disable_all_big_buttons()

func _on_quit_button_pressed() -> void:
	from_quit = true
	_show_sure_rect()


func _on_restart_button_pressed() -> void:
	from_restart = true
	_show_sure_rect()


func _on_continue_button_pressed() -> void:
	my_controller.pause_menu.hide()
	my_controller.is_paused = false
	my_controller.stage_controller.process_mode = Node.PROCESS_MODE_PAUSABLE

func _on_full_quit_pressed() -> void:
	var wants_to_leave: bool = true
	match wants_to_leave:
		from_quit:
			get_tree().quit()
		from_restart:
			_reset_bools()
			_enable_all_big_buttons()
			my_controller._restart_behaviour()
			sure_rect.hide()


func _on_return_pressed() -> void:
	_reset_bools()
	_enable_all_big_buttons()
	sure_rect.hide()
