extends Control


@onready var my_controller = get_parent()
@onready var remove_last_button: Button = $RemoveButton

func _on_remove_last_clicked():
	my_controller._on_remove_last_clicked()

func _on_confirm_clicked():
	my_controller._on_confirm_clicked()
