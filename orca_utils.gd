extends Node

class_name OrcaUtils


static func on_segment(l1 : Vector2, l2 : Vector2, p : Vector2):
	if (l2-l1).dot(p-l1) < 0:
		return false
	if (l1-l2).dot(p-l2) < 0:
		return false
	return true
	
static func on_half_line(l_start : Vector2,  l_point: Vector2, p : Vector2):
	if (l_point - l_start).dot(p-l_start) < 0:
		return false
	return true
		

static func outside_normal(l1: Vector2, l2: Vector2, point: Vector2):
	var dir = l1.direction_to(l2)
	var p = l2 - point
	return (p - dir.dot(p)*dir).normalized()

static func closest_point_on_vo_boundary(
	p1 : Vector2,
	p2 : Vector2,
	rA: float,
	rB: float,
	tau: float,
	opt_v
):
	var m1 = (p2 - p1)/float(tau)
	var m2 = p2 - p1
	#var m3 = m2 + (m1 - m2) / 2
	
	var r1 = float(rA + rB) / tau
	var r2 = rA + rB
	
	var r3 = (r1 + r2) / 2
	
	var x = r1**2/(2*r3)
	var y = r1 * sqrt(1-r1**2/(4*r3**2))
	var dir = m2.direction_to(m1)
	var dir_rot_90 = dir.rotated(PI/2)

	var c1 = m2 + dir * x + dir_rot_90 * y
	var c2 = m2 + dir * x - dir_rot_90 * y
	var dir_out = 	(dir * x + dir_rot_90 * y).normalized()
	var dir_out_2 = (dir * x - dir_rot_90 * y).normalized()
	var s1_up = c1 + (r2-r1) * dir_out
	var s2_up= m1 + r1 * dir_out
	var s1_down = c2 + (r2-r1) * dir_out_2
	var s2_down= m1 + r1 * dir_out_2
	var m1_out = dir * x + dir_rot_90 * y + r1 * dir_out
	var m2_out = dir * x - dir_rot_90 * y + r1 * dir_out_2
	var l_x = abs(m1_out.dot(dir)) + r2
	var tangent_1 = (s1_up-s2_up).normalized()
	var m_tangent_1 = (s1_up - s2_up).dot(dir_rot_90)/(s1_up - s2_up).dot(dir)
	var m_tangent_2 = (s1_down - s2_down).dot(dir_rot_90)/(s1_down - s2_down).dot(dir)
	var s3_up = s1_up - dir * l_x  - m_tangent_1 * l_x * dir_rot_90
	var s3_down = s1_down - dir * l_x  - m_tangent_2 * l_x * dir_rot_90
	var closest_point = Vector2(0,0)
	
	var min_dist = INF
	
	
	var circ_dir = GeometryUtils.get_closest_point_on_line(s2_up, s2_down, m1) - m1
	
	if (opt_v-s2_up).dot(circ_dir) > 0:
		var r_dir = m1.direction_to(opt_v)
		closest_point = m1 + r1 * r_dir
		var u = closest_point - opt_v
		var n = m1.direction_to(closest_point)
		return [m1, m2, r1, r2, s3_up, s2_up, s3_down, s2_down, closest_point, u, n]
	#if outside_normal(s3_up, s3_down, m1).dot(opt_v-s3_up) >= 0:
	#	closest_point = GeometryUtils.get_closest_point_on_line(s3_up, s3_down, opt_v)
	#	if not on_segment(s3_up, s3_down, closest_point):
	#		closest_point = s3_up
	#		if s3_up.distance_to(opt_v) > s3_down.distance_to(opt_v):
	#			closest_point = s3_down
	#	var n = outside_normal(s3_up, s3_down, m1)
	#	var u = closest_point - opt_v 
	#	return [m1, m2, r1, r2, s3_up, s2_up, s3_down, s2_down, closest_point, u, n]
		
	var p1_online :Vector2 = GeometryUtils.get_closest_point_on_line(s3_up, s2_up, opt_v)
	
	var n = null #= Vector2(0,0)
	
	if p1_online.distance_to(opt_v) < min_dist: #and on_segment(s3_up, s2_up, p1_online):
		closest_point =  p1_online
		min_dist = p1_online.distance_to(opt_v)
		n = outside_normal(s3_up, s2_up, m1) 
	var p2_online = GeometryUtils.get_closest_point_on_line(s3_down, s2_down, opt_v)
	if p2_online.distance_to(opt_v) < min_dist: #and on_segment(s3_down, s2_down, p2_online):
		closest_point =  p2_online
		min_dist = p2_online.distance_to(opt_v)
		n = outside_normal(s3_down, s2_down, m1) 
	#var p3_online = GeometryUtils.get_closest_point_on_line(s3_up, s3_down, opt_v)
	#if p3_online.distance_to(opt_v) < min_dist and on_segment(s3_up, s3_down, p3_online):
	#	closest_point =  p3_online
	#	min_dist = p3_online.distance_to(opt_v)
	#	n = outside_normal(s3_up, s3_down, m1) 
	
	#if n == null:
	#	closest_point = s3_up
	#	if s3_up.distance_to(opt_v) > s3_down.distance_to(opt_v):
	#		closest_point = s3_down
	#	n = outside_normal(s3_up, s3_down, m1) 
	
	var u: Vector2 = closest_point - opt_v
	
	
	#var in_circle = Geometry2D.is_point_in_circle(opt_v, m1, r1)
	#var in_polygon =  Geometry2D.is_point_in_polygon(opt_v,[s2_up, s3_up, s3_down, s1_down])
	
	#var inside = in_circle or in_polygon
	
	#if not inside:
	#	n = -n
	
	#s3_up = s1_up
	#s3_down = s1_down
	
	return [m1, m2, r1, r2, s3_up, s2_up, s3_down, s2_down, closest_point, u, n]

static func closest_point_on_vo_boundary_2(
	p1 : Vector2,
	p2 : Vector2,
	rA: float,
	rB: float,
	tau: float,
	opt_v
):
	var m1 = (p2 - p1)/float(tau)
	var r1 = float(rA + rB) / tau
	
 
	
	#if m1.length() < r1:
	#	r1 = m1.length()
	#	var n = (opt_v - m1).normalized()
	#	return [Vector2(1,0), Vector2(1,0), m1 + n * r1 - opt_v, n]
	
	var ts = determine_tangent_to_circle(m1, r1)
	
	# if agents are touching each other tangent will become zero
	if not ts[0]:
		var n = -m1.normalized()
		var u = m1 + r1 * n
		return [ts[0], ts[1], u, n] 
	
	var t1 = ts[0]
	var t2 = ts[1]
	
	#if m1.length() <= r1:
	#	return [t1, t2 ,-m1, -m1.normalized()]
	
	#if not t1:
	#	return Vector2(0,0)
	#if not t2:
	#	return Vector2(0,0)
	
	var us = []
	var ns = []
	
	var on_t1 = on_half_line(t1, 2 * t1, opt_v )  
	var on_t2 = on_half_line(t2, 2 * t2, opt_v )  
	
	if on_t1:
		#print("on segment t1")
		var n1 = outside_normal(Vector2(0, 0), t1, m1)
		var u1 : Vector2 = GeometryUtils.get_closest_point_on_line(Vector2(0,0), t1, opt_v)
		ns += [n1]
		us += [u1]
	if on_t2:
		#print("on segment t1")
		var n1 = outside_normal(Vector2(0, 0), t2, m1)
		var u1 : Vector2 = GeometryUtils.get_closest_point_on_line(Vector2(0,0), t2, opt_v)
		ns += [n1]
		us += [u1]
	if not on_t1 and not on_t2:
		var n1 = (opt_v - m1).normalized()
		if not n1:
			n1 = -m1.normalized()
		var u1 = m1 + r1* n1
		ns += [n1]
		us += [u1]
	
	#var n1 = -m1.normalized()
	
	#us += [m1 + r1* n1 ]
	#ns += [n1]
		
	var dist = INF
	var u = null
	var n = null
	for i in range(len(ns)):
		var u_c = us[i]
		var dist_c = u_c.distance_to(opt_v)
		if dist_c < dist:
			dist = dist_c
			u = u_c
			n = ns[i]
	
	if u == null:
		print("warning no u")
		print(m1)
		print(r1)
		print(m1.length())
		print(t1)
		print(t2)
		print(us)
		print(ns)
	
	return [t1, t2, u - opt_v, n]

class HalfPlane:
	var p : Vector2
	var l_dir : Vector2
	var p_dir : Vector2
	
	func _init(p, l_dir, p_dir) -> void:
		self.p = p
		self.l_dir = l_dir.normalized()
		self.p_dir = p_dir.normalized()

static func intersect_halfplanes(halfplanes):
	var n = len(halfplanes)
	if n == 1:
		return halfplanes[1]
	var n_half = int(n / 2)
	var halfplanes_1 = halfplanes.slice(0, n_half)
	var halfplanes_2 = halfplanes.slice(n_half, n)
	
static func element_of(half_plane: HalfPlane, p: Vector2):
	var to_point : Vector2 = p - half_plane.p
	return to_point.dot(half_plane.p_dir) >= 0


static func left_bounded(half_plane: HalfPlane, org_plane: HalfPlane):
	
	var orientation = half_plane.p_dir.x
	var orientation_2 = org_plane.p_dir.x
	var p_dir = half_plane.p_dir
	var o_dir = org_plane.p_dir
	
	p_dir.y = -p_dir.y
	o_dir.y = -o_dir.y
	
	var switch = false
	if orientation < 0:
		p_dir = - p_dir
		switch = true
	if orientation_2 < 0:
		o_dir =  - o_dir
	
	var angle = GeometryUtils.polar_angle(p_dir)
	var angle_2 = GeometryUtils.polar_angle(o_dir)
	
	if angle_2 > angle and p_dir.y < 0:
		return switch
	if angle_2 < angle and p_dir.y > 0:
		return switch
		
	return not switch
		
	if angle_2 > angle and angle < PI/2 and switch:
		return false
	if angle_2 < angle and angle > PI/2 and switch:
		return false
		
	return switch
	
	#var angle = Vector2(1,0).dot(p_dir)
	#var angle_2 = Vector2(1,0).dot(o_dir)
	
	if angle < 0 and angle_2 > angle:
		return true
	elif  angle_2 < angle:
		return true
	
	#if abs(p_dir.dot(org_plane.p_dir)) <= PI/2:
	#	orientiation_2 = -1 
	#if orientation * orientiation_2 < 0:
	#	return true
	#var dot_p = half_plane.p_dir.dot(org_plane.p_dir)
	#if dot_p > 0:
	#	return true
	#if dot_p == 0:
	#	return half_plane.p_dir.dot(Vector2(0,1)) > 0
	return false
	
static func right_bounded(half_plane: HalfPlane, org_plane: HalfPlane):
	return not left_bounded(half_plane, org_plane)
	var orientation = half_plane.p_dir.x
	#var orientation_2 = half_plane.p_dir.x
	var orientiation_2 = 1
	if abs(half_plane.p_dir.dot(org_plane.p_dir)) <= PI/2:
		orientiation_2 = -1 
	if orientation * orientiation_2 >= 0:
		return true
	#if half_plan.p_dir.dot(Vector2(1,0)) < 0:
	#	return true
	return false
	
static func up_bounded(half_plan: HalfPlane):
	if half_plan.p_dir.y == -1:
		return true
	return false
	
static func down_bounded(half_plan: HalfPlane):
	if half_plan.p_dir.y == 1:
		return true
	return false
	
static func intersection_with_cirlce(
	half_plane: HalfPlane,
	v_opt: Vector2,
	delta_v: float
):
	var pl = half_plane.p
	var dir = half_plane.l_dir
	
	var pv = pl - v_opt 
	
	var p_05 = (pv.x * dir.x + pv.y * dir.y) 
	var q = pv.x**2 + pv.y**2 - delta_v**2
	
	var sq = (p_05)**2 - q 
	if sq < 0:
		return null
	var s1 = - p_05 - sqrt(sq)
	var s2 = - p_05 + sqrt(sq)
	
	var p1 = pl + s1 * dir
	var p2 = pl + s2 * dir
	
	var right = p1
	var left = p2

	
	if left.x > right.x:
		var temp = right
		right = left
		left = temp
		
	if dir.y != 1 or dir.y != -1:
		return {
		"right": right,
		"left": left,
		"up": null,
		"down": null
	}
	
	var up = left
	var down = right
	
	if left.y < right.y:
		up = right
		down = left
	
	return {
		"right": null,
		"left": null,
		"up": up,
		"down": down
	}
	
static func test_intersection_with_circle():
	var m1 = Vector2(300, 300)
	var dir = Vector2(1,1)  
	var half_plane = HalfPlane.new(
		m1,
		dir,
		Vector2(1, -1)
	)
	
	var m2 = Vector2(290, 325)
	var r = 50.0
	var intersection = intersection_with_cirlce(
		half_plane,
		m2,
		r
	)
	return [intersection, m2, r, half_plane]
	

static func in_range(point, left, right, up, down):
	if point == null:
		return false
	if left != null and left.x > point.x:
		return false
	if right != null and right.x < point.x:
		return false
	if up != null and up.y < point.y:
		return false
	if down != null and down.y > point.y:
		return false
	if down == null and left == null and right == null and down == null:
		return false
	return true

static func evaluate_constraints(
	half_planes : Array[HalfPlane],
	half_plane: HalfPlane,
	g_c: Vector2,
	delta_v: float,
	last
):
	var org_c = Vector2(g_c.x, g_c.y)
	#c = c.normalized() * 1000000
	var v_left = Vector2(-INF, 0)
	var v_right = Vector2(INF, 0)
	var v_up = Vector2(0, INF)
	var v_down = Vector2(0, -INF)

	for idx in half_planes.size():
		var c = g_c
		if idx <4:
			c =  g_c.normalized() * 10000000
		var h_p = half_planes[idx]
		var intersection = GeometryUtils.get_intersection(
			half_plane.p,
			half_plane.l_dir,
			h_p.p,
			h_p.l_dir
		)

		if intersection == null:
			#if half_planes.size() == 5:
			#	print("no intersection found")
			continue
		#else:
		#	print("instersection found")
		#	print(left_bounded(h_p, half_plane))
		#	print(right_bounded(h_p, half_plane))
		
		if left_bounded(h_p, half_plane):
			if intersection != null and v_left.x < intersection.x:
				v_left = intersection
			elif intersection != null and v_left.x == intersection.x:
				if intersection.distance_to(c) < v_left.distance_to(c):
					v_left = intersection
		elif right_bounded(h_p, half_plane):
			if intersection != null and v_right.x > intersection.x:
				v_right = intersection
			elif intersection != null and v_right.x == intersection.x:
				if intersection.distance_to(c) < v_right.distance_to(c):
					v_right = intersection
		elif up_bounded(h_p):
			if intersection != null and v_up.y > intersection.y:
				v_up = intersection
			elif intersection != null and v_up.y == intersection.y:
				if intersection.distance_to(c) < v_up.distance_to(c):
					v_up = intersection
		elif down_bounded(h_p):
			if intersection != null and v_down.y < intersection.y:
				v_down = intersection
			elif intersection != null and v_down.y == intersection.y:
				if intersection.distance_to(c) > v_down.distance_to(c):
					v_down = intersection
	
	var left = -INF
	var right = INF
	var up = INF
	var down = -INF
	if v_left != null:
		left = v_left.x
	if v_right != null:
		right = v_right.x
	if v_up != null:
		up = v_up.y
	if v_down != null:
		down = v_down.y
		
	var closest_point = GeometryUtils.get_closest_point_on_line(
		half_plane.p,
		half_plane.p +  half_plane.l_dir,
		g_c
	)
	
	if closest_point != null and closest_point.x > left and closest_point.x < right and closest_point.y  < up and closest_point.y > down:
		
		#if half_planes.size() == 5:
		#	print("nr planes")
		#	print(half_planes.size())
		#	print("left")
		#	print(left)
		#	print("right")
		#	print(right)
		#	print("up")
		#	print(up)
		#	print("down")
		#	print(down)
		if g_c.length() + delta_v < closest_point.length():
			return null
		
		return closest_point
	
	#print()
	#print("opt_c" + str(org_c))
	#print()
	#print("before v_left: " + str(v_left))
	#print("before v_right: " + str(v_right))
	#print("before v_up: " + str(v_up))
	#print("before v_down: " + str(v_down))
	#print()
	
	if true: #last: # and false:
		var circle_points = intersection_with_cirlce(
			half_plane,
			org_c,
			delta_v
		)
	
		if not circle_points:
			return null
	
		var intersection = circle_points["left"]
		
		
		var in_r = in_range(
			intersection,
			v_left,
			v_right,
			v_up,
			v_down
		)
		if intersection != null and v_left.x < intersection.x and in_r:
			v_left = intersection
		elif intersection != null and v_left.x == intersection.x and in_r:
			if intersection.distance_to(g_c) < v_left.distance_to(g_c):
				v_left = intersection
	
		intersection = circle_points["right"]
		
		in_r = in_range(
			intersection,
			v_left,
			v_right,
			v_up,
			v_down
		)
		if intersection != null and v_right.x > intersection.x and in_r:
			v_right = intersection
		elif intersection != null and v_right.x == intersection.x and in_r:
			if intersection.distance_to(g_c) < v_right.distance_to(g_c):
				v_right = intersection
			
		intersection = circle_points["up"]
		
		in_r = in_range(
			intersection,
			v_left,
			v_right,
			v_up,
			v_down
		)

		if intersection != null and v_up.y > intersection.y and in_r:
			v_up = intersection
		elif intersection != null and v_up.y == intersection.y and in_r:
			if intersection.distance_to(g_c) < v_up.distance_to(g_c):
				v_up = intersection
			
		intersection = circle_points["down"]
		in_r = in_range(
			intersection,
			v_left,
			v_right,
			v_up,
			v_down
		)
		if intersection != null and v_down.y < intersection.y and in_r:
			v_down = intersection
		elif intersection != null and v_down.y == intersection.y and in_r:
			if intersection.distance_to(g_c) > v_down.distance_to(g_c):
				v_down = intersection
		if org_c.distance_to(v_left) > delta_v:
			v_left = null
		if org_c.distance_to(v_right) > delta_v:
			v_right = null
		if org_c.distance_to(v_up) > delta_v:
			v_up = null
		if org_c.distance_to(v_down) > delta_v:
			v_down = null
	
	
	if v_left and v_left.x == -INF:
		v_left = null
	if v_right and v_right.x == INF:
		v_right = null
	if v_up and v_up.y == INF:
		v_up = null
	if v_down and v_down.y == -INF:
		v_down = null
	
	#print("v_left: " + str(v_left))
	#print("v_right: " + str(v_right))
	#print("v_up: " + str(v_up))
	#print("v_down: " + str(v_down))
	#print()
	
	var nr_null = 0
	
	#for vel in [v_left, v_right, v_up, v_down]:
	#	if not vel:
#			nr_null += 1
	#if nr_null >2:
	#	return null
	
	if v_left and v_right and v_left.x > v_right.x:
		return null
		
	if v_up and v_down and v_up.y < v_down.y:
		return null
	
	var min = INF
	
	var v = null
	
	
	
	for inter in [v_left, v_right, v_up, v_down]:
		if inter == null:
			continue
		var value = inter.distance_to(g_c)
		#if inter.length() >= 100:
		#	value -= 1000
		if value < min:
			v = inter
			min = value
			
			
	return v

static func randomized_bounded_lp(
	half_planes : Array[HalfPlane],
	c, 
	v_opt,
	delta_v
):
	var v = v_opt #Vector2(0,0)
	var dir1 = Vector2(1,0)
	var dir2 = Vector2(0,1)
	
	#v.x = -m1
	#if v.x > 0:
	#	v.x = m1
	#	dir1 = -dir1
	#v.y = - m2
	#if v.y > 0:
	#	v.y = m2
	#	dir2 = -dir2
		
	var plane_m1 = HalfPlane.new(
		Vector2(-10000, 0),
		Vector2(0,1),
		dir1
	)
	var plane_m2 = HalfPlane.new(
		Vector2(0, -10000),
		Vector2(1,0),
		dir2
	)
	
	var plane_m3 = HalfPlane.new(
		Vector2(10000, 0),
		Vector2(0,1),
		-dir1
	)
	var plane_m4 = HalfPlane.new(
		Vector2(0, 10000),
		Vector2(1,0),
		-dir2
	)
	
	half_planes.shuffle()
	var nr_planes = len(half_planes)
	var ps : Array[HalfPlane] = [plane_m1, plane_m2, plane_m3, plane_m4]
	half_planes = ps + half_planes
	
	
	#v = v_opt
	
	var found_vs = []
	
	for i in range(nr_planes):
		if element_of(half_planes[i+4], v): #and dist_current >= dist_current:
			continue
		var h_ps = half_planes.slice(0, i + 4) 
		
		v = evaluate_constraints(
			h_ps, #+ h_ps_2,
			half_planes[i+4],
			c,
			delta_v,
			i + 5 == nr_planes + 4
		)
		if v == null:
			return null
			
	return v

static func test_randomized_bounded_lp():
	var plane_1 = HalfPlane.new(
		Vector2(10, 10),
		Vector2(0,-1),
		Vector2(-1,0)
	)
	
	var plane_2 = HalfPlane.new(
		Vector2(10, 0),
		Vector2(-1,0),
		Vector2(0,1)
	)
	
	var plane_3 = HalfPlane.new(
		Vector2(0, 10),
		Vector2(1, 0),
		Vector2(0, -1)
	)
	
	var plane_4 = HalfPlane.new(
		Vector2(0, 0),
		Vector2(0, 1),
		Vector2(1, 0)
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
	
static func test_randomized_bounded_lp_2():
	var plane_1 = HalfPlane.new(
		Vector2(0, 25),
		Vector2(1, -2).normalized(),
		Vector2(2, 1).normalized()
	)
	
	var plane_2 = HalfPlane.new(
		Vector2(0, 25),
		Vector2(1,0),
		Vector2(0,-1)
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
	
	
static func set_velocity(agent, others_all, walls_all):
	var others = []
	
	var w11 = Vector2(200, 200)
	var w21 = Vector2(400, 500)
	var w31 = Vector2(450, 600)
	
	var walls = walls_all # [[w11, w21], [w21, w31]]
	
	for o in others_all:
		if o["position"].distance_to(agent["position"]) < 200:
			others.append(o)
	for w in walls_all:
		continue
		var c_p = GeometryUtils.get_closest_point_on_line(w[0], w[1], agent["position"])
		if c_p.distance_to(agent["position"]) < 200:
			walls.append(w)
			
	
	#if not agent["opt_velocity"]:
	#	agent["new_velocity"] = Vector2(0,0)
	var opt_vel = agent["opt_velocity"]
	var h_ps : Array[HalfPlane] = []
	for other in others:
		var opt_other = Vector2(0,0)
		if "new_velocity" in other: 
			opt_other = other["new_velocity"]
		var p1 = agent["position"]
		var p2 = other["position"]
		var vs = closest_point_on_vo_boundary_2( p1, p2, 8, 8, 1, opt_vel - opt_other )
		var u: Vector2 = vs[2]
		var n = vs[3]
		var factor = 1 #1/2
		if opt_other == Vector2(0,0):
			factor = 1.0		
		
		var h_p = HalfPlane.new(
			opt_vel + factor * u,
			n.rotated(-PI/2),
			n
		)
		h_ps.append(h_p)
		
	
		
	for wall in walls:
		var w1 = wall[0]
		var w2 = wall[1]
		var vs = determine_closest_point_on_wall_v_object(
			agent["position"],
			w1,
			w2,
			8,
			opt_vel,
			1.0
		)
		var u: Vector2 = vs[2]
		var n = vs[3]	
		
		var h_p = HalfPlane.new(
			opt_vel + u,
			n.rotated(-PI/2),
			n
		)
		h_ps.append(h_p)
		
	var new_velocity = randomized_bounded_lp(h_ps, agent["opt_velocity"], opt_vel, 50)
	if not new_velocity:
		new_velocity = Vector2(0,0)
		agent["opt_velocity"] = new_velocity#Vector2(0,0)
	agent["new_velocity"] = new_velocity
	
static func set_opt_velocities(agents: Array, paths: Array):
	var nr_agent = len(agents)
	for i in range(nr_agent):
		var path = paths[i]
		if not path:
			agents[i]["opt_velocity"] = Vector2(0,0)
			agents[i]["new_velocity"] = Vector2(0,0)
			continue
		var dir = agents[i]["position"].direction_to(path[0])
		agents[i]["opt_velocity"] = dir * agents[i]["velocity"]
		
	
static func set_velocities(agents : Array, paths: Array, walls: Array):
	set_opt_velocities(agents, paths)
	var nr_agents = len(agents)
	for i in range(nr_agents):
			var agent = agents[i]
			var others = agents.slice(0, i) + agents.slice(i+1, nr_agents)
			set_velocity(agent, others, walls)
	for i in range(nr_agents):
		if not agents[i]["new_velocity"]:
			continue
		var agent = agents[i]
		var others = agents.slice(0, i) + agents.slice(i+1, nr_agents)
		set_velocity(agent, others, walls)
		
static func determine_tangent_to_circle(c, r: float):
	var devisor = c.x**2 + c.y**2
	var p_2 = (c.x**3 + c.x * c.y**2 - r**2 * c.x)/ devisor
	var q =  ((c.x**2 - r**2)**2 - r**2 * c.y**2 + c.x**2 * c.y**2)/devisor
	var p1 = p_2 - sqrt( p_2**2 - q )
	#p1 = p_2 + sqrt( p_2**2 - q )
	var p2 = sqrt( r**2 - (p1 -c.x)**2) + c.y
	var d = c.length()
	var s1 = (1.0 - r**2/d**2) * c 
	var s2 = sqrt(d**2 - r**2)* r/d**2 * Vector2(c.y, -c.x)
	var t1 = s1 + s2
	var t2 = s1 - s2
	return [t1, t2]

static func determine_closest_point_on_wall_v_object(pos: Vector2, w1: Vector2, w2: Vector2, r: float, v: Vector2, tau: float):
	var c1 = (w1 - pos) / tau
	var c2 = (w2 - pos) / tau
	r = r / tau
	var ts = determine_tangent_to_circle(c1, r)
	var ts2 = determine_tangent_to_circle(c2, r)
	var t1: Vector2 = ts[0]
	if abs(t1.angle_to(c2)) < abs(ts[1].angle_to(c2)):
		t1 = ts[1]
	var t2 : Vector2 = ts2[0]
	if abs(t2.angle_to(c1)) < abs(ts2[1].angle_to(c1)):
		t2 = ts2[1]
	
	var dir = outside_normal(t1, t2, Vector2(0,0))	
	
	var n = null
	var u = null
	
	var n1_n = -outside_normal(c1, c2, Vector2(0,0))
	var c1_n = c1 + n1_n * r
	var c2_n = c2 + n1_n * r
	
	var us = []
	var ns = []
	if on_half_line(t1, 2 * t1, v ):
		var n1 = outside_normal(Vector2(0, 0), t1, c1)
		var u1 : Vector2 = GeometryUtils.get_closest_point_on_line(Vector2(0,0), t1, v)
		# Edge cases
		var u3 = t1
		var u4 = t2
		ns += [n1]
		us += [u1]
	if  on_half_line(t2, 2 * t2, v ):
		var n2 = outside_normal(Vector2(0, 0), t2, c2)
		var u2 : Vector2 = GeometryUtils.get_closest_point_on_line(Vector2(0,0), t2, v)
		ns += [n2]
		us += [u2]
	if on_segment(c1, c2, v):
		var u1 = GeometryUtils.get_closest_point_on_line(c1_n, c2_n, v)
		ns += [n1_n]
		us += [u1]
	if not on_segment(c1, c2, v) and not on_segment(t1, 100000 * t1.normalized(), v):
		var n1 = (v - c1).normalized()
		var u1 = c1 + n1 * r
		ns += [n1]
		us += [u1]
	if not on_segment(c1, c2, v) and not on_segment(t2, 100000 * t2.normalized(), v):
		var n1 = (v - c2).normalized()
		var u1 = c2 + n1 * r
		ns += [n1]
		us += [u1]

	ns += [n1_n, n1_n, outside_normal(Vector2(0, 0), t1, c1), outside_normal(Vector2(0, 0), t2, c2)]
	us += [c1_n, c2_n, t1, t2]
		
	var dist = INF
	for i in range(len(ns)):
		var u_c = us[i]
		var dist_c = u_c.distance_to(v)
		if dist_c < dist:
			dist = dist_c
			u = u_c
			n = ns[i]
			
	var n_out = -outside_normal(c1, c2, Vector2(0, 0))
	
	return [t1, t2, u - v , n, c1 + n_out * r, c2 + n_out*r]
	
static func test_tangent_to_circle():
	var r = 90
	var center = Vector2(150,150)
	var p = determine_tangent_to_circle(center, r)
	return [p[0], r, center, p[1]]
	
static func find_opt_v(H,c):
	
	H.shuffle()
	
	var dir_1 = Vector2(-1,0)
	var dir_2 = Vector2(0,-1)
	var x = 10000
	var y = 10000
	
	if c.x < 0:
		dir_1 = -dir_1
		x = -x
	if c.y < 0:
		dir_2 = -dir_2
		y = -y
		
	var v = Vector2(x,y)
		
	var m1 = HalfPlane.new(
		v,
		Vector2(0,1),
		dir_1
	)
	var m2 = HalfPlane.new(
		v,
		Vector2(1,0),
		dir_2
	)
	
	var hps : Array = [m1, m2] + H
	
	for i in H.size():
		if element_of(H[i], v):
			continue
		v = max_v(H[i], hps.slice(0, i+2), c)
		#for h in hps.slice(0, i+2):
		#	print(h.p)
		if v == null:
			return Vector2(0,0)
	return v
		
	
static func max_v(h, hps, c):
	var v_left = Vector2(-INF, 0)
	var v_right = Vector2(INF, 0)
	for hp in hps:
		var intersection = GeometryUtils.get_intersection(
			h.p,
			h.l_dir,
			hp.p,
			hp.l_dir
		)
		if intersection == null:
			continue
		if left_bounded(hp, h):
			if intersection.x > v_left.x:
				v_left = intersection
			if intersection.x == v_left.x:
				v_left = lexigraphical_max(v_left, intersection, c)
		else:
			if intersection.x < v_right.x:
				v_right = intersection
			if intersection.x == v_right.x:
				v_right = lexigraphical_max(v_right, intersection, c)
	if v_left.x > v_right.x:
		return null
	if v_left.x == -INF:
		return v_right
	if v_right.x == INF:
		return v_left
	return lexigraphical_max(v_left, v_right, c)

static func lexigraphical_max(p1, p2, c):
	var opt_p1 = p1.dot(c)
	var opt_p2 = p2.dot(c)
	if opt_p1 > opt_p2:
		return p1
	if opt_p2 > opt_p1:
		return p2
	if p1.x < p2.x:
		return p1
	if p1.x == p2.x and p1.y < p2.y:
		return p1
	return p2
	
static func test_find_opt_v():
	var plane_1 = HalfPlane.new(
		Vector2(10, 10),
		Vector2(0,-1),
		Vector2(-1,0)
	)
	
	var plane_2 = HalfPlane.new(
		Vector2(10, 0),
		Vector2(-1,0),
		Vector2(0,1)
	)
	
	var plane_3 = HalfPlane.new(
		Vector2(0, 10),
		Vector2(1, 0),
		Vector2(0, -1)
	)
	
	var plane_4 = HalfPlane.new(
		Vector2(0, 0),
		Vector2(0, 1),
		Vector2(1, 0)
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
	
