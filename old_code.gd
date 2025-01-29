extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var v = Vector2(-20, -20)
var pos = Vector2(200, 300)

#var c1_ = Vector2(250, 200)
var c1_ = Vector2(768.4091, 379.506)
var opt_v = Vector2(80,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	"""
	var p32 = sqrt(128)
	
	var pos_1 = Vector2(500, 500)
	var pos_2 = Vector2(500 + p32, 500 + p32)
	
	var o_v = Vector2(50, 50)
	
	draw_circle(pos_1, 8, Color.WHITE)
	draw_circle(pos_2, 8, Color.WHITE)
	
	var vs = OrcaUtils.closest_point_on_vo_boundary_2(
		pos_1,
		pos_2,
		8,
		8,
		1,
		o_v
	)
	
	var vel = vs[2] + o_v
	var the_n = vs[3]
	
	draw_line(pos_1, pos_1 + vel, Color.BLACK, 3)
	draw_line(pos_1 + vel, pos_1 + vel + the_n * 10, Color.BLACK, 3)
	draw_line(pos_1, pos_1 + o_v, Color.RED, 3)
	
	var out = Vector2(293.8073, 471.2429)
	var velo = Vector2(34.87661, -35.82767)
	
	draw_circle(out, 4, Color.RED)
	draw_line(out, out + velo, Color.GREEN, 3)
	
	"""
	
	"""
	
	var rect = $Poly.get_viewport().get_visible_rect().size
	
	print(rect)
	
	print("large polygons")
	print(large_polygons)
	
	for polygon in large_polygons:
		for i in range( polygon.size()):
			var next_i = (i+1) % polygon.size()
			draw_line(polygon[i], polygon[next_i], Color.DARK_GREEN, 3)
	
	for convex_p in convex_polygons:
		if not convex_p:
			continue
		for i in range( convex_p.size()):
			var next_i = (i+1) % convex_p.size()
			draw_line(convex_p[i], convex_p[next_i], Color.BLACK, 10)
	
	
	var area = [
		100*Vector2(0,0),
		100*Vector2(0,1),
		100*Vector2(1,1),
		100*Vector2(1,0)
	]
	
	var polys = [
		100*Vector2(0.5, 0.0),
		100*Vector2(0.5, 0.75),
		100*Vector2(1.2, 0.75),
		100*Vector2(1.2, 0.0)
	]
	
	var polys_1 = [
		100*Vector2(0.5, -0.5),
		100*Vector2(0.5, 0.75),
		100*Vector2(1.5, 0.75),
		100*Vector2(1.5, -0.5)
	]
	
	
	# Not working right now
	var polys_2 = [
		100*Vector2(0.5, -0.5),
		100*Vector2(0.5, 0.75),
		100*Vector2(0.75, 0.75),
		100*Vector2(0.75, -0.5)
	] 
	
	var polys_3 = [
		100*Vector2(-0.5, -0.5),
		100*Vector2(-0.5, 0.75),
		100*Vector2(0.75, 0.75),
		100*Vector2(0.75, -0.5)
	]
	
	var polys_4 = [
		100*Vector2(-0.5, 0.5),
		100*Vector2(-0.5, 0.75),
		100*Vector2(0.75, 0.75),
		100*Vector2(0.75, 0.5)
	]
	
	var polys_5 = [
		100*Vector2(-0.5, 0.5),
		100*Vector2(-0.5, 1.75),
		100*Vector2(0.75, 1.75),
		100*Vector2(0.75, 0.5)
	]
	
	var polys_6 = [
		100*Vector2(0.5, 0.5),
		100*Vector2(0.5, 1.75),
		100*Vector2(0.75, 1.75),
		100*Vector2(0.75, 0.5)
	]
	
	var polys_7 = [
		100*Vector2(0.5, 0.5),
		100*Vector2(0.5, 1.75),
		100*Vector2(1.75, 1.75),
		100*Vector2(1.75, 0.5)
	]
	
	var polys_8 = [
		100*Vector2(0.5, 0.25),
		100*Vector2(0.5, 0.75),
		100*Vector2(1.75, 0.75),
		100*Vector2(1.75, 0.25)
	]
	
	var polys_9 = [
		100*Vector2(-0.25, 0.50),
		100*Vector2(-0.25, 1.25),
		100*Vector2(1.25, 1.25),
		100*Vector2(1.25, -0.25),
		100*Vector2(0.75, 0.25),
		100*Vector2(0.8, 0.7),
		100*Vector2(0.6, 0.85),
		100*Vector2(0.25, 0.25)
	]
	
	var inner_polygon = [
		100*Vector2(0.25, 0.25),
		100*Vector2(0.25, 0.75),
		100*Vector2(0.75, 0.75),
		100*Vector2(0.75, 0.25)
	]
	
	var inner_polygon_2 = [
		100*Vector2(0.1, 0.1),
		100*Vector2(0.1, 0.2),
		100*Vector2(0.2, 0.2),
		100*Vector2(0.2, 0.1)
	]
	
	var inner_polygon_3 = [
		100*Vector2(0.3, 0.1),
		100*Vector2(0.3, 0.2),
		100*Vector2(0.95, 0.2),
		100*Vector2(0.95, 0.1)
	]
	
	var polygon_test = [
		100 * Vector2(0.8, 0.8),
		100 * Vector2(0.8, 1.8),
		100 * Vector2(1.8, 1.8),
		100 * Vector2(1.8, 0.8)
	]
	
	var used_polygon = polys_6 #inner_polygon
	
	#var new_area = PolygonUtils.reshape_area(area, used_polygon, 100 , 100)
	
	for i in range( area.size()):
		var next_i = (i+1) % area.size()
		draw_line(area[i] + Vector2(50,50), area[next_i] + Vector2(50,50), Color.RED, 3)
		
	for i in range( used_polygon.size()):
		var next_i = (i+1) % used_polygon.size()
		draw_line(used_polygon[i] + Vector2(50,50), used_polygon[next_i] + Vector2(50,50), Color.DARK_GREEN, 3)
	
	#var new_area = PolygonUtils.add_poylgon_inside_area(area, used_polygon)
	
	#var new_area = PolygonUtils.extract_allowed_area([inner_polygon, inner_polygon_2, inner_polygon_3], 100, 100)
	#var new_area = PolygonUtils.extract_allowed_area([inner_polygon, inner_polygon_2, inner_polygon_3, polygon_test], 100, 100)
	var new_area = PolygonUtils.extract_allowed_area([inner_polygon], 100, 100)
	
	#new_area = area
	
	#var triangles = PolygonUtils.triangulate_polygon(new_area)
	
	#var convex_polygons = PolygonUtils.allowed_area_splitted_convex(
	#	[inner_polygon, inner_polygon_2, inner_polygon_3, polygon_test],
	#	100,
	#	100
	#)
	
	var convex_polygons = PolygonUtils.allowed_area_splitted_convex(
		[inner_polygon],
		100,
		100
	)

	#print("triangles")
	#print(triangles)
	#for i in range( new_area.size()):
	#	var next_i = (i+1) % new_area.size()
	#	draw_line(new_area[i] + Vector2(50,50), new_area[next_i] + Vector2(50,50), Color.BLUE, 3)
		
	#for triangle in triangles:
	#	for i in range( triangle.size()):
	#		var next_i = (i+1) % triangle.size()
	#		draw_line(triangle[i] + Vector2(50,50), triangle[next_i] + Vector2(50,50), Color.GREEN, 3)
	
	for triangle in convex_polygons:
		for i in range( triangle.size()):
			var next_i = (i+1) % triangle.size()
			draw_line(triangle[i] + Vector2(50,50), triangle[next_i] + Vector2(50,50), Color.BLACK, 3)
	
	#var new = PolygonUtils.extract_allowed_area([polys], 100, 100)
	
	#print("Area")
	#print(PolygonUtils.is_convex_polygon(new))
	
	var triangle = [Vector2(100,100), Vector2(100,0), Vector2(150,0)]
	var po = PolygonUtils.add_triangle_to_poylgon(area, triangle)
	#for i in range( po.size()):
	#		var next_i = (i+1) % po.size()
	#		draw_line(po[i] + Vector2(50,50), po[next_i] + Vector2(50,50), Color.BLACK, 3)
	return
	
	var triangle_clockwise = [Vector2(0,0), Vector2(50,50), Vector2(100,0)]
	var triangle_counter_clockwise = [Vector2(0,0), Vector2(100,0), Vector2(50,50)]

	
	var lines = PolygonUtils.split_line_on_height([Vector2(5,5), Vector2(10,10), Vector2(15, 29)], 19.5, true)
	
	print(lines)
	
	var polygons = [] 
	
	for poly in $Poly.get_children():
		polygons.append(poly.polygon)
		
	PolygonUtils.order_clockwise(polygons)
	
	for poly in polygons:
		print(poly)
		print(PolygonUtils.clockwise_rotation(poly))
		draw_circle(poly[0], 5, Color.BLUE)
		draw_circle(poly[1], 5, Color.GREEN)
	
	
	
	
	return
	

	
	#var radius = 8
	#var p1 = Vector2(500, 500)
	#var v1 = Vector2(1,0).normalized() * 100
	#var p2 = Vector2(550, 400)
	#var v2 = Vector2(0.8,1) * 100
	#var overlap = GeometryUtils.get_time_overlaps(p1, v1, p2, v2, 8)
	

	
	#draw_circle(p1, radius, Color.VIOLET)
	#draw_line(p1, p1 + v1, Color.BLUE, 3)
	
	#draw_circle(p2, radius, Color.VIOLET)
	#draw_line(p2, p2 + v2, Color.BLUE, 3)
	
	var l1 = Vector2(500,500)
	var l2 = Vector2(550,700)
	var p = Vector2(400, 600)
	var online = GeometryUtils.get_closest_point_on_line(l1, l2, p)
	
	draw_line(l1, l2, Color.BLUE)
	draw_circle(p, 5, Color.RED)
	draw_circle(online, 5, Color.RED)
	
	var p1 = Vector2(0, 0)
	var p2 = Vector2(-50, -50)
	
	var v_opt = Vector2(-50,100)
	
	var xs = OrcaUtils.closest_point_on_vo_boundary(
		p1,
		p2,
		8,
		8,
		10,
		v_opt
	)
	var shift = Vector2(250, 250)
	
	v_opt += shift
	
	var m1 = xs[0] + shift
	var m2 = xs[1] + shift
	var r1 = xs[2] 
	var r2 = xs[3] 
	var s1_up = xs[4] + shift
	var s2_up = xs[5] + shift
	var s1_down = xs[6] + shift
	var s2_down = xs[7] + shift
	var closest_point = xs[8] + shift
	var u = xs[9] + shift
	var n = xs[10] 

	
	#draw_circle(m1, r1, Color.DARK_GREEN)
	#draw_circle(m2, r2, Color.DARK_BLUE)
	#draw_circle(v_opt, 8, Color.DARK_VIOLET)
	#draw_circle(closest_point, 8, Color.DARK_RED)
	
	#draw_line(s1_up, s2_up, Color.VIOLET, 3)
	#draw_line(s1_down, s2_down, Color.VIOLET, 3)
	#draw_line(s1_down, s1_up, Color.VIOLET, 3)#
	#draw_circle(s2_up, 3, Color.GREEN)
	#draw_circle(s2_down, 3, Color.GREEN)
	
	#draw_line(s2_up, s2_down, Color.DARK_BLUE, 3)
	
	#var c_p = GeometryUtils.get_closest_point_on_line(s2_up, s2_down, m1)
	#draw_circle(c_p, 3, Color.RED)
	#draw_circle(m1, 3, Color.RED)
	#draw_line(closest_point, (closest_point + 20*n), Color.GHOST_WHITE, 3)
	
	#[m1, m2, r1, r2, s1_up, s2_up, s1_down, s2_down]
	#[m1, m2, r1, r2, s1_up, s2_up, s1_down, s2_down]
	
	#draw_circle(overlap, radius, Color.RED)
	
	for edge in edges:
		draw_circle(edge, 4, Color.BLUE)
		
	#if shortest_path:
		#draw_line(fake_character["position"], shortest_path[0], Color.RED)
		#for i in range(len(shortest_path) - 1):
		#	var start = shortest_path[i]
		#	var end = shortest_path[i+1]
		#	draw_line(start, end, Color.RED)
	
	
	for path in shortest_paths:
		if not path:
			continue 
		for i in range(len(path) - 1):
			var start = path[i]
			var end = path[i+1]
			draw_line(start, end, Color.RED)
	
	#var v_e_1 = position_to_visible_edges[Vector2(64, 64)]
	#var v_e_2 = position_to_visible_edges[Vector2(800, 400)]
	
	#for e in v_e_1:
	#	draw_circle(edges[e], 4, Color.WHITE)
		
	#for e in v_e_2:
	#	draw_circle(edges[e], 4, Color.RED)
	var color = Color.NAVY_BLUE
	
	if GeometryUtils.in_polygons_range(
		$Poly,
		8,
		fake_character["position"]
	):
		color = Color.RED
		
	#draw_circle(fake_character["position"], 8, color)
	
	"""
	
	
	"""
	for polygon in occupied_polygons:
		for point in polygon:
			draw_circle(point, 2, Color.NAVY_BLUE)
	

	var obs_ps = [
		#Vector2(50, 50),
		#Vector2(75, 75),
		#Vector2(125, 75),
		Vector2(104, 104)
	]
	
	for p in obs_ps:
		draw_circle(p, 24, Color.NAVY_BLUE)
		
	draw_circle(Vector2(256, 256,), 8, Color.RED)
		
	for i in range(200):
		for j in range(200):
			var x = i * 16
			var y = j * 16
			var dir = VFUtils.get_dir(
				Vector2(x,y),
				obs_ps,
				Vector2(256,256),
				24
			)
			draw_line(Vector2(x,y), Vector2(x,y) + 8 * dir, Color.WHITE, 3)
			draw_circle(Vector2(x,y) + 8 * dir, 2, Color.RED)
	
	"""
	
	
	#var xss = OrcaUtils.test_intersection_with_circle()
	#var inter = xss[0]
	#var m = xss[1]
	#var r = xss[2]
	#var hp = xss[3]
	
	
	#draw_circle(m,r, Color.VIOLET)
	#draw_circle(inter["left"], 8, Color.GREEN)
	#draw_circle(inter["right"], 8, Color.RED)
	#draw_circle(m + r* hp.l_dir, 8, Color.GREEN)
	#draw_circle(m - r * hp.l_dir, 8, Color.RED)
	#draw_circle(inter["right"], 8, Color.RED)
	#draw_line(hp.p + 1000 * hp.l_dir, hp.p - 1000 * hp.l_dir, Color.CADET_BLUE, 3)
		
	#for pos in pos_to_walls:
	#	if pos_to_walls[pos]:
	#		draw_circle(pos, 2, Color.WHITE)
	#	for wall in pos_to_walls[pos]:
	#		draw_line(wall[0], wall[1], Color.GREEN, 3)
	
	#var pos_m = GeometryUtils.get_closest_mesh_position(fake_character["position"])
	#var actor_positions = []
	#for i in range(9):
	#	for j in range(9):
	#		var delta_pos = Vector2((i-4)*8, (j-4)*8) + pos_m
	#		if not delta_pos in actor_position_mesh:
	#			continue
	#		var actors = actor_position_mesh[delta_pos]
	#		actor_positions.append_array(actors)

	
	for f_c in fake_characters:
		draw_circle(f_c, 8, Color.DARK_VIOLET)
		#var square = generate_sourounding_square(f_c, 16, Vector2(1,0))
		#draw_polyline(square, Color.RED, 1)
		#draw_line(square[0], square[3], Color.RED, 1)
		#var square2 = generate_sourounding_square(f_c, 24, Vector2(1,0))
		#draw_polyline(square2, Color.BLUE, 1)
		#draw_line(square2[0], square2[3], Color.BLUE, 1)
	
	"""
	var pos = fake_character["position"]
	var f_c_pos = GeometryUtils.get_closest_mesh_position(pos)
	if f_c_pos in pos_to_walls:
		for wall in pos_to_walls[f_c_pos]:
			var dir = generate_wall_velocity(pos, wall, 15)
			draw_line(pos, pos + 30 * dir, Color.RED, 3)
	"""
	
	"""
	for p_c in actor_positions:
		draw_circle(p_c, 8, Color.RED)
		var dir = fake_character["dir"]
		var square2 = generate_sourounding_square(p_c, 24, dir)
		draw_polyline(square2, Color.BLUE, 1)
		draw_line(square2[0], square2[3], Color.BLUE, 1)
	
	for i in range(dim_x):
		for j in range(dim_y):
			draw_circle(Vector2(i*8, j*8), 1, Color.BLACK)
	"""
	
	"""
	
	var c1 = Vector2(500, 500)
	var c2 = Vector2(550, 600)
	var radius = 25
	
	#draw_circle(c1/2, radius/2, Color.WHITE)
	#draw_circle(c2/2, radius/2, Color.WHITE)
	
	#var qs = OrcaUtils.determine_closest_point_on_wall_v_object(Vector2(0,0), c1, c2, radius, v, 2)
	#draw_line(qs[0], 2 * qs[0]  , Color.WHITE, 3)
	#draw_line(qs[1], 2 * qs[1], Color.WHITE, 3)
	#draw_line(qs[0], qs[1], Color.WHITE, 3)
	#draw_line(qs[4], qs[5], Color.WHITE, 3)
	
	#draw_circle(v, 5, Color.INDIGO)
	#draw_circle(qs[2], 5, Color.RED)
	#draw_line(qs[2], qs[2] + qs[3]*16, Color.OLIVE, 3)
	
	var w1 = Vector2(200, 200)
	var w2 = Vector2(500, 210)
	var w3 = Vector2(450, 600)
	
	
	var qq = OrcaUtils.determine_closest_point_on_wall_segment(
		pos,
		w1,
		w2,
		8,
		v,
		1
	)
	
	draw_line(
		w1,
		w2,
		Color.BLACK,
		3
	)
	

	
	var qq2 = OrcaUtils.determine_closest_point_on_wall_segment(
		pos,
		w2,
		w3,
		8,
		v,
		1
	)
	
	draw_line(
		w2,
		w3,
		Color.BLACK,
		3
	)
	

	
	draw_circle(
		pos,
		8,
		Color.DARK_MAGENTA
	)
	
	draw_line(
		pos,
		pos + v,
		Color.DARK_RED,
		3
	)
	
	var hps : Array[OrcaUtils.HalfPlane] = []
	
	if qq:
		var u_n = qq[0]
		var n_n = qq[1]
		
		draw_circle(pos + u_n + v, 8, Color.YELLOW_GREEN)
		var half_plane = OrcaUtils.HalfPlane.new(
			v +  u_n,
			n_n.rotated(-PI/2),
			n_n,
			-1
		)
		draw_line(pos + u_n + v, pos + u_n + v + 16 * n_n, Color.WHITE, 3)
		draw_line(pos + qq[2], pos + qq[3], Color.WHITE, 3)
		
		hps.append(half_plane)
	
	if qq2:
		var u_n = qq2[0]
		var n_n = qq2[1]
		
		draw_circle(pos + u_n + v, 8, Color.YELLOW_GREEN)
		var half_plane = OrcaUtils.HalfPlane.new(
			v +  u_n,
			n_n.rotated(-PI/2),
			n_n,
			-1
		)
		draw_line(pos + u_n + v, pos + u_n + v + 16 * n_n, Color.WHITE, 3)
		draw_line(pos + qq2[2], pos + qq2[3], Color.WHITE, 3)
		
		hps.append(half_plane)
	
	if not qq and not qq2:
		var vs = OrcaUtils.determine_closest_edge_point(pos, w2, 8, v, 1, [w1 - pos, w3 - pos])
		var u_n = vs[0]
		var n_n = vs[1]
		
		var half_plane = OrcaUtils.HalfPlane.new(
			v +  u_n,
			n_n.rotated(-PI/2),
			n_n,
			-1
		)
		draw_line(pos + u_n + v, pos + u_n + v + 16 * n_n, Color.WHITE, 3)
		#draw_line(pos + qq2[2], pos + qq2[3], Color.WHITE, 3)
		
		hps.append(half_plane)
		
		if len(vs) == 4:
			var half_plane2 = OrcaUtils.HalfPlane.new(
				v +  vs[2],
				vs[3].rotated(-PI/2),
				vs[3],
				-1
			)
			hps.append(half_plane2)
			
			draw_line(pos + vs[2] + v, pos + vs[2] + v + 16 * vs[3], Color.WHITE, 3)
		
				
	var velocity = OrcaUtils.randomized_bounded_lp(hps,  v, v, 50)
	
	if not velocity:
		velocity = Vector2(0,0)
	
	draw_line(pos, pos + velocity, Color.BLUE, 3)
	
	draw_circle(w3, 8, Color.FIREBRICK)
	#var vs = OrcaUtils.determine_closest_edge_point(pos, w2, 8, v, 1, [w1 - pos, w3 - pos])
	
	#draw_circle(pos + vs[0] + v, 8, Color.YELLOW)
	
	
	return
	
	
	var qs = OrcaUtils.determine_closest_point_on_wall_v_object(
		pos,
		w1,
		w2,
		8,
		v,
		1
	)
	
	var qs_2 = OrcaUtils.determine_closest_point_on_wall_v_object(
		pos,
		w2,
		w3,
		8,
		v,
		1
	)
	
	
	#draw_circle(pos, 8, Color.WHITE)
	
	draw_line(
		w1,
		w2,
		Color.BLUE,
		3
	)
	
	draw_line(
		w2,
		w3,
		Color.BLUE,
		3
	)
	
	
	
	return
	
	
	var u2 = qs[2]
	var n2 = qs[3]
	
	
	draw_line(pos , pos + v, Color.AQUA)
	draw_line(pos + v, pos + v + u2, Color.RED)
	draw_line(pos + qs[4], pos + qs[5], Color.WHITE, 3)
	
	draw_circle(w1, 8,  Color.NAVY_BLUE)
	draw_circle(w2, 8,  Color.NAVY_BLUE)
	
	draw_line(pos + v + u2, pos + v + u2 + n2*20, Color.WHITE)
	draw_circle(pos + qs[1], 5, Color.RED)
	draw_circle(pos + qs[0], 5, Color.RED)
	draw_line(pos + qs[0], pos + 100 * qs[0], Color.WHITE, 3)
	draw_line(pos + qs[1], pos + 100 * qs[1], Color.WHITE, 3)
	draw_circle(pos + v + u2 + n2*20, 4,  Color.NAVY_BLUE)
	
	var half_plane = OrcaUtils.HalfPlane.new(
		v +  u2,
		n2.rotated(-PI/2),
		n2,
		-1
	)
	
	
	u2 = qs_2[2]
	n2 = qs_2[3]
	
	
	var half_plane_2 = OrcaUtils.HalfPlane.new(
		v +  u2,
		n2.rotated(-PI/2),
		n2,
		-1
	)
	
	draw_line(pos , pos + v, Color.AQUA)
	draw_line(pos + v, pos + v + u2, Color.RED)
	draw_line(pos + qs_2[4], pos + qs_2[5], Color.WHITE, 3)
	
	draw_circle(w2, 8,  Color.NAVY_BLUE)
	draw_circle(w3, 8,  Color.NAVY_BLUE)
	
	draw_line(pos + v + u2, pos + v + u2 + n2 * 20, Color.WHITE)
	draw_circle(pos + qs_2[1], 5, Color.RED)
	draw_circle(pos + qs_2[0], 5, Color.RED)
	draw_line(pos + qs_2[0], pos + 100 * qs_2[0], Color.WHITE, 3)
	draw_line(pos + qs_2[1], pos + 100 * qs_2[1], Color.WHITE, 3)
	draw_circle(pos + v + u2 + n2 * 20, 4,  Color.NAVY_BLUE)
	
	draw_circle(pos, 8, Color.RED)
	
	var new_velocity = OrcaUtils.randomized_bounded_lp(
		[half_plane, half_plane_2],
		v,
		v,
		50
	)
	
	
	if not new_velocity:
		new_velocity = Vector2(0,0)
		
	draw_line(pos, pos + new_velocity, Color.VIOLET, 3)
	
	#OrcaUtils.test_find_opt_v()
	
	
	var o_dir = Vector2(1, 1)
	var p_dir = Vector2(0, -1).normalized()
	
	var orientation = o_dir.x
	
	
	#var a = Vector2(0,1)
	#var b = Vector2(1,0)
	#var c = Vector2(-1,0)
	#var alpha = a.angle_to(c)
	#var beta = b.angle_to(c)
	var dir = Vector2(2,-1)
		
	var hp = OrcaUtils.HalfPlane.new(
		Vector2(550, 240),
		dir.rotated(PI/2),
		dir,
		-1
	)
	

	#dir.y *= -1
	#var orient = dir.x
	
	var angle = GeometryUtils.polar_angle(dir)
	
	for i in range(361):
		var dir_2 = Vector2(cos(i), sin(i))
		
		var hp2 = OrcaUtils.HalfPlane.new(
			Vector2(550, 240),
			dir_2.rotated(PI/2),
			dir_2,
			-1	
		)
		
		#var o_2 = dir_2.x
		#if o_2 < 0:
		#	dir_2 = -dir_2
		
		#var ang2 = GeometryUtils.polar_angle(dir_2)
		
		var c = Color.GREEN
		
		
		if OrcaUtils.right_bounded(hp, hp2):
			c = Color.RED
		#if ang2 > angle  and dir.y < 0:
		#	c = Color.RED
		#if ang2 < angle  and dir.y > 0:
		#	c = Color.RED
		
		dir_2.y *= -1
		
		dir_2 = dir_2.rotated(PI/2)
			
		var pos_1 = Vector2(550, 240) - dir_2 * 100
		var pos_2 = Vector2(550, 240) + dir_2 * 100
		
		#draw_line(pos_1, pos_2, c, 1)
	
	#var pos_1 =  Vector2(550, 240) - dir * 100
	#var pos_2 =  Vector2(550, 240) + dir * 100
	#draw_line(pos_1, pos_2, Color.BLUE, 3)
		
		
	#var orientation_2 = half_plane.p_dir.x
	#var o_dir = org_plane.p_dir
	var switch = false
	if orientation < 0:
		p_dir = - p_dir
		switch = true
	#if orientation_2 < 0:
	
	var r1_ = 8
	var r2_ = 8
	var r3_ = 8
	
	var tau_ = 1.0
	
	
	#[m1, m2, r1, r2, s3_up, s2_up, s3_down, s2_down, closest_point, u, n]
	
	draw_circle(c1_, 8, Color.NAVY_BLUE)
	
	var c2_ = Vector2(300, 200)
	var c3_ = Vector2(320, 210)
	var c4_ = Vector2(340, 220)
	var c5_ = Vector2(380, 240)
	var c6_ = Vector2(752.8511, 383.3361)
	
	var cs_ = [c2_, c3_, c4_, c5_, c6_]
	
	var hps_ : Array[OrcaUtils.HalfPlane] = []
	
	for c in cs_:
	
		draw_circle(c, 16, Color.INDIGO)
	
		#var xxs = OrcaUtils.closest_point_on_vo_boundary(
		#	c1_,
		#	c,
		#	r1_,
		#	r2_,
		#	tau_,
		#	opt_v
		#)
	
		#[m1, m2, r1, r2, s3_up, s2_up, s3_down, s2_down, closest_point, u, n]
	
		#draw_circle(c +  xxs[8],4, Color.YELLOW )
	
		var ts = OrcaUtils.closest_point_on_vo_boundary_2(
			c1_,
			c,
			r1_,
			r2_,
			1,
			opt_v
		)
	
		draw_circle(c1_ + ts[0], 2, Color.YELLOW)
		draw_circle(c1_ + ts[1], 2, Color.YELLOW)
		draw_line(c1_ + ts[2] + opt_v, c1_ + opt_v + ts[2] + 20 * ts[3], Color.RED, 1)
		draw_circle(c1_ + opt_v + ts[2] + 20 * ts[3], 4, Color.BLUE)
		draw_line(c1_ + ts[0], c1_ + ts[0]*10000, Color.WHITE, 3)
		draw_line(c1_ + ts[1], c1_ + ts[1]*10000, Color.WHITE, 3)	
		draw_line(c1_, c1_ + opt_v, Color.VIOLET, 2)
	
		var hp_ = OrcaUtils.HalfPlane.new(
			opt_v + ts[2],
			ts[3].rotated(PI/2),
			ts[3],
			-1
		)
		
		hps_.append(hp_)
	
		draw_line(c1_ + ts[2] + opt_v, c1_ + ts[2] + opt_v + ts[3].rotated(PI/2) * 50, Color.RED, 3)
		draw_line(c1_ + ts[2] + opt_v, c1_ + ts[2] + opt_v - ts[3].rotated(PI/2) * 50, Color.RED, 3)
	
	var v_ = OrcaUtils.randomized_bounded_lp(
		hps_,
		opt_v,
		opt_v,
		50
	)
	
	if not v_:
		v_ = Vector2(0,0)
	#print("outside_v")
	#print(hp_.p)
	#print(v_)
	#print(v_)
	
	draw_line(
		c1_,
		c1_ + v_,
		Color.LAWN_GREEN,
		3
	)
	
	var agent_1 = {
		"position": Vector2(177.6088, 312.1458),
		"new_velocity": Vector2(0,0),
		"opt_velocity":Vector2(-4.745203, 49.77432)
	}
	
	var agent_2 = {
		"position": Vector2(163.3748, 304.0786),
		"new_velocity": Vector2(0,0),
		"opt_velocity":Vector2(11.27111, 48.71306)
	}
	

	var paths = agent_1["position]
	
	OrcaUtils.set_velocities(
		[agent_1, agent_2],
		[]
	)
	
	
	var v = OrcaUtils.closest_point_on_vo_boundary_2(
		Vector2(483.7, 401.763),
		Vector2(499.079, 406.179),
		8,
		8,
		1,
		Vector2(38.987, 31.305)
	)
	print(Vector2(483.7, 401.763).distance_to(Vector2(499.079, 406.179)))
	
	print(v)

static func test_randomized_bounded_lp_2():
	var plane_1 = HalfPlane.new(
		Vector2(0, 25),
		Vector2(1, -2).normalized(),
		Vector2(2, 1).normalized(),
		-1
	)
	
	var plane_2 = HalfPlane.new(
		Vector2(0, 25),
		Vector2(1,0),
		Vector2(0,-1),
		-1
	)
	
	var planes : Array[HalfPlane] = [plane_1, plane_2]
	
	var c = Vector2(100, 30)
	
	var opt_x = c
	
	var p = randomized_bounded_lp(
		planes,
		c,
		c,
		20
	)


static func test_randomized_bounded_lp():
	var plane_1 = HalfPlane.new(
		Vector2(10, 10),
		Vector2(0,-1),
		Vector2(-1,0),
		-1
	)
	
	var plane_2 = HalfPlane.new(
		Vector2(10, 0),
		Vector2(-1,0),
		Vector2(0,1),
		-1
	)
	
	var plane_3 = HalfPlane.new(
		Vector2(0, 10),
		Vector2(1, 0),
		Vector2(0, -1),
		-1
	)
	
	var plane_4 = HalfPlane.new(
		Vector2(0, 0),
		Vector2(0, 1),
		Vector2(1, 0),
		-1
	)
	
	var planes : Array[HalfPlane] = [
		plane_1,
		plane_2,
		plane_3,
		plane_4
	]
	
	var c = Vector2(30, 30)
	
	var opt_x = Vector2(
		30,
		30
	)
	
	var p = randomized_bounded_lp(
		planes,
		c,
		c,
		30
	)
	
static func test_find_opt_v():
	var plane_1 = HalfPlane.new(
		Vector2(10, 10),
		Vector2(0,-1),
		Vector2(-1,0),
		-1
	)
	
	var plane_2 = HalfPlane.new(
		Vector2(10, 0),
		Vector2(-1,0),
		Vector2(0,1),
		-1
	)
	
	var plane_3 = HalfPlane.new(
		Vector2(0, 10),
		Vector2(1, 0),
		Vector2(0, -1),
		-1
	)
	
	var plane_4 = HalfPlane.new(
		Vector2(0, 0),
		Vector2(0, 1),
		Vector2(1, 0),
		-1
	)
	var H = [
		plane_1,
		plane_2,
		plane_3,
		plane_4
	]
	
	
	var c = Vector2(-1,-1)
	
	var opt_v = find_opt_v(
		H,
		c
	)
	
	print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
	print("Opt_v is: " + str(opt_v))
	print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
		"""
