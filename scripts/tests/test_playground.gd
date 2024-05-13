@tool
extends EditorScript

func _run() -> void:
	print("first_X_last".match("first_?_?*"))
	print([1, "hello"].find(StringName("hello")))
	
	if false:
		var a : Array = [SegmentShape2D.new()]
		var b : Array[SegmentShape2D] = []
		b.assign(a)
		print(a, b)
		a.append(SegmentShape2D.new())
		print(a,b)
	
	if false:
		print(31 & 1)
		print(~1)
		print(~31 & 1)
	
	if false:
		var t := Time.get_ticks_usec()
		var j := 0
		var arr:= PackedInt32Array()
		arr.resize(1000000)
		for i in arr:
			j += 1
		print(Time.get_ticks_usec() - t, " ", j)

	if false:
		var t := Time.get_ticks_usec()
		var j := 0
		for i in range(1000000):
			j += 1
		print(Time.get_ticks_usec() - t, " ", j)

	if false:
		var t := Time.get_ticks_usec()
		var d := {"a":1}
		var j := 0
		for i in range(100000):
			j += d["a"]
		print(Time.get_ticks_usec() - t, " ", j)
		t = Time.get_ticks_usec()
		for i in range(100000):
			d[i] = 1
		print(Time.get_ticks_usec() - t, " ", j)
		t = Time.get_ticks_usec()
		j = 0
		for i in range(100000):
			j += d["a"]
		print(Time.get_ticks_usec() - t, " ", j)
	
