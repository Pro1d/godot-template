@tool
class_name MapArea
extends Node3D

signal camera_inside_changed(camera_inside: bool)

const wall_model := preload("res://assets/models/walls/side.res")
const inner_corner_model := preload("res://assets/models/walls/inner_corner1.res")
const outter_corner_model := preload("res://assets/models/walls/outter_corner1.res")

@export var auto_wall := true

@export_group("Neighbors", "neighbor_")
@export var neighbor_drop : MapArea : # Editor only
	set(a):
		if a != null:
			match(Geometry.to_direction_index(center_2d, a.center_2d)):
				0: neighbor_X_plus = a
				1: neighbor_Y_plus = a
				2: neighbor_X_minus = a
				3: neighbor_Y_minus = a
@export var neighbor_X_plus: MapArea :
	set(a):
		if neighbor_X_plus != a:
			var old := neighbor_X_plus
			neighbor_X_plus = a
			_make_neighbors()
			if old != null:
				old.neighbor_X_minus = null
			if a != null:
				a.neighbor_X_minus = self
			_create_mesh_instances()
			_build_occluders()
@export var neighbor_Y_plus: MapArea :
	set(a):
		if neighbor_Y_plus != a:
			var old := neighbor_Y_plus
			neighbor_Y_plus = a
			_make_neighbors()
			if old != null:
				old.neighbor_Y_minus = null
			if a != null:
				a.neighbor_Y_minus = self
			_create_mesh_instances()
			_build_occluders()
@export var neighbor_X_minus: MapArea :
	set(a):
		if neighbor_X_minus != a:
			var old := neighbor_X_minus
			neighbor_X_minus = a
			_make_neighbors()
			if old != null:
				old.neighbor_X_plus = null
			if a != null:
				a.neighbor_X_plus = self
			_create_mesh_instances()
			_build_occluders()
@export var neighbor_Y_minus: MapArea :
	set(a):
		if neighbor_Y_minus != a:
			var old := neighbor_Y_minus
			neighbor_Y_minus = a
			_make_neighbors()
			if old != null:
				old.neighbor_Y_plus = null
			if a != null:
				a.neighbor_Y_plus = self
			_create_mesh_instances()
			_build_occluders()

var neighbors : Array[MapArea]
var _doors : Array[Door] = [null, null, null, null]

var size := 1.0 :
	set(s):
		if size != s:
			size = s
			_update_scale()
var camera_inside := false :
	set(c):
		if c != camera_inside:
			camera_inside = c
			camera_inside_changed.emit(c)
var _occluders: Array[Array] = [[], [], [], []]

@onready var _base_position := position
@onready var center_2d := Geometry.to_vector2(_base_position)
@onready var _scaled_root := $ScaledStatic as Node3D
@onready var _ground_mesh_instance := $ScaledStatic/Ground as MeshInstance3D
@onready var _ceil_mesh_instance := $ScaledStatic/Ceil as MeshInstance3D
@onready var _wall_mesh_instance: Array[MeshInstance3D] = [$ScaledStatic/WallPZ, $ScaledStatic/WallZP, $ScaledStatic/WallNZ, $ScaledStatic/WallZN]
@onready var _corner_mesh_instance: Array[MeshInstance3D] = [$ScaledStatic/CornerPP, $ScaledStatic/CornerNP, $ScaledStatic/CornerNN, $ScaledStatic/CornerPN]

func _ready() -> void:
	_make_neighbors()
	_create_mesh_instances()
	_build_occluders()

func _make_neighbors() -> void:
	neighbors = [
		neighbor_X_plus,
		neighbor_Y_plus,
		neighbor_X_minus,
		neighbor_Y_minus,
	]

func _get_walls() -> Array[bool]:
	return [
		neighbor_X_plus == null,
		neighbor_Y_plus == null,
		neighbor_X_minus == null,
		neighbor_Y_minus == null,
	]

func _get_inner_corners(walls: Array[bool]) -> Array[bool]:
	var inner_corners: Array[bool] = []
	inner_corners.resize(4)
	for i in 4:
		inner_corners[i] = walls[i] and walls[(i+1) & 3]
	return inner_corners

func _get_outter_corners(walls: Array[bool], neighbor_walls: Array) -> Array[bool]:
	var outter_corners: Array[bool] = []
	outter_corners.resize(4)
	for i in 4:
		var j := (i + 1) & 3
		#print(name, " ", i, " ", j, "", walls," ",neighbor_walls)
		outter_corners[i] = (
			not walls[i] and not walls[j]
			and (neighbor_walls[i][j] or neighbor_walls[j][i])
		)
	return outter_corners

func _create_mesh_instances() -> void:
	if _ground_mesh_instance == null:
		return
	
	if auto_wall:
		var plane_mesh := PlaneMesh.new()
		plane_mesh.size = Vector2.ONE
		_ground_mesh_instance.mesh = plane_mesh
		_ceil_mesh_instance.mesh = plane_mesh
		_ceil_mesh_instance.position.y = 2.3
		_ceil_mesh_instance.rotate_y(PI)
		var walls := _get_walls()
		var inner_corners := _get_inner_corners(walls)
		var outter_corners := _get_outter_corners(
			walls,
			neighbors.map(func(area: MapArea) -> Array: return [] if area == null else area._get_walls())
		)
		for i in 4:
			_wall_mesh_instance[i].mesh = wall_model if walls[i] else null
				
			if inner_corners[i]:
				_corner_mesh_instance[i].mesh = inner_corner_model
			elif outter_corners[i]:
				_corner_mesh_instance[i].mesh = outter_corner_model
			else:
				_corner_mesh_instance[i].mesh = null
	_update_scale()

func _update_scale() -> void:
	_scaled_root.scale = Vector3(size, 1, size)
	position = _base_position * size

func _build_occluders() -> void:
	for o in _occluders:
		o.clear()
	if neighbors.is_empty():
		return
	# to override
	var corners: Array[Vector2] = [
		Vector2(.5, -.5), Vector2(.5, .5), Vector2(-.5, .5), Vector2(-.5, -.5)
	]
	for i in 4:
		if neighbors[i] == null:
			var seg := SegmentShape2D.new()
			seg.a = corners[i]
			seg.b = corners[(i + 1) % 4]
			# occluder
			_occluders[i].append(seg)

func register_door(door: Door, direction: int) -> void:
	_doors[direction] = door

func is_neighbor_reachable(direction: int) -> bool:
	return (
		neighbors[direction] != null
		and (_doors[direction] == null or _doors[direction].is_opened())
	)

func is_neighbor_visible(direction: int) -> bool:
	return (
		neighbors[direction] != null
		and (_doors[direction] == null or _doors[direction].passthrough())
	)

func get_occluders(direction: int) -> Array: # Array[SegmentShape2D]
	var door := _doors[direction]
	if door != null:
		return door.get_occluders(self)
	return _occluders[direction]

func set_state(active: bool, reachable: bool) -> void:
	assert(active or not reachable)
	visible = active
	if camera_inside and not reachable:
		Config.console.print_line("WARN - %s disabled while camera inside" % [name])
	var new_process_mode := Node.PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
	if Engine.is_in_physics_frame():
		set_process_mode.call_deferred(new_process_mode)
	else:
		process_mode = new_process_mode

func is_inside(pos: Vector2) -> bool:
	var dist := (pos - center_2d).abs()
	return dist[dist.max_axis_index()] < 0.5001

func fov(origin: Vector2) -> Vector2:
	# origin must be outside
	var to_center := center_2d - origin
	var corner_angles: Array[float] = [
		to_center.angle_to(to_center + Vector2(.5, -.5)),
		to_center.angle_to(to_center + Vector2(.5, .5)),
		to_center.angle_to(to_center + Vector2(-.5, .5)),
		to_center.angle_to(to_center + Vector2(-.5, -.5)),
	]
	var center_angle := to_center.angle()
	return Vector2(
		PanoramicOccluder2D.wrap_angle((corner_angles.min() as float) + center_angle),
		PanoramicOccluder2D.wrap_angle((corner_angles.max() as float) + center_angle),
	)

# fov of the side (reverse angle order, i.e. side fov as seen from outside)
func side_fov(origin: Vector2, from_direction: int) -> Vector2:
	var to_center := center_2d - origin
	var d1 := (from_direction + 1) & 3
	var d2 := from_direction
	var x := Vector2(.5 if d1 & 2 else -.5, -.5 if d1 % 3 else .5) + to_center
	var y := Vector2(.5 if d2 & 2 else -.5, -.5 if d2 % 3 else .5) + to_center
	return Vector2(x.angle(), y.angle())
