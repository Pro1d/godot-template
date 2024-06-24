class_name VisualRect
extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_rect(size: Vector2, center: Vector2, orientation: float) -> void:
	scale = Vector3(size.x / 2, 1.0, size.y / 2)
	rotation = Vector3(0, orientation, 0)
	position = Vector3(center.x, position.y, -center.y)
	
func set_rect2(corner1: Vector2, corner2: Vector2, size: Vector2) -> void:
	var center := (corner1 + corner2) * .5
	var orientation := size.angle_to(corner2 - corner1)
	size = size.normalized() * corner1.distance_to(corner2)
	set_rect(size, center, orientation)
