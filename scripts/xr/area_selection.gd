extends Node3D

@export var rect_size := Vector2(2.0, 2.5)

var _drawing := false
var _start_point := -Vector2.ONE
var _end_point := Vector2.ONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pointer := %FunctionPointer as XRToolsFunctionPointer
	pointer.pointing_event.connect(_on_pointing_event)

func _on_pointing_event(event: XRToolsPointerEvent) -> void:
	match event.event_type:
		XRToolsPointerEvent.Type.PRESSED:
			_start_point.x = event.position.x
			_start_point.y = -event.position.z
			_drawing = true
		XRToolsPointerEvent.Type.MOVED:
			_end_point.x = event.position.x
			_end_point.y = -event.position.z
		XRToolsPointerEvent.Type.RELEASED:
			_drawing = false
	
	var label := ($XROrigin3D/XRControllerRight/Label3D as Label3D)
	if _drawing:
		label.text = "%.3f %.3f %s" % [event.position.x, -event.position.z, event.event_type]
		label.show()
		($MeshInstance3D2 as VisualRect).set_rect2(_start_point, _end_point, rect_size)
	else:
		label.hide()
	# rotation + side/corner resize axis-aligned handles (+ center move
	# 2 opposite corners handle
