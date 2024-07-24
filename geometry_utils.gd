class_name GeometryUtils
extends Node

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
	for i in range(n-1):
		var s1 = shape[i]
		var s2 = shape[i+1]
		if intersection_exists(s1, s2, p, q):
			return true
	if intersection_exists(shape[0], shape[n-1], p, q):
		return true
	return false
	
static func isometric_distance(p,q):
	var d = q - p
	return sqrt(d.x**2/2 + 2 * d.y**2)
