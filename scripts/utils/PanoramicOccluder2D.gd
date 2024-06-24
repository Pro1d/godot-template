class_name PanoramicOccluder2D

const EPSILON := 1e-3 # ~= PI / 180 * 0.1

var _boundaries : Array[float] = []
var _boundary_is_begin : Array[bool] = []
var _full_occluded := false

func _add_boundary(i: int, angle: float, is_begin: bool) -> void:
	_boundaries.insert(i, angle)
	_boundary_is_begin.insert(i, is_begin)

func add_occluder(angle_begin: float, angle_end: float) -> void:
	if _full_occluded:
		return
	elif _is_angle_approx_equal(angle_begin, angle_end):
		return
	elif _boundaries.is_empty():
		if angle_begin < angle_end:
			_add_boundary(0, angle_begin, true)
			_add_boundary(1, angle_end, false)
		else:
			_add_boundary(0, angle_end, false)
			_add_boundary(1, angle_begin, true)
		return
	
	#print("occluder ", angle_begin, " ", angle_end)
	#print(_boundaries, _boundary_is_begin)
	
	var index_begin := _search_boundary(angle_begin)
	var match_begin := _is_angle_approx_equal(angle_begin, _boundaries[index_begin % _boundaries.size()])
	var remove_from := index_begin
	var remove_length := 0
	
	if match_begin:
		if _boundary_is_begin[index_begin % _boundaries.size()]: # input range begins at the beginning of an existing range -> keep existing
			remove_from += 1 #= (index_begin + 1) % _boundaries.size()
		else: # input range begins at the end of an existing range -> remove existing
			remove_length = 1
	else:
		if _boundary_is_begin[index_begin % _boundaries.size()]: # input range begins inside a non-occluded range -> insert new begin
			_add_boundary(index_begin, angle_begin, true)
			remove_from += 1 #= (index_begin + 1) % _boundaries.size()
		else: # input range begins inside an occluded range -> do nothing
			pass
	
	#print(index_begin, _boundaries)
	
	var occluder_length := _relative_angle(angle_begin, angle_end)
	while remove_length < _boundaries.size():
		var index := (remove_from + remove_length) % _boundaries.size()
		var position := _relative_angle(angle_begin, _boundaries[index])
		if position < EPSILON:position = 2 * PI
		if abs(position - occluder_length) < EPSILON: # matching existing boundary
			if _boundary_is_begin[index]:
				remove_length += 1
			break 
		elif position > occluder_length: # create new end boundary
			if _boundary_is_begin[index]:
				var insert_index := _boundaries.size() if index == 0 and angle_end > _boundaries[0] else index
				_add_boundary(insert_index, angle_end, false)
				if insert_index <= remove_from:
					remove_from = (remove_from + 1) % _boundaries.size()
			break
		else: # position < occluder_length
			remove_length += 1
			
	#print(_boundaries)
	#print(remove_from, " size:", remove_length)
	remove_from %= _boundaries.size()
	
	if remove_length == _boundaries.size():
		_boundaries.clear()
		_boundary_is_begin.clear()
		_full_occluded = true
	elif (remove_from + remove_length) <= _boundaries.size():
		var new_size := _boundaries.size() - remove_length
		for i in range(remove_from, new_size):
			_boundaries[i] = _boundaries[i + remove_length]
			_boundary_is_begin[i] = _boundary_is_begin[i + remove_length]
		_boundaries.resize(new_size)
		_boundary_is_begin.resize(new_size)
	else:
		_boundaries = _boundaries.slice(
			(remove_from + remove_length) % _boundaries.size(),
			remove_from
		)
		_boundary_is_begin = _boundary_is_begin.slice(
			(remove_from + remove_length) % _boundary_is_begin.size(),
			remove_from
		)

	assert(_boundaries.size() % 2 == 0)

static func wrap_angle(angle: float) -> float:
	return wrapf(angle, -PI, PI)

# Returns true if a < b or a ~= b, false if a > b
func _is_angle_less_or_equal(a: float, b: float) -> bool:
	var diff := angle_difference(b, a)
	return diff < EPSILON

func _relative_angle(from: float, to: float) -> float:
	return wrapf(to - from, 0, 2*PI)

func _is_angle_approx_equal(a: float, b: float) -> bool:
	return abs(angle_difference(b, a)) < EPSILON

func _search_boundary(angle: float) -> int:
	if _boundaries.is_empty():
		return 0
	else:
		var i := _boundaries.bsearch(angle)
		if i == _boundaries.size() and _is_angle_approx_equal(angle, _boundaries[0]):
			return 0
		elif _is_angle_approx_equal(angle, _boundaries[i - 1]):
			return (i - 1 + _boundaries.size()) % _boundaries.size()
		else:
			return i

func is_fully_occluded(angle_begin: float, angle_end: float) -> bool:
	if _boundaries.is_empty():
		return _full_occluded
	elif _is_angle_approx_equal(angle_begin, angle_end):
		return false
	
	var index_begin := _search_boundary(angle_begin) % _boundaries.size()
	if _is_angle_approx_equal(angle_begin, _boundaries[index_begin]):
		index_begin = (index_begin + 1) % _boundaries.size()
	var index_end := _search_boundary(angle_end) % _boundaries.size()
	
	return  (
		(index_begin == index_end)
		and not _boundary_is_begin[index_begin]
		and _relative_angle(angle_begin, _boundaries[index_begin]) - _relative_angle(angle_begin, angle_end) > -EPSILON
	)
