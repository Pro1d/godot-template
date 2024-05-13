class_name Geometry

enum DirectionIndex {
	X_PLUS=0,
	Y_PLUS=1,
	X_MINUS=2,
	Y_MINUS=3,
}
# Rotate clockwise: (i - 1) & 3
# Rotate counter-clockwise: (i + 1) & 3
# Opposite direction: i ^ 2

static func to_direction_vector(index : int) -> Vector2:
	return Vector2(~index & 1, index & 1) * (1 - (index & 2))

static func to_direction_index(from: Vector2, to: Vector2) ->  int:
	var delta := to - from
	var axis := delta.abs().max_axis_index()
	return axis if delta[axis] > 0 else axis + 2

static func to_direction_index3(from: Vector3, to: Vector3) ->  int:
	var delta := Geometry.to_vector2(to - from)
	var axis := delta.abs().max_axis_index()
	return axis if delta[axis] > 0 else axis + 2

static func to_vector2(v: Vector3) -> Vector2:
	return Vector2(v.x, -v.z)

static func to_vector3(v: Vector2) -> Vector3:
	return Vector3(v.x, 0.0, -v.y)

static func to_transform_2d(t3: Transform3D) -> Transform2D:
	return Transform2D(t3.basis.get_euler().y, to_vector2(t3.origin))

static func to_transform_3d(t2: Transform2D) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, t2.get_rotation()), to_vector3(t2.origin))
