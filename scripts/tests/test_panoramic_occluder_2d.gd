@tool
extends EditorScript

func _run() -> void:
	var p : PanoramicOccluder2D
	
	p = PanoramicOccluder2D.new()
	assert(p._search_boundary(0.0) == 0)
	p._boundaries = [-PI, 0.0]
	p._boundary_is_begin = [true, false]
	assert(p._search_boundary(-PI+1e-4) == 0)
	assert(p._search_boundary(-PI-1e-4) == 0)
	assert(p._search_boundary(PI+1e-4) == 0)
	assert(p._search_boundary(PI-1e-4) == 0)
	p._boundaries = [0.0, PI]
	p._boundary_is_begin = [true, false]
	assert(p._search_boundary(-PI+1e-4) == 1)
	assert(p._search_boundary(-PI-1e-4) == 1)
	assert(p._search_boundary(PI+1e-4) == 1)
	assert(p._search_boundary(PI-1e-4) == 1)
	p._boundaries = [0.0, 1.0]
	p._boundary_is_begin = [true, false]
	assert(p._search_boundary(-PI) == 0)
	assert(p._search_boundary(-1.0) == 0)
	assert(p._search_boundary(0.0-1e-4) == 0)
	assert(p._search_boundary(0.0+1e-4) == 0)
	assert(p._search_boundary(0.5) == 1)
	assert(p._search_boundary(1.0-1e-4) == 1)
	assert(p._search_boundary(1.0+1e-4) == 1)
	assert(p._search_boundary(2.0) == 2)
	assert(p._search_boundary(PI) == 2)
	
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 1.0)
	assert(p._boundaries == [0.0, 1.0] and p._boundary_is_begin == [true, false] and not p._full_occluded)
	
	p = PanoramicOccluder2D.new()
	p.add_occluder(1.0, 0.0)
	assert(p._boundaries == [0.0, 1.0] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 0.0)
	assert(p._boundaries == [] and p._boundary_is_begin == [] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(-PI, PI)
	assert(p._boundaries == [] and p._boundary_is_begin == [] and not p._full_occluded)
	
	p = PanoramicOccluder2D.new()
	p.add_occluder(-PI, 0.0)
	assert(p._boundaries == [-PI, 0.0] and p._boundary_is_begin == [true, false] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, -PI)
	assert(p._boundaries == [-PI, 0.0] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(PI, 0.0)
	assert(p._boundaries == [0.0, PI] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, PI)
	assert(p._boundaries == [0.0, PI] and p._boundary_is_begin == [true, false] and not p._full_occluded)

	# parametrize
	# existing range [direct, back]
	# new range begin [0_begin, begin, begin_end, end, end_0, 0] / [begin, begin_0, 0, 0_end, end, end_begin]
	# new range end [0_begin, begin, begin_end, end, end_0, 0]+[new_begin_x, x_new_begin]

	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 2.0)
	p.add_occluder(0.0, 2.0)
	assert(p._boundaries == [0.0, 2.0] and p._boundary_is_begin == [true, false] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 2.0)
	p.add_occluder(0.0, 3.0)
	assert(p._boundaries == [0.0, 3.0] and p._boundary_is_begin == [true, false] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 2.0)
	p.add_occluder(0.0, 1.0)
	assert(p._boundaries == [0.0, 2.0] and p._boundary_is_begin == [true, false] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 2.0)
	p.add_occluder(0.0, -1.0)
	assert(p._boundaries == [-1.0, 0.0] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 2.0)
	p.add_occluder(1.0, 2.0)
	assert(p._boundaries == [0.0, 2.0] and p._boundary_is_begin == [true, false] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 2.0)
	p.add_occluder(1.0, 1.5)
	assert(p._boundaries == [0.0, 2.0] and p._boundary_is_begin == [true, false] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 2.0)
	p.add_occluder(1.0, 3.0)
	assert(p._boundaries == [0.0, 3.0] and p._boundary_is_begin == [true, false] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 2.0)
	p.add_occluder(1.0, -1.0)
	assert(p._boundaries == [-1.0, 0.0] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(0.0, 2.0)
	p.add_occluder(1.0, 0.5)
	assert(p._boundaries == [] and p._boundary_is_begin == [] and p._full_occluded == true)
	
	p = PanoramicOccluder2D.new()
	p.add_occluder(-1.0, 2.0)
	p.add_occluder(0.0, 1.0)
	assert(p._boundaries == [-1.0, 2.0] and p._boundary_is_begin == [true, false] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(-1.0, 2.0)
	p.add_occluder(2.5, 3.0)
	assert(p._boundaries == [-1.0, 2.0, 2.5, 3.0] and p._boundary_is_begin == [true, false, true, false] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(-1.0, 2.0)
	p.add_occluder(-3.0, -2.0)
	assert(p._boundaries == [-3.0, -2.0, -1.0, 2.0] and p._boundary_is_begin == [true, false, true, false] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(-1.0, 2.0)
	p.add_occluder(3.0, -3.0)
	assert(p._boundaries == [-3.0, -1.0, 2.0, 3.0] and p._boundary_is_begin == [false, true, false, true] and not p._full_occluded)
	
	p = PanoramicOccluder2D.new()
	p.add_occluder(2.0, -1.0)
	p.add_occluder(0.0, 1.0)
	assert(p._boundaries == [-1.0, 0.0, 1.0, 2.0] and p._boundary_is_begin == [false, true, false, true] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(2.0, -1.0)
	p.add_occluder(2.5, 3.0)
	assert(p._boundaries == [-1.0, 2.0] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(2.0, -1.0)
	p.add_occluder(-3.0, -2.0)
	assert(p._boundaries == [-1.0, 2.0] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(2.0, -1.0)
	p.add_occluder(3.0, -3.0)
	assert(p._boundaries == [-1.0, 2.0] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	
	p = PanoramicOccluder2D.new()
	p.add_occluder(-1.0, 2.0)
	p.add_occluder(1.0, 0.0)
	assert(p._boundaries == [] and p._boundary_is_begin == [] and p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(-1.0, 2.0)
	p.add_occluder(3.0, 2.5)
	assert(p._boundaries == [2.5, 3.0] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(-1.0, 2.0)
	p.add_occluder(-2.0, -3.0)
	assert(p._boundaries == [-3.0, -2.0] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(-1.0, 2.0)
	p.add_occluder(-3.0, 3.0)
	assert(p._boundaries == [-3.0, 3.0] and p._boundary_is_begin == [true, false] and not p._full_occluded)
	
	p = PanoramicOccluder2D.new()
	p.add_occluder(2.0, -1.0)
	p.add_occluder(1.0, 0.0)
	assert(p._boundaries == [0.0, 1.0] and p._boundary_is_begin == [false, true] and not p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(2.0, -1.0)
	p.add_occluder(3.0, 2.5)
	assert(p._boundaries == [] and p._boundary_is_begin == [] and p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(2.0, -1.0)
	p.add_occluder(-2.0, -3.0)
	assert(p._boundaries == [] and p._boundary_is_begin == [] and p._full_occluded)
	p = PanoramicOccluder2D.new()
	p.add_occluder(2.0, -1.0)
	p.add_occluder(-3.0, 3.0)
	assert(p._boundaries == [] and p._boundary_is_begin == [] and p._full_occluded)

	var N := 8
	var occluded: Array[bool] = []
	occluded.resize(N)
	var angles: Array[float] = [-PI, -PI*3/4, -PI/2, -PI/4, 0.0, PI/4, PI/2, PI*3/4, PI]
	for s in [Vector2i(2, 6), Vector2i(6, 2)] as Array[Vector2i]:
		for x in [0, 1, 2, 3, 4, 6, 7, 8] as Array[int]:
			for y in [0, 1, 2, 3, 4, 6, 7, 8] as Array[int]:
				if x % N == y % N: continue
				p = PanoramicOccluder2D.new()
				occluded.fill(false)
				var i := s.x%N
				while i != s.y%N:
					occluded[i] = true
					i = (i+1) % N
				p.add_occluder(angles[s.x], angles[s.y])
				i = x%N
				while i != y%N:
					occluded[i] = true
					i = (i+1) % N
				p.add_occluder(angles[x], angles[y])
				var actual_occluded: Array[bool] = []
				actual_occluded.resize(N)
				for j in range(N):
					actual_occluded[j] = p.is_fully_occluded(angles[j] + 0.1, angles[j+1] - 0.1)
				if actual_occluded != occluded:
					printerr(s, " ", x, " ", y)
					printerr(p._boundaries, p._boundary_is_begin)
					printerr(actual_occluded)
					printerr(occluded)
					assert(false)
	
	
	#var N: int
	#var occluded: Array[bool]
	#var angles: Array[float]
	#N = 10
	#occluded = []
	#occluded.resize(N)
	#angles = []
	#for i in range(N+1):
		#angles.append(PI * (i - N/2) / (N/2))
	#for a in range(N):
		#for b in range(N):
			#if a == b: continue
			#for c in range(N):
				#if a == c or b == c: continue
				#for d in range(N):
					#if a == d or b == d or c == d: continue
					#for x in range(N+1):
						#for y in range(N+1):
							#if x % N == y % N: continue
							#p = PanoramicOccluder2D.new()
							#occluded.fill(false)
							#var i := a%N
							#while i != b%N:
								#occluded[i] = true
								#i = (i+1) % N
							#p.add_occluder(angles[a], angles[b])
							#i = c%N
							#while i != d%N:
								#occluded[i] = true
								#i = (i+1) % N
							#p.add_occluder(angles[c], angles[d])
							#i = x%N
							#while i != y%N:
								#occluded[i] = true
								#i = (i+1) % N
							#p.add_occluder(angles[x], angles[y])
							#var actual_occluded: Array[bool] = []
							#actual_occluded.resize(N)
							#for j in range(N):
								#actual_occluded[j] = p.is_fully_occluded(angles[j] + 0.1, angles[j+1] - 0.1)
							#if actual_occluded != occluded:
								#printerr(a, " ", b, " ", c, " ", d, " ", x, " ", y)
								#printerr(p._boundaries, p._boundary_is_begin)
								#printerr(actual_occluded)
								#printerr(occluded)
								#assert(false)
