extends Node

class_name VFUtils

static func vector_field(
	pos: Vector2,
	dir: Vector2,
	lambda: float,
	x : float,
	y: float
):
	var dx = x - pos.x
	var dy = y - pos.y
	return Vector2(
		(lambda-1) * dir.x * dx**2 + lambda * dir.y * dx * dy - dir.x * dy**2,
		(lambda-1) * dir.y * dy**2 + lambda * dir.x * dx * dy - dir.y * dx**2
	)	

static func dipole(	
	pos: Vector2,
	dir: Vector2,
	x : float,
	y: float
):
	var dx = x - pos.x
	var dy = y - pos.y
	return Vector2(
		dir.x * dx**2 + 2 * dir.y * dx * dy - dir.x * dy**2,
		dir.y * dy**2 + 2 * dir.x * dx * dy - dir.y * dx**2
	)	
	
static func obstacle_field(
	pos: Vector2,
	goal: Vector2,
	x : float,
	y: float
):
	var dx = x - pos.x
	var dy = y - pos.y
	
	var p = goal.direction_to(pos)
	var decision = p.x * dx + p.y * dy
	if decision < 0:
		return vector_field(pos, p, 0, x, y)
	return vector_field(pos, p, 1, x, y)
	
static func beta(pos, radius, x, y):
	var dx = x - pos.x
	var dy = y- pos.y
	return radius**2 - dx**2 - dy**2

static func beta_z(radius):
	return -3*radius**2
	
static func beta_f(radius, delta_r):
	return (1 - (2 + delta_r)**2) * radius**2

static func sigma(pos, radius, x, y):
	var b_z = beta_z(radius)
	var b_f = beta_f(radius, 0.1)
	var b_r = beta(pos, radius, x, y)
	if b_r <= b_f:
		return 1
	if b_f < b_r and b_r < b_z:
		var a = 2/(b_z-b_f)**3
		var b = - 3*(b_z + b_f)/(b_z-b_f)**3
		var c =  6*b_z*b_f/(b_z-b_f)**3
		var d =  b_z**2*(b_z - 3*b_f)/(b_z-b_f)**3
		
		return a*b_r**3 + b * b_r**2 + c * b_r + d		
		
	return 0
	
static func in_obstacle(goal, obs_positions, radius):
	for pos in obs_positions:
		if goal.distance_to(pos) < radius:
			return true
	return false

static func get_dir(
	pos: Vector2,
	obstacle_positions, 
	goal: Vector2,
	radius,
	polygons,
	delta_t,
	in_polyrange: bool
):
	
	#if in_obstacle(goal, obstacle_positions, radius):
	#	if goal.distance_to(pos) < 3*radius:
	#		return Vector2(0,0)
	var attractive_field = dipole(
		goal,
		pos.direction_to(goal),
		pos.x,
		pos.y
	)
	
	var attractive_factor = 1
	
	var repulsive_field = Vector2(0,0)
	
	for o_pos in obstacle_positions:
		var sig = sigma(
			o_pos,
			radius,
			pos.x,
			pos.y
		)
		attractive_factor *= sig
		var r_f = obstacle_field(
			o_pos,
			goal,
			pos.x,
			pos.y
		)
		repulsive_field += (1-sig)*r_f
	
	var reverse = 1
	if in_polyrange:
		reverse = -1
	
	var dir = (attractive_factor * attractive_field + reverse * repulsive_field).normalized() 
	
	
	for obs_pos in obstacle_positions:
		var next_position = pos + dir * delta_t 
		if GeometryUtils.in_polygons_range(polygons, radius, next_position):
			return Vector2(0,0)
		if next_position.distance_to(obs_pos) < 2*radius:
			print("stopped")
			return Vector2(0,0)
		
	return dir
	#return attractive_field.normalized()
