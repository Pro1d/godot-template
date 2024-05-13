@tool
class_name Door
extends Node3D

# TODO manual trigger
# TODO only one door open at a time: close previous door and wait vully closed before opning a new one

enum State { OPENED, CLOSING, CLOSED, OPENING }

@export var front_area : MapArea
@export var back_area : MapArea

@export var proximity_trigger := true

var size := 1.0 : 
	set(s): 
		if s != size:
			size = s
			_update_size()
var state := State.CLOSED
var _front_closed_occluders: Array[SegmentShape2D] = [SegmentShape2D.new()]
var _back_closed_occluders: Array[SegmentShape2D] = [SegmentShape2D.new()]

@onready var _base_position := position

func _ready() -> void:
	if front_area != null and back_area != null:
		if proximity_trigger:
			front_area.camera_inside_changed.connect(_on_area_proximity_changed)
			back_area.camera_inside_changed.connect(_on_area_proximity_changed)
		
		_update_visibility()
		front_area.visibility_changed.connect(_update_visibility)
		back_area.visibility_changed.connect(_update_visibility)
	
		var direction := Geometry.to_direction_index3(front_area.position, back_area.position)
		front_area.register_door(self, direction)
		back_area.register_door(self, direction ^ 2)
	
	var t2 := Geometry.to_transform_2d(transform)
	_front_closed_occluders[-1].a = t2.basis_xform(Vector2(.5, -.5))
	_front_closed_occluders[-1].b = t2.basis_xform(Vector2(.5, .5))
	_back_closed_occluders[-1].a = t2.basis_xform(Vector2(-.5, .5)) #_front_closed_occluders[-1].b
	_back_closed_occluders[-1].b = t2.basis_xform(Vector2(-.5, -.5)) #_front_closed_occluders[-1].a
	
	_update_size()

func _on_area_proximity_changed(_inside: bool) -> void:
	var command_open := front_area.camera_inside or back_area.camera_inside
	match state:
		State.CLOSING, State.CLOSED:
			if command_open:
				trigger_open()
		State.OPENING, State.OPENED:
			if not command_open:
				trigger_close()

func _update_visibility() -> void:
	# FIXME consider camera_origin to check visibility
	visible = front_area.visible or back_area.visible

func _update_size() -> void:
	scale = Vector3(size, 1, size)
	position = _base_position * size

func trigger_open() -> void:
	# Default implementation to be overriden by subclass
	state = State.OPENED
	# ($MeshInstance3D as MeshInstance3D).visible = false

func trigger_close() -> void:
	# Default implementation to be overriden by subclass
	state = State.CLOSED
	# ($MeshInstance3D as MeshInstance3D).visible = true

func _open_occluders(_front: bool) -> Array[SegmentShape2D]:
	# Default implementation to be overriden by subclass
	return []

func get_occluders(area: MapArea) -> Array[SegmentShape2D]:
	var front := area == front_area
	if state == State.CLOSED:
		return _front_closed_occluders if front else _back_closed_occluders
	else:
		return []

# Whether the player can see through the door
func passthrough() -> bool:
	# Default implementation to be overriden by subclass
	return state != State.CLOSED

# Whether the player can cross the door
func is_opened() -> bool:
	# FIXME? consider crossable when state == State.OPENING
	return state == State.OPENED
