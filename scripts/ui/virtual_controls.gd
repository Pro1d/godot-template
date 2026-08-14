class_name VirtualControls
extends Container

@export var button_a_action_name := "ui_accept"
@export var button_b_action_name := "ui_cancel"
@onready var _button_a: Button = %ButtonA
@onready var _button_b: Button = %ButtonB

func _ready() -> void:
	visible = Config.is_mobile_device()
	
	_button_a.button_down.connect(trigger_action.bind(button_a_action_name, true))
	_button_a.button_up.connect(trigger_action.bind(button_a_action_name, false))
	
	_button_b.button_down.connect(trigger_action.bind(button_b_action_name, true))
	_button_b.button_up.connect(trigger_action.bind(button_b_action_name, false))

func trigger_action(action_name: String, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action_name
	event.pressed = pressed
	Input.parse_input_event(event)
