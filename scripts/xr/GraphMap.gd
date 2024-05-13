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
	if Engine.is_editor_hint():
		child_entered_tree.connect(
			func(n: MapArea) -> void:
				if n != null:
					n.hide()
		)

func _process(_delta: float) -> void:
	var t := Time.get_ticks_usec()
	if not Engine.is_editor_hint() or Time.get_ticks_msec() % 200 < _delta * 1000:
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
	var new_key_areas: Array[MapArea]
	var camera_pos := to_local_2d(camera_node.global_position) if camera_node != null else Vector2.ZERO
	
	# Key areas
	var inside: Array[MapArea] = []
	var outside: Array[MapArea] = []
	for area in _reachable_areas:
		if area.is_inside(camera_pos):
			inside.append(area)
		else:
			outside.append(area)
	# first, notify entering ; then, notify leaving (thus, doors stay open)
	for area in inside:
		area.camera_inside = true
	for area in outside:
		area.camera_inside = false
	new_key_areas = inside
	
	# Sync state and hanging area
	if new_key_areas.is_empty():
		_key_areas.resize(mini(1, _key_areas.size())) # only one hanging area (arbitrarily the 1st of the list)
		player_desynchronized = true
	else:
		_key_areas = new_key_areas
		player_desynchronized = false
	
	# Visible tiles
	var new_active_areas := {} # true: reachable, false: not reachable, missing: not active
	if not player_desynchronized:
		var visible_areas := GraphMap._compute_area_visibility(
			_key_areas,
			camera_pos,
		)
		for area in visible_areas:
			new_active_areas[area] = false
	
	# Key tiles and direct neighbors are reachable
	var diagonal_areas := {}
	for key_area in _key_areas:
		new_active_areas[key_area] = true
		if not player_desynchronized:
			for direction in 4:
				var neighbor := key_area.neighbors[direction]
				if new_active_areas.has(neighbor) and key_area.is_neighbor_reachable(direction):
					new_active_areas[neighbor] = true
					# register diagonal neighbor
					for orthogonal_direction: int in [(direction + 1) & 3, (direction - 1) & 3]:
						var diag_neighbor := neighbor.neighbors[orthogonal_direction]
						if new_active_areas.has(diag_neighbor) and neighbor.is_neighbor_reachable(orthogonal_direction):
							var d := diagonal_areas.get(diag_neighbor, {}) as Dictionary
							d[orthogonal_direction] = null
							diagonal_areas[diag_neighbor] = d
	
	# Make diagonal tile be reachable (if reachable from two sides)
	for diag_area: MapArea in diagonal_areas:
		if (diagonal_areas.get(diag_area) as Dictionary).size() >= 2:
			new_active_areas[diag_area] = true
	
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
	#print("--------")
	# Initialize Dikjstra
	var heap := Heap.new(_Item.lt)
	var visited := {}
	var occupied_pos := {}
	for ra  in root_areas:
		heap.push(_Item.new(ra, origin))
		visited[ra] = null
	
	var paranoramic_occluder := PanoramicOccluder2D.new()
	var visible_areas : Array[MapArea] = []
	
	while not heap.is_empty():
		var current_item := heap.pop() as _Item
		var current := current_item.area
		
		#print(current)
		
		# tile is visible
		visible_areas.append(current)
		
		# Collect occluders
		var to_center := current.center_2d - origin
		for direction_index in 4:
			var direction := Geometry.to_direction_vector(direction_index)
			for occluder: SegmentShape2D in current.get_occluders(direction_index):
				if direction.dot(to_center + occluder.a) > 0:
					#print("add occluder ",  
						#(to_center + occluder.a).angle(), " ",
						#(to_center + occluder.b).angle())
					paranoramic_occluder.add_occluder(
						(to_center + occluder.a).angle(),
						(to_center + occluder.b).angle()
					)
		
		# Visit neighboring tiles
		for direction_index in 4:
			if current.is_neighbor_visible(direction_index):
				var next := current.neighbors[direction_index]
				var fov := next.side_fov(origin, direction_index)
				#print("neighbor ", next.name, " ", fov, " ", paranoramic_occluder.is_fully_occluded(fov.x, fov.y))
				#print("with ", paranoramic_occluder._boundaries, paranoramic_occluder._boundary_is_begin)
				if (
					not visited.has(next)
					and angle_difference(fov.x, fov.y) > 0
					and not paranoramic_occluder.is_fully_occluded(fov.x, fov.y)
				):
					visited[next] = null
					var item := _Item.new(next, origin)
					if _Item.lt(current_item, item): # do not go back (heuristic to avoid overlapping tiles)
						heap.push(item)
						var ipos := roundi((next.center_2d + Vector2.ONE).dot(Vector2(1,3)))
						if occupied_pos.has(ipos):
							print("Overlapping ", occupied_pos[ipos], " ", next)
							pass
						else:
							occupied_pos[ipos] = next

	return visible_areas

func to_local_2d(global_pos: Vector3) -> Vector2:
	return Geometry.to_vector2(to_local(global_pos)) / area_size
