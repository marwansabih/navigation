class_name OrcaUtils

extends Node

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

	var ts = determine_tangent_to_circle(m1, r1)
	
	var t1 = ts[0]
	var t2 = ts[1]
	
	if m1.length() <= r1 + 0.01:
		#var l = m1.length()
		var n = -m1.normalized()
		var u : Vector2 = GeometryUtils.get_closest_point_on_line(
			Vector2(0,0),
			n.rotated(PI/2),
			opt_v
		)
		return [ts[0], ts[1], u - opt_v, n] 
		
	

	
	# if agents are touching each other tangent will become zero
	if (t1.x == 0.0 and t1.y == 0.0) or not t1 or is_nan(t1.x) or is_nan(t1.y):
		var n = -m1.normalized()
		var u : Vector2 = GeometryUtils.get_closest_point_on_line(
			Vector2(0,0), n.rotated(PI/2), opt_v
		)
		return [ts[0], ts[1], u - opt_v, n] 
	
	if (t2.x == 0.0 and t2.y == 0.0) or not t2 or is_nan(t2.x) or is_nan(t2.y):
		var n = -m1.normalized()
		var u : Vector2 = GeometryUtils.get_closest_point_on_line(
			Vector2(0,0), n.rotated(PI/2), opt_v
		)
		return [ts[0], ts[1], u - opt_v, n] 
	
	var us = []
	var ns = []
	
	var on_t1 = on_half_line(t1, 2 * t1, opt_v )  
	var on_t2 = on_half_line(t2, 2 * t2, opt_v )  
	
	if on_t1:
		var n1 = outside_normal(Vector2(0, 0), t1, m1)
		var u1 : Vector2 = GeometryUtils.get_closest_point_on_line(Vector2(0,0), t1, opt_v)
		ns += [n1]
		us += [u1]
	if on_t2:
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
		
	var dist = INF
	var u_velocity = null
	var normal = null
	for i in range(len(ns)):
		var u_c = us[i]
		var dist_c = u_c.distance_to(opt_v)
		if dist_c < dist:
			dist = dist_c
			u_velocity = u_c
			normal = ns[i]
	
	return [t1, t2, u_velocity - opt_v, normal]

static func closest_point_on_wall_boundary(
	pos : Vector2,
	wall,
	rA: float,
	tau: float,
	opt_v
):
	

	
	var c1 = (wall[0] - pos)/tau
	var c2 = (wall[1] - pos)/tau
	
	var p1: Vector2
	var p2: Vector2
	var u_velocity: Vector2
	
	var outside_dir = wall[2]
	
	rA = rA/tau
	
	# need to use outside_dir to check whether infront
	# or behind wall
	
	var behind_wall =  c1.dot(outside_dir) >= 0
	
	# wall is hidden behind some other wall infront of it
	if behind_wall:
		return null
	
	# Touching the wall will be handled here
	var c_p = GeometryUtils.get_closest_point_on_line(c1, c2, Vector2(0,0))
	if c_p.length() <= rA + 0.000001 and in_front_range(c1, c2, Vector2(0,0)):
		p1 = c1 + rA * outside_dir
		p2 = c2 + rA * outside_dir
		u_velocity = GeometryUtils.get_closest_point_on_line(
			p1,
			p2,
			opt_v
		) 
		return [
			p1, #0
			p2, #1 
			Vector2(1,0), #2 
			Vector2(1,0), #3
			Vector2(0,0), #4
			Vector2(0,0), #5
			Vector2(0,0), #6
			Vector2(0,0), #7
			c1, #8
			c2, #9
			u_velocity - opt_v, #10
			outside_dir #11
		]
	
	var t1s = calculate_tangent_points(c1, rA)
	var t2s = calculate_tangent_points(c2, rA)
	
	var t1 = t1s[0]
	var t2 = t2s[0]
	
	if c2.distance_to(t1) > c2.distance_to(t1s[1]):
		t1 = t1s[1]
	
	if c1.distance_to(t2) > c1.distance_to(t2s[1]):
		t2 = t2s[1]
	
	
	p1 = c1 + rA * outside_dir
	p2 = c2 + rA * outside_dir
	
	var p1_t = c1 - t1
	var p2_t = c2 - t2
	
	var t1_dir = p1_t 
	var t2_dir = p2_t	
	
	var on_t1 = on_half_line(p1_t, 2 * p1_t, opt_v )  
	var on_t2 = on_half_line(p2_t, 2 * p2_t, opt_v )
	var on_front_line = in_front_range(c1, c2, opt_v)
	
	var ns = []
	var us = []
		
	
	if on_t1 and c1 != t1:
		var n1 = outside_normal(Vector2(0, 0), p1_t, c1)
		var u1 : Vector2 = GeometryUtils.get_closest_point_on_line(Vector2(0,0), p1_t, opt_v)
		ns += [n1]
		us += [u1]
	if on_t2 and c2 != t2:
		var n1 = outside_normal(Vector2(0, 0), p2_t, c2)
		var u1 : Vector2 = GeometryUtils.get_closest_point_on_line(Vector2(0,0), p2_t, opt_v)
		ns += [n1]
		us += [u1]
	if on_front_line:
		var n1 = outside_dir
		var u1 : Vector2 = GeometryUtils.get_closest_point_on_line(p1, p2, opt_v)
		ns += [n1]
		us += [u1]
		
	var dist = INF
	var normal = null
	for i in range(len(ns)):
		var u_c = us[i]
		var dist_c = u_c.distance_to(opt_v)
		if dist_c < dist:
			dist = dist_c
			u_velocity = u_c
			normal = ns[i]  
	
	if not u_velocity:
		var c = c1
		if c1.distance_to(opt_v) > c2.distance_to(opt_v):
			c = c2
		normal = c.direction_to(opt_v)
		u_velocity = c + rA*normal
	
	return [p1, p2, t1_dir, t2_dir, p1_t, p2_t, t1 , t2, c1, c2, u_velocity - opt_v, normal]
	
static func in_front_range(c1: Vector2, c2: Vector2, point):
	var dir = c1.direction_to(c2)
	var d1 = c1.distance_to(c2)
	var d2 = dir.dot(point-c1)
	return d2 >= 0 and d2 <= d1

static func calculate_tangent_points(p: Vector2, r: float):
	# Will calculate the points lying on the tangents
	# of a circle at origin (0,0) 
	# and passing through the point p
	var d = p.length()
	var s1 = r**2/d**2*p
	var s2 = r/d**2*sqrt(d**2- r**2) * Vector2(-p.y, p.x)
	return [s1+ s2, s1 - s2]

class HalfPlane:
	var p : Vector2
	var l_dir : Vector2
	var p_dir : Vector2
	var wall_idx : int
	
	func _init(point, line_dir, plane_dir, wall_index) -> void:
		self.p = point
		self.l_dir = line_dir.normalized()
		self.p_dir = plane_dir.normalized()
		self.wall_idx = wall_index

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
	
static func right_bounded(half_plane: HalfPlane, org_plane: HalfPlane):
	return not left_bounded(half_plane, org_plane)
	
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
		Vector2(1, -1),
		-1
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
):
	var org_c = Vector2(g_c.x, g_c.y)
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
		return closest_point
	
	
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
	
	if v_left and v_right and v_left.x > v_right.x:
		return null
		
	if v_up and v_down and v_up.y < v_down.y:
		return null
	
	var minimum = INF
	
	var v = null
	
	
	
	for inter in [v_left, v_right, v_up, v_down]:
		if inter == null:
			continue
		var value = inter.distance_to(g_c)
		#if inter.length() >= 100:
		#	value -= 1000
		if value < minimum:
			v = inter
			minimum = value
			
			
	return v


static func randomized_bounded_lp(
	half_planes : Array[HalfPlane],
	c, 
	v_opt,
	delta_v
):
	var v = v_opt
	
	half_planes.shuffle()
	var nr_planes = len(half_planes)
	
	var wall_idx = -1
	
	for i in range(nr_planes):
		if element_of(half_planes[i], v): #and dist_current >= dist_current:
			continue
			
		var h_ps = half_planes.slice(0, i) 
		
		wall_idx = half_planes[i].wall_idx
		
		v = evaluate_constraints(
			h_ps,
			half_planes[i],
			c,
			delta_v
		)
		if v == null:
			return [null, null]
			
	return [wall_idx, v]
	
	
static func adjust_region(region, agent_position):
	var adjusted_regions = []
	for i in region.size():
		var hp = region[i]
		var half_plane = HalfPlane.new(
			hp.p - agent_position,
			hp.l_dir,
			hp.p_dir,
			hp.wall_idx
		)
		adjusted_regions.append(half_plane)
	return adjusted_regions
	
static func generate_agent_halfplanes(
	agent,
	others_all
):
	# Determine the allowed halfplanes for 
	var others = []
	
	for o in others_all:
		if o["position"].distance_to(agent["position"]) < 20:
			others.append(o)
			
	var opt_vel = agent["opt_velocity"]
	var h_ps : Array[HalfPlane] = []
	for other in others:
		var opt_other = Vector2(0,0)
		if "new_velocity" in other: 
			opt_other = other["new_velocity"]
		#if "opt_velocity" in other:
		#	opt_other = other["opt_velocity"]
		var p1 = agent["position"]
		var p2 = other["position"]
		if "new_velocity" in agent:
			opt_vel = agent["new_velocity"]
		
		var r1 = agent["radius"]
		var r2 = other["radius"]
		var vs = closest_point_on_vo_boundary_2( 
			p1,
			p2,
			r1,
			r2,
			1,
			opt_vel - opt_other 
		)
		var u: Vector2 = vs[2]
		var n = vs[3]
		var factor = 1 #1/2
		if opt_other == Vector2(0,0):
			factor = 1.0		
		
		var h_p = HalfPlane.new(
			opt_vel + factor*u,
			n.rotated(-PI/2),
			n,
			-1
		)
		h_ps.append(h_p)
	agent["half_planes"] = h_ps 
		

static func generate_wall_halfplanes(
	agent,
	walls
):
	var h_ps : Array[HalfPlane] = []
	var opt_vel = agent["opt_velocity"]
	for wall in walls:
		var pos = agent["agent"].position
		
		var vs = closest_point_on_wall_boundary(
			pos,
			wall,
			agent["radius"],
			1,
			opt_vel
		)
		
		if not vs:
			continue
		
		var u: Vector2 = vs[10]
		var n = vs[11]
		var factor = 1 #1/2		
		
		var h_p = HalfPlane.new(
			opt_vel + factor*u,
			n.rotated(-PI/2),
			n,
			-1
		)
		h_ps.append(h_p)
	return h_ps 

static func generate_agent_halfplanes_2(
	agent,
	others_all
):
	# Determine the allowed halfplanes for 
	var others = []
	
	for o in others_all:
		var o_pos = o["agent"].position
		var a_pos = agent["agent"].position
		if o_pos.distance_to(a_pos) < agent["radius"] + o["radius"] + 5:
			others.append(o)
			
	var opt_vel = agent["opt_velocity"]
	var h_ps : Array[HalfPlane] = []
	for other in others:
		var opt_other = Vector2(0,0)
		if "new_velocity" in other: 
			opt_other = other["new_velocity"]
		var p1 = agent["agent"].position
		var p2 = other["agent"].position
		if "new_velocity" in agent:
			opt_vel = agent["new_velocity"]
		#opt_other = Vector2(0,0)
		#opt_other = other["opt_velocity"]
		
		var r1 = agent["radius"]
		var r2 = other["radius"]
		
		var vs = closest_point_on_vo_boundary_2( 
			p1,
			p2,
			r1,
			r2,
			1,
			opt_vel - opt_other 
		)
		var u: Vector2 = vs[2]
		var n = vs[3]
		var factor = 1 #1/2
		if opt_other == Vector2(0,0):
			factor = 1.0		
		
		var h_p = HalfPlane.new(
			opt_vel + factor*u,
			n.rotated(-PI/2),
			n,
			-1
		)
		h_ps.append(h_p)
	agent["half_planes"] = h_ps 
	
static func get_close_walls(
	pos: Vector2,
	grid_position_to_walls,
	grid_size
):
	var grid_pos = PolygonUtils.position_to_grid_position(
		pos,
		grid_size
	)
	var walls = grid_position_to_walls[int(grid_pos.x)][int(grid_pos.y)]
	return walls
	
static func in_wall_range(
	pos: Vector2,
	grid_position_to_walls,
	wall_vision
):
	var walls = get_close_walls(
		pos,
		grid_position_to_walls,
		wall_vision
	)
	var close_wall = false
	for wall in walls:
		
		if pos.distance_to(wall[0]) < 16:
			return true
		if pos.distance_to(wall[1]) < 16:
			return true
		
		var w_p = GeometryUtils.get_closest_point_on_line(
			wall[0],
			wall[1],
			pos
		)
		var dist_to_p = wall[0].distance_to(
			w_p
		)
		
		var dist_to_p2 = wall[1].distance_to(
			w_p
		)
		
		var wall_length = wall[0].distance_to(
			wall[1]
		)
		
		
		if dist_to_p > wall_length:
			continue
		if dist_to_p2 > wall_length:
			continue
		
		var dist = pos.distance_to(
			w_p
		)
		
		if dist < 16:
			return true
	
	return close_wall
	
	
static func set_velocity(
	agent,
	others_all,
	grid_position_to_walls,
	wall_vision
):
	var others = []
	
	var walls = get_close_walls(
		agent["agent"].position,
		grid_position_to_walls,
		wall_vision
	)
	
	var wall_planes = generate_wall_halfplanes(
		agent,
		walls
	)

	for o in others_all:
		if o["agent"].position.distance_to(agent["agent"].position) < 200:
			others.append(o)
			
	var opt_vel = agent["opt_velocity"]
	
	var h_ps = agent["half_planes"]
	
	
	
	var half_planes : Array[HalfPlane] = []
	
	if not wall_planes:
		wall_planes = []
	
	half_planes.append_array(h_ps)
	half_planes.append_array(wall_planes)
	
	var xs = randomized_bounded_lp(
		half_planes,
		agent["opt_velocity"],
		opt_vel,
		agent["delta_v"]
	)
	
	var new_velocity = xs[1]
	
	if not new_velocity:
		new_velocity = Vector2(0,0)
	agent["new_velocity"] = new_velocity
	#agent["new_velocity"] = opt_vel
	
	
static func set_opt_velocities(agents: Array, paths: Array):
	var nr_agent = len(agents)
	for i in range(nr_agent):
		var path = paths[i]
		if not path:
			agents[i]["opt_velocity"] = Vector2(0,0)
			continue
		var dir = agents[i]["agent"].position.direction_to(path[0])
		agents[i]["opt_velocity"] = dir * agents[i]["velocity"]
	
static func get_other_agents(
	agents,
	indices
):
	var others = []
	for i in indices:
		others.append(agents[i])
	return others

		
static func set_velocities(
	agent_id_to_agent_data,
	grid_position_to_walls,
	wall_vision
):
	var agents = []
	var paths = []
	for agent_id in agent_id_to_agent_data:
		var agent = agent_id_to_agent_data[agent_id]
		agents.append(agent)
		paths.append(agent["shortest_path"])
		
	set_opt_velocities(agents, paths)
	var nr_agents = len(agents)
	var resting_agents = []
	var new_resting_agent = true
	
	for agent in agents:
		if not "new_velocity" in agent:
			agent["new_velocity"] = agent["opt_velocity"]
	
	while new_resting_agent:
		new_resting_agent = false
		
		var agent_idx = []
		
		for i in range(nr_agents):
			agent_idx.append(i)
		agent_idx.shuffle()
	
		for i in range(nr_agents):
			var agent = agents[agent_idx[i]]
			#var others = agent.slice(0, i) + agents.slice(i+1, nr_agents)
			var others_indices = agent_idx.slice(0, i) + agent_idx.slice(i+1, nr_agents)
			
			var others = get_other_agents(
				agents,
				others_indices
			)
			
			generate_agent_halfplanes_2(
				agent,
				others
			)
		
		for i in range(nr_agents):
			if i in resting_agents:
				continue
			var agent = agents[agent_idx[i]]
			#var others = agent.slice(0, i) + agents.slice(i+1, nr_agents)
			var others_indices = agent_idx.slice(0, i) + agent_idx.slice(i+1, nr_agents)
			
			var others = get_other_agents(
				agents,
				others_indices
			)
			
			set_velocity(
				agent,
				others,
				grid_position_to_walls,
				wall_vision
			)
			if agent["new_velocity"] == Vector2(0,0):
				resting_agents.append(i)
				new_resting_agent = true
				
		new_resting_agent = false
		
static func determine_tangent_to_circle(c, r: float):
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
	
	#var dir = outside_normal(t1, t2, Vector2(0,0))	
	
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
		#var u3 = t1
		#var u4 = t2
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
	
static func determine_closest_point_on_wall_segment(pos: Vector2, w1: Vector2, w2: Vector2, r: float, v: Vector2, tau: float):
	var c1 = (w1 - pos) / tau
	var c2 = (w2 - pos) / tau
	r = r/tau
	
	var n = -outside_normal(c1, c2, Vector2(0,0))
	var c1_n = c1 + n * r
	var c2_n = c2 + n * r
	var p : Vector2 = GeometryUtils.get_intersection(
		Vector2(0,0),
		v,
		c1,
		c2-c2
	)
	if p.length() < v.length():
		var u = GeometryUtils.get_closest_point_on_line(c1_n, c2_n, v)
		return [u-v , n, c1_n, c2_n]

	if (on_segment(c1, c2, Vector2(0,0)) and on_segment(c1, c2, v)) or on_segment(c1, c2, v):
		var u = GeometryUtils.get_closest_point_on_line(c1_n, c2_n, v)
		return [u-v , n, c1_n, c2_n]
	return null
	
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
		dir_1,
		-1
	)
	var m2 = HalfPlane.new(
		v,
		Vector2(1,0),
		dir_2,
		-1
	)
	
	var hps : Array = [m1, m2] + H
	
	for i in H.size():
		if element_of(H[i], v):
			continue
		v = max_v(H[i], hps.slice(0, i+2), c)
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
	
