class_name Heap

var _data := [null]
var _cmp : Callable

func _init(cmp: Callable) -> void:
	_cmp = cmp

func is_empty() -> bool:
	return _data.size() == 1

func push(value: Variant) -> void:
	_data.append(null)
	var i := _data.size() - 1
	while i > 1:
		var parent := i / 2
		if _cmp.call(value, _data[parent]):
			_data[i] = _data[parent]
		else:
			break
		i = parent
	_data[i] = value

func pop() -> Variant:
	@warning_ignore("untyped_declaration")
	var value = _data[1]
	@warning_ignore("untyped_declaration")
	var back = _data.pop_back()
	if _data.size() > 1:
		_data[1] = back
		_pop_heapify()
	return value

func _pop_heapify() -> void:
	var i := 1
	while true:
		var left := 2 * i
		var right := left + 1
		var top := i
		if left < _data.size() and _cmp.call(_data[left], _data[top]):
			top = left
		if right < _data.size() and _cmp.call(_data[right], _data[top]):
			top = right
		if top != i:
			@warning_ignore("untyped_declaration")
			var value = _data[i]
			_data[i] = _data[top]
			_data[top] = value
			i = top
		else:
			break
