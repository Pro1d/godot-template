extends Node3D

@export var rect_size := Vector2(3.0, 3.0)

var _drawing := false
var _start_point := -Vector2.ONE
var _end_point := Vector2.ONE

@onready var _xr_root := $XROrigin3D as XRRoot
@onready var _visual_rect := $MeshInstance3D2 as VisualRect

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
			_xr_root.align_world_to(_visual_rect.get_transform2())
			_visual_rect.clear_rotation_and_position()
			Config.console.print_line("xr_root %s" % [_xr_root.position])
			Config.console.print_line("xr_root %sdeg" % [_xr_root.rotation_degrees.y])
			Config.console.print_line("rect ratio %s m/cell" % [(_visual_rect.get_size() / rect_size).x])
	
	var label := ($XROrigin3D/XRControllerRight/Label3D as Label3D)
	if _drawing:
		label.text = "%.3f %.3f %s" % [event.position.x, -event.position.z, event.event_type]
		label.show()
		_visual_rect.set_rect2(_start_point, _end_point, rect_size)
	else:
		label.hide()
	# rotation + side/corner resize axis-aligned handles (+ center move
	# 2 opposite corners handle
