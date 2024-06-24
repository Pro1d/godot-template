@tool
class_name GraphMap
extends Node3D

var area_size := 1.0 :
	set(s):
		if area_size != s:
			area_size = s
			_update_size()
@export var entry_area: MapArea
@export var camera_node: Node3D
@export_category("Debug")
@export var _show_reachable_only := false
# a. hanging area : max 1
#  OR
# b. key areas (containing the player)

# reachable area (direct neighbors of player areas)
#   SUBSET OF
# active area (visible from player areas)

var _key_areas: Array[MapArea] = []
var _active_areas: Dictionary = {}
var _reachable_areas: Array[MapArea] = []
var player_desynchronized := false

func _walk_map_areas(root: Node3D, f_area: Callable, f_door: Callable, f_node: Callable) -> void:
	for child in root.get_children():
		if child is MapArea:
			f_area.call(child as MapArea)
		elif child is Door:
			f_door.call(child as Door)
		elif child is Node3D:
			f_node.call(child as Node3D)
			_walk_map_areas(child as Node3D, f_area, f_door, f_node)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_walk_map_areas(
		self,
		func(map_area: MapArea) -> void:
			map_area.set_state(false, false),
		func(_door: Door) -> void: return,
		func(node: Node3D) -> void:
			node.visible = true
	)
	if entry_area != null:
		_reachable_areas.append(entry_area)
		_key_areas.append(entry_area)
	if not Engine.is_editor_hint():
		area_size = 0.7
	_update_areas()

func _process(_delta: float) -> void:
	var t := Time.get_ticks_usec()
	_update_areas()
	t -= Time.get_ticks_usec()
	t *= -1
	if not Engine.is_editor_hint() and Time.get_ticks_msec() % 1000 < _delta * 1000:
		Config.console.print_line(str(t / 1000.0))

func _update_size() -> void:
	_walk_map_areas(
		self,
		func(map_area: MapArea) -> void: map_area.size = area_size,
		func(door: Door) -> void: door.size = area_size,
		func(_n: Node3D) -> void: return,
	)

func _update_areas() -> void:
	var new_key_areas: Array[MapArea] = []
	var camera_pos := to_local_2d(camera_node.global_position) if camera_node != null else Vector2.ZERO
	
	# Key areas
	for area in _reachable_areas:
		var inside := area.is_inside(camera_pos)
		area.camera_inside = inside
		if inside:
			new_key_areas.append(area)
	
	# Sync state and hanging area
	if new_key_areas.is_empty():
		_key_areas.resize(mini(1, _key_areas.size())) # only one hanging area (arbitrarily the 1st of the list)
		player_desynchronized = true
	else:
		_key_areas = new_key_areas
		player_desynchronized = false
	
	# Visible tiles
	var new_active_areas := {}
	if not player_desynchronized and not _show_reachable_only:
		var visible_areas := GraphMap._compute_area_visibility(
			_key_areas,
			camera_pos,
		)
		for area in visible_areas:
			new_active_areas[area] = false
	
	# Key tiles and direct neighbors are reachable
	for key_area in _key_areas:
		new_active_areas[key_area] = true
		if not player_desynchronized:
			for direction in 4:
				var neighbor := key_area.neighbors[direction]
				if new_active_areas.has(neighbor): # can it be false? yes, if _show_reachable_only.
					if key_area.is_neighbor_reachable(direction):
						new_active_areas[neighbor] = true
	
	# Apply tile state (active)
	_reachable_areas.clear()
	for active_area: MapArea in new_active_areas.keys():
		var reachable := new_active_areas.get(active_area) as bool
		active_area.set_state(true, reachable)
		if reachable:
			_reachable_areas.append(active_area)
	
	# Apply tile state (inactive)
	for prev_active_area: MapArea in _active_areas.keys():
		if not new_active_areas.has(prev_active_area):
			(prev_active_area as MapArea).set_state(false, false)
	
	# Save active tiles
	_active_areas = new_active_areas

class _Item:
	var area : MapArea
	var _dist_to_origin : float
	
	func _init(a: MapArea, origin: Vector2) -> void:
		area = a
		_dist_to_origin = origin.distance_squared_to(a.center_2d)
	
	static func lt(a: _Item, b: _Item) -> bool:
		return a._dist_to_origin < b._dist_to_origin

static func _compute_area_visibility(root_areas: Array[MapArea], origin: Vector2) -> Array[MapArea]:
	# Initialize Dikjstra
	var heap := Heap.new(_Item.lt)
	var visited := {}
	for ra  in root_areas:
		heap.push(_Item.new(ra, origin))
		visited[ra] = null
	
	var paranoramic_occluder := PanoramicOccluder2D.new()
	var visible_areas : Array[MapArea] = []
	
	while not heap.is_empty():
		var current_item := heap.pop() as _Item
		var current := current_item.area
		
		# Check visibility - TODO move to visit neighboring tiles?
		var fov := current.fov(origin)
		var is_inside := current.is_inside(origin) # don't check visility of tile if player is inside
		
		if is_inside or not paranoramic_occluder.is_fully_occluded(fov.x, fov.y):
			# tile is visible
			visible_areas.append(current)
			
			# Collect occluders
			var to_center := current.center_2d - origin
			for direction_index in 4:
				var direction := Geometry.to_direction_vector(direction_index)
				for occluder: SegmentShape2D in current.get_occluders(direction_index):
					if direction.dot(to_center + occluder.a) > 0:
						paranoramic_occluder.add_occluder(
							(to_center + occluder.a).angle(),
							(to_center + occluder.b).angle()
						)
			
			# Visit neighboring tiles
			for next in current.neighbors:
				if next != null and not visited.has(next):
					visited[next] = null
					var item := _Item.new(next, origin)
					if _Item.lt(current_item, item): # do not go back (heuristic to avoid overlapping tiles)
						heap.push(item)

	return visible_areas

func to_local_2d(global_pos: Vector3) -> Vector2:
	return Geometry.to_vector2(to_local(global_pos)) / area_size
