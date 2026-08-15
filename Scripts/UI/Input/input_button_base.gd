extends Button

class_name InputButton

@export_enum("Letter", "Word", "Prompt") var type: String
var controller: Control
var sim_value: float #for use only in S3

func _ready() -> void:
	controller = get_parent().get_parent()
	connect("pressed", Callable(self, "_call_input_behaviour_by_type"))

# BASE FUNCTIONALITY
func _input(event: InputEvent) -> void:
	if type == "Letter":
		if Input.is_action_just_pressed(text):
			_call_input_behaviour_by_type()

func _call_input_behaviour_by_type():
	match type:
		"Letter":
			if controller.get_correct_given():
				return
			_letter_behaviour()
		"Word":
			_word_behaviour()
		"Prompt":
			_prompt_behaviour()
		_:
			push_error("ERROR: NO TYPE SET FOR INPUT BUTTON")

func _make_self_unclickable():
	pass

func _make_self_clickable():
	pass

func _visualise_self_clickable():
	pass

func _visualise_self_unclickable():
	pass

# LETTER FUNCTIONALITY

func _letter_behaviour():
	controller._letter_clicked(self) #CALL SOME MANAGER TO CALL SOME FUNCTION FOR NEXT SLOT IN WORD ; MAKE SELF UNCLICKABLE ; CHANGE SELF VISUAL THEME TO REFLECT THIS

func _call_stage_one_manager(letter: String):
	pass

# WORD FUNCTIONALITY

func _word_behaviour():
	controller._on_word_clicked(text)


# PROMPT FUNCTIONALITY

func _prompt_behaviour():
	controller._on_word_clicked(text, sim_value)
