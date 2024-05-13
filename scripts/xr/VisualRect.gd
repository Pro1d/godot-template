class_name VisualRect
extends MeshInstance3D


var _orientation := 0.0
var _size := Vector2.ONE

func set_rect(size: Vector2, center: Vector2, orientation: float) -> void:
	_size = size
	scale = Vector3(size.x / 2, 1.0, size.y / 2)
	_orientation = orientation
	rotation = Vector3(0, orientation, 0)
	position = Geometry.to_vector3(center) + Vector3.UP * position.y
	
func set_rect2(corner1: Vector2, corner2: Vector2, size: Vector2) -> void:
	var center := (corner1 + corner2) * .5
	var orientation := size.angle_to(corner2 - corner1)
	size = size.normalized() * corner1.distance_to(corner2)
	set_rect(size, center, orientation)

func clear_rotation_and_position() -> void:
	rotation = Vector3.ZERO
	position = Vector3(0, position.y, 0)

func get_transform2() ->  Transform2D:
	return Transform2D(get_orientation(), get_origin())

func get_origin() -> Vector2:
	return Geometry.to_vector2(position)
	
func get_orientation() -> float:
	return _orientation

func get_size() -> Vector2:
	return _size
