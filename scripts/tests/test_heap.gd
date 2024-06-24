@tool
extends EditorScript

static func lt(a: int, b: int) -> bool:
	return a < b

func _run() -> void:
	var h := Heap.new(lt)
	h.push(3)
	h.push(5)
	h.push(2)
	h.push(4)
	h.push(1)
	assert(h.pop() == 1)
	assert(h.pop() == 2)
	assert(h.pop() == 3)
	assert(h.pop() == 4)
	assert(h.pop() == 5)

	var t := Time.get_ticks_usec()
	var values: Array[int] = Array(range(1001), TYPE_INT, &"", null)
	var t2 := Time.get_ticks_usec()
	print(t2-t)
	t = t2
	h = Heap.new(lt)
	for i in values:
		h.push(i)
	for i in values.size():
		assert(h.pop() == i)
	t2 = Time.get_ticks_usec()
	print(t2-t)
	values.reverse()
	t = Time.get_ticks_usec()
	h = Heap.new(lt)
	for i in values:
		h.push(i)
	for i in values.size():
		assert(h.pop() == i)
	t2 = Time.get_ticks_usec()
	print(t2-t)
	values.shuffle()
	t = Time.get_ticks_usec()
	h = Heap.new(lt)
	for i in values:
		h.push(i)
	for i in values.size():
		assert(h.pop() == i)
	t2 = Time.get_ticks_usec()
	print(t2-t)
