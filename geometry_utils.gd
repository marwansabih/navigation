extends Node
class_name GeometryUtils

static func polar_angle(v: Vector2):
	var angle = v.angle()
	if angle < 0:
		angle += 2 * PI
	return angle
	
static func get_intersection(
	p1: Vector2,
	dir1: Vector2,
	p2: Vector2,
	dir2: Vector2
):
	if dir1 == dir2 or dir1 == - dir2:
		return null
	if dir1.x == 0:
		var s = (p1.x - p2.x) / dir2.x
		return p2 + s * dir2
	if dir1.y == 0:
		var s = (p1.y - p2.y) / dir2.y
		return p2 + s * dir2
	if dir2.x == 0:
		var t = (p2.x - p1.x) / dir1.x
		return p1 + t * dir1
	if dir2.y == 0:
		var t = (p2.y - p1.y) / dir1.y
		return p1 + t * dir1
	var numerator = p1.y * dir1.x - p1.x * dir1.y + p2.x * dir1.y - p2.y * dir1.x
	var denominator = dir1.x * dir2.y - dir2.x * dir1.y
	var f = numerator / denominator
	return p2 + f * dir2

static func get_closest_point_on_line(
	l1,
	l2,
	p
):
	var dir : Vector2 = (l2 - l1).normalized()
	var dir_90 = dir.rotated(PI/2)
	return get_intersection(l1, dir, p, dir_90)
	#var numerator = l1.y * dir.x - l1.x * dir.y + p.x * dir.y - p.y * dir.x
	#var denominator = dir.x * dir_90.y - dir_90.x * dir.y
	#var s = numerator / denominator
	#return p + s * dir_90

static func get_time_overlaps(
	p1: Vector2,
	v1: Vector2,
	p2: Vector2,
	v2: Vector2,
	radius: float
):
	var p: Vector2 = p2 - p1
	var s = (v2.x*p.y - v2.y*p.x)/(v1.y*v2.x  - v1.x * v2.y)
	var t = (s*v1.x - p.x)/v2.x
	var alpha = v1.normalized().angle_to(v2) 
	var h = 2*radius/sin(alpha)
	#var delta_s = h/v1.length()
	var delta_t = h/v2.length()
	
	return p2 + (t + delta_t) * v2

static func get_closest_edge(edges, pos):
	var minimum = INF
	var found_edge = null
	for i in range(len(edges)):
		var dist = edges[i].distance_to(pos)
		if dist < minimum:
			found_edge = i
			minimum = dist
	return found_edge

static func in_polygons_range(polygons, radius, pos):
	for p in polygons.get_children():
		var poly = p.polygon
		if in_polygon_range(poly, radius, pos):
			return true
	return false

static func in_polygon_range(polygon, radius, pos):
	var size = len(polygon)
	for i in range(size):
		var next_idx = (i+1) % size
		var p1: Vector2 = polygon[i]
		var p2: Vector2 = polygon[next_idx]
		var distance = p1.distance_to(pos)
		if distance <= radius+1:
			return true
		distance = p2.distance_to(pos)
		if distance <= radius +1:
			return true
		var dir: Vector2 = p1.direction_to(p2)
		var parallel = dir.dot(pos - p1)
		var between_points = 0 < parallel and parallel < (p2-p1).length()
		distance = abs(dir.rotated(PI/2).dot(pos-p1))
		var in_range = distance <  radius +1
		if between_points and in_range:
			return true
	return false	
	

static func get_wall_points(line, distance):
	var p1: Vector2 = line[0]
	var p2: Vector2 = line[1]
	var start = p1
	var end = p2
	if p1.y > p2.y:
		start = p2
		end = p1
	if p1.x < p2.x:
		start = p1
		end = p2
	
	var dir_1 = p1.direction_to(p2)
	var dir_2 = dir_1.rotated(PI/2)
	var A = start - dir_2 * distance
	var B = end - dir_2 * distance
	var C = end + dir_2 * distance
	var D = start + dir_2 * distance
	var polygon = [A,B,C,D]
	
	# Mark sourrounding rectangle
	var up = INF
	var down = -INF
	var left = INF
	var right = -INF

	for point in polygon:
		up = int(min(up, point.y))
		down =int(max(down, point.y))
		left = int(min(left, point.x))
		right = int(max(right, point.x))
		
	up = up - up % 8
	left = left - left % 8
	
	var positions = []
	
	for p_x in range(left, right + 1, 8):
		for p_y in range(up, down + 1, 8):
			var pos = Vector2(p_x, p_y)
			if Geometry2D.is_point_in_polygon(pos, polygon):
				positions.append(pos)
	return positions
		

static func orientation(p, q, r): 
	# to find the orientation of an ordered triplet (p,q,r) 
	# function returns the following values: 
	# 0 : Collinear points 
	# 1 : Clockwise points 
	# 2 : Counterclockwise 
	  
	# See https://www.geeksforgeeks.org/orientation-3-ordered-points/amp/  
	# for details of below formula.  
	  
	var val = (float(q.y - p.y) * (r.x - q.x)) - (float(q.x - p.x) * (r.y - q.y)) 
	if (val > 0): 
		# Clockwise orientation 
		return 1
	elif (val < 0): 
		  
		# Counterclockwise orientation 
		return 2
	else: 
		  
		# Collinear orientation 
		return 0
		
static func onSegment(p, q, r): 
	if ( (q.x <= max(p.x, r.x)) and (q.x >= min(p.x, r.x)) and 
		   (q.y <= max(p.y, r.y)) and (q.y >= min(p.y, r.y))): 
		return true
	return true
		
static func intersection_exists(
	p1: Vector2, 
	q1: Vector2,
	p2: Vector2,
	q2: Vector2
):
	# Find the 4 orientations required for  
	# the general and special cases 
	var o1 = orientation(p1, q1, p2) 
	var o2 = orientation(p1, q1, q2) 
	var o3 = orientation(p2, q2, p1) 
	var o4 = orientation(p2, q2, q1) 
  
	# General case 
	if ((o1 != o2) and (o3 != o4)): 
		return true
  
	# Special Cases 
  
	# p1 , q1 and p2 are collinear and p2 lies on segment p1q1 
	if ((o1 == 0) and onSegment(p1, p2, q1)): 
		return true
  
	# p1 , q1 and q2 are collinear and q2 lies on segment p1q1 
	if ((o2 == 0) and onSegment(p1, q2, q1)): 
		return true
  
	# p2 , q2 and p1 are collinear and p1 lies on segment p2q2 
	if ((o3 == 0) and onSegment(p2, p1, q2)): 
		return true
  
	# p2 , q2 and q1 are collinear and q1 lies on segment p2q2 
	if ((o4 == 0) and onSegment(p2, q1, q2)): 
		return true
  
	# If none of the cases 
	return false
 

static func interset_with_shape(shape: Array, p: Vector2,q: Vector2):
	var n = len(shape)
	for i in range(n):
		var s1 = shape[i]
		var s2 = shape[(i+1) % n]
		if intersection_exists(s1, s2, p, q):
			return true
	return false
	
static func isometric_distance(p,q):
	var d = q - p
	return sqrt(d.x**2/2 + 2 * d.y**2)


static func get_closest_mesh_position(position, grid_size):
	var dx = int(position.x) % grid_size
	var dy = int(position.y) % grid_size
	if dx > grid_size/2:
		dx += grid_size
	if dy > grid_size/2:
		dy += grid_size
	var x = int(position.x) - dx
	var y = int(position.y) - dy
	return Vector2(x,y)
