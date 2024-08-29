extends Node

class_name OrcaUtils


static func on_segment(l1 : Vector2, l2 : Vector2, p : Vector2):
	var dist = l1.distance_to(l2)
	if dist < l1.distance_to(p):
		return false
	if dist < l2.distance_to(p):
		return false
	if (l2-l1).dot(p-l1) < 0:
		return false
	return true

static func closest_point_on_vo_boundary(
	p1 : Vector2,
	p2 : Vector2,
	rA,
	rB,
	tau,
	opt_v
):
	var m1 = (p2 - p1)/tau
	var m2 = p2 - p1
	#var m3 = m2 + (m1 - m2) / 2
	
	var r1 = (rA + rB) / tau
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
	var s1_up = c1 + r1 * dir_out
	var s2_up= m1 + r1 * dir_out
	var s1_down = c2 + r1 * dir_out_2
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
	
	
	var p1_online :Vector2 = GeometryUtils.get_closest_point_on_line(s3_up, s2_up, opt_v)
	
	if p1_online.distance_to(opt_v) < min_dist and on_segment(s3_up, s2_up, p1_online):
		closest_point =  p1_online
		min_dist = p1_online.distance_to(opt_v)
	var p2_online = GeometryUtils.get_closest_point_on_line(s3_down, s2_down, opt_v)
	if p2_online.distance_to(opt_v) < min_dist and on_segment(s3_down, s2_down, p2_online):
		closest_point =  p2_online
		min_dist = p2_online.distance_to(opt_v)
	var p3_online = GeometryUtils.get_closest_point_on_line(s3_up, s3_down, opt_v)
	if p3_online.distance_to(opt_v) < min_dist and on_segment(s3_up, s3_down, p3_online):
		closest_point =  p3_online
		min_dist = p3_online.distance_to(opt_v)
	
	
	return [m1, m2, r1, r2, s3_up, s2_up, s3_down, s2_down, closest_point]

class HalfPlane:
	var p : Vector2
	var l_dir : Vector2
	var p_dir : Vector2
	
	func _init(p, l_dir, p_dir) -> void:
		self.p = p
		self.l_dir = l_dir
		self.p_dir = p_dir

static func intersect_halfplanes(halfplanes):
	var n = len(halfplanes)
	if n == 1:
		return halfplanes[1]
	var n_half = int(n / 2)
	var halfplanes_1 = halfplanes.slice(0, n_half)
	var halfplanes_2 = halfplanes.slice(n_half, n)
	
static func element_of(half_plane: HalfPlane, p: Vector2, c: Vector2):
	var to_point : Vector2 = p - half_plane.p
	return to_point.dot(half_plane.p_dir) >= 0


static func left_bounded(half_plan: HalfPlane):
	if half_plan.p_dir.dot(Vector2(1,0)) > 0:
		return true
	return false
	
static func right_bounded(half_plan: HalfPlane):
	if half_plan.p_dir.dot(Vector2(1,0)) < 0:
		return true
	return false
	
static func down_bounded(half_plan: HalfPlane):
	if half_plan.p_dir.y == -1:
		return true
	return false
	
static func up_bounded(half_plan: HalfPlane):
	if half_plan.p_dir.y == 1:
		return true
	return false
	
static func evaluate_constraints(half_planes : Array[HalfPlane], half_plane: HalfPlane, c: Vector2):
	var v_left = Vector2(-INF, 0)
	var v_right = Vector2(INF, 0)
	var v_up = Vector2(0, -INF)
	var v_down = Vector2(0, INF)

	for h_p in half_planes:
		
		var intersection = GeometryUtils.get_intersection(
			half_plane.p,
			half_plane.l_dir,
			h_p.p,
			h_p.l_dir
		)
		if intersection == null:
			continue
		
		if left_bounded(h_p):
			if intersection != null and v_left.x < intersection.x:
				v_left = intersection
			elif intersection != null and v_left.x == intersection.x:
				if intersection.dot(c) > v_left.dot(c):
					v_left = intersection
		elif right_bounded(h_p):
			if intersection != null and v_right.x > intersection.x:
				v_right = intersection
			elif intersection != null and v_right.x == intersection.x:
				if intersection.dot(c) > v_right.dot(c):
					v_right = intersection
		elif up_bounded(h_p):
			if intersection != null and v_up.y < intersection.y:
				v_up = intersection
			elif intersection != null and v_up.y == intersection.y:
				if intersection.dot(c) > v_up.dot(c):
					v_up = intersection
		elif down_bounded(h_p):
			if intersection != null and v_down.y > intersection.y:
				v_down = intersection
			elif intersection != null and v_down.y == intersection.y:
				if intersection.dot(c) > v_down.dot(c):
					v_down = intersection
	
	if v_left.x == -INF:
		v_left = null
	if v_right.x == INF:
		v_right = null
	if v_up.y == -INF:
		v_up = null
	if v_down.y == INF:
		v_down = null
	
	
	if v_left and v_right and v_left.x > v_right.x:
		return null
		
	if v_up and v_down and v_up.y > v_down.y:
		return null
	
	var max = -INF
	
	var v = null
	
	for intersection in [v_left, v_right, v_up, v_down]:
		if intersection == null:
			continue
		var value = intersection.dot(c)
		if value > max:
			v = intersection
			max = value
	return v

static func randomized_bounded_lp(half_planes : Array[HalfPlane], c, m1, m2):
	var v = Vector2(0,0)
	var dir1 = Vector2(1,0)
	var dir2 = Vector2(0,1)
	
	v.x = -m1
	if c.x > 0:
		v.x = m1
		dir1 = -dir1
	v.y = - m2
	if c.y > 0:
		v.y = m2
		dir2 = -dir2
		
	var plane_m1 = HalfPlane.new(
		Vector2(v.x, 0),
		Vector2(0,1),
		dir1
	)
	var plane_m2 = HalfPlane.new(
		Vector2(0, v.y),
		Vector2(1,0),
		dir2
	)
	
	half_planes.shuffle()
	var nr_plans = len(half_planes)
	var ps : Array[HalfPlane] = [plane_m1, plane_m2]
	half_planes = ps + half_planes
	
	
	for i in range(nr_plans):
		if element_of(half_planes[i+2], v, c):
			continue
		var h_ps = half_planes.slice(0, i + 2)
		v = evaluate_constraints(h_ps, half_planes[i+2], c)
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
	
	var c = Vector2(-1, -1)
	
	var p = randomized_bounded_lp(
		planes,
		c,
		10000,
		10000
	)
	print("p is: " + str(p))
	

