class_name VisibilityHelper
extends Node

static func get_visible_corner_ids(areas, pos):
	var ids = []
	for i in areas.size():
		var area = areas[i]
		if not area:
			continue
		#if PolygonUtils.in_polygon(area, pos):
		if Geometry2D.is_point_in_polygon(
			pos, area
		):
			ids.append(i)
	return ids

static func get_box_line_intersection(p1: Vector2, p2: Vector2, dim_x: float, dim_y: float) -> Vector2:
	# Check if p1 is inside the box. The box is defined from (0,0) to (dim_x, dim_y)
	var p1_inside = (p1.x >= 0 and p1.x <= dim_x and p1.y >= 0 and p1.y <= dim_y)
	if not p1_inside:
		# If p1 is not inside, swap the points so that p1 becomes the inside point.
		var temp = p1
		p1 = p2
		p2 = temp

	var dir = p2 - p1  # Direction vector from inside to outside
	var t: float

	# Check left boundary (x = 0)
	if dir.x != 0:
		t = (0 - p1.x) / dir.x
		if t > 0 and t <= 1:
			var y_val = p1.y + t * dir.y
			if y_val >= 0 and y_val <= dim_y:
				return p1 + t * dir
	# Check right boundary (x = dim_x)
	if dir.x != 0:
		t = (dim_x - p1.x) / dir.x
		if t > 0 and t <= 1:
			var y_val = p1.y + t * dir.y
			if y_val >= 0 and y_val <= dim_y:
				return p1 + t * dir
	# Check top boundary (y = dim_y)
	if dir.y != 0:
		t = (dim_y - p1.y) / dir.y
		if t > 0 and t <= 1:
			var x_val = p1.x + t * dir.x
			if x_val >= 0 and x_val <= dim_x:
				return p1 + t * dir
	# Check bottom boundary (y = 0)
	if dir.y != 0:
		t = (0 - p1.y) / dir.y
		if t > 0 and t <= 1:
			var x_val = p1.x + t * dir.x
			if x_val >= 0 and x_val <= dim_x:
				return p1 + t * dir

	# If no valid intersection was found, return null.
	return Vector2(0,0)

static func in_area(point, dim_x, dim_y):
	var in_x_range =  point.x < dim_x and 0 < point.x
	var in_y_range =  point.y < dim_y and 0 < point.y
	return in_y_range and in_x_range
	
static func get_polygon_part(polygon, dim_x, dim_y, idx):
	var polygon_part = []
	var last_idx = idx
	while in_area(polygon[idx], dim_x, dim_y):
		polygon_part.append(polygon[idx])
		last_idx = idx
		idx = (idx + 1) % polygon.size()
	var intersection = get_box_line_intersection(
		polygon[last_idx],
		polygon[idx],
		dim_x,
		dim_y
	)
	return polygon_part + [intersection]

static func adjust_polygon(polygon: Array, dim_x, dim_y):
	var found_polygons = []
	var intersection_found = false
	for i in polygon.size():
		var p1 = polygon[i]
		var p2 = polygon[(i+1) % polygon.size()]
		var p1_not_in_area = not in_area(p1, dim_x, dim_y)
		var p2_in_area = in_area(p2, dim_x, dim_y)
		if p1_not_in_area and p2_in_area:
			intersection_found = true
			var intersection = get_box_line_intersection(
				p1,
				p2,
				dim_x,
				dim_y
			)
			var part = get_polygon_part(
				polygon,
				dim_x,
				dim_y, 
				(i+1) % polygon.size()	
			)
			found_polygons.append([intersection] + part)
	if not intersection_found:
		found_polygons.append(polygon)
	return found_polygons

		
		
static func generate_view_lines(
	observer,
	adjusted_polygons,
	visible_corners,
	dim_x,
	dim_y
):
	#var visible_corners = visible_corner_pairs["visible_corners"]
	var lines = []
	for corner in visible_corners:
		var line = generate_view_line(
			observer,
			corner,
			dim_x,
			dim_y
		)
		
		lines.append(line)
	var new_lines = []
	for line in lines:
		var new_line = line
		for polygon in adjusted_polygons:
			if not new_line:
				break
			new_line = adjust_line(
				new_line,
				polygon
			)
		new_lines.append(new_line)
	
	return new_lines
	
static func sort_by_angle(
	a,
	b
):
	return a[1] < b[1]
	
	
static func gernerate_visible_area(
	observer: Vector2,
	adjusted_polygons,
	visible_corner_pairs,
	dim_x,
	dim_y
):
	var v_cs = []
	
	for i in visible_corner_pairs["visible_corners"].size():
		var corner = visible_corner_pairs["visible_corners"][i]
		var rotation = visible_corner_pairs["corner_rotations"][i]
		var angle = observer.angle_to_point(corner)
		v_cs.append([corner, angle, rotation])
	
	v_cs.sort_custom(VisibilityHelper.sort_by_angle)
	
	var visible_corners = []
	var rotations = []
	
	for triple in v_cs:
		visible_corners.append(triple[0])
		rotations.append(triple[2])
	
	var view_lines = generate_view_lines(
		observer,
		adjusted_polygons,
		visible_corners,
		dim_x,
		dim_y
	)
	
	var visibility_polygon = []
	
	var size = view_lines.size()
	for i in size:
		var corner = visible_corners[i]
		var rotation = rotations[i]
		var line = view_lines[i]
		if not line:
			visibility_polygon.append(corner)
			continue
		if not rotation:
			visibility_polygon.append(line[1])
			visibility_polygon.append(corner)
		else:
			visibility_polygon.append(corner)
			visibility_polygon.append(line[1])
	return visibility_polygon

static func generate_visible_areas(
	observers,
	polygons,
	dim_x,
	dim_y
):
	var adjusted_polygons = VisibilityHelper.adjust_polygons(
		polygons,
		dim_x,
		dim_y
	)
	
	var areas = []
	
	for observer in observers:
		var inside_area = VisibilityHelper.in_area(
			observer,
			dim_x,
			dim_y
		)
		if not inside_area:
			areas.append([])
			continue
			
		var pairs = get_visible_corners_for_observer(
			adjusted_polygons,
			observer
		)
		
		var area = gernerate_visible_area(
			observer,
			adjusted_polygons,
			pairs,
			dim_x,
			dim_y
		)
		areas.append(area)
	return areas
	
static func generate_view_line(
	observer: Vector2,
	point: Vector2,
	dim_x,
	dim_y
):
	#If Borderpoint no view line should be generated
	if point.x == dim_x or point.x == 0:
		return []
	if point.y == dim_y or point.y == 0:
		return []
	
	var dir = observer.direction_to(point)
	var border_point: Vector2

	# Handle cases where direction is strictly horizontal or vertical
	if dir.x == 0:  # Vertical line
		if dir.y > 0:
			return [point, Vector2(point.x, dim_y)]
		elif dir.y < 0:
			return [point, Vector2(point.x, 0)]
	
	if dir.y == 0:  # Horizontal line
		if dir.x > 0:
			return [point, Vector2(dim_x, point.y)]
		elif dir.x < 0:
			return [point, Vector2(0, point.y)]

	# General cases where dir.x != 0 and dir.y != 0
	var factor_x = INF
	var factor_y = INF

	if dir.x > 0:
		factor_x = (dim_x - point.x) / dir.x
	elif dir.x < 0:
		factor_x = -point.x / dir.x

	if dir.y > 0:
		factor_y = (dim_y - point.y) / dir.y
	elif dir.y < 0:
		factor_y = -point.y / dir.y

	# Choose the smaller factor to find the first intersection
	if factor_x < factor_y:
		border_point = point + dir * factor_x
	else:
		border_point = point + dir * factor_y

	return [point, border_point]
	
static func adjust_line(line, polygon):
	var size = polygon.size()
	var in_polygon = false
	for i in size:
		var next_i = (i + 1) % size
		var p1 = polygon[i]
		var p2 = polygon[next_i]
		if p1.x == line[0].x and p1.y == line[0].y:
			in_polygon = true
			continue
		if p2.x == line[0].x and p2.y == line[0].y:
			in_polygon = true
			continue
		if GeometryUtils.intersection_exists(
			line[0],
			line[1],
			p1,
			p2
		):
			var intersection = GeometryUtils.get_intersection(
				p1,
				p2 - p1,
				line[0],
				line[1] - line[0]
			)
			line = [line[0], intersection]
	if in_polygon:
		var mid_point = (line[0] + line[1])/2
		var inside = PolygonUtils.in_polygon(
			polygon,
			mid_point
		)
		if inside:
			return []
	return line
	

static func adjust_polygons(
	polygons: Array,
	dim_x,
	dim_y
):
	var adjusted_polygons = []
	for polygon in polygons:
		adjusted_polygons.append_array(
			adjust_polygon(
				polygon,
				dim_x,
				dim_y
			)
		)
	return adjusted_polygons
		

static func intersect_polygon_two_times(
	adjusted_polygon: Array,
	observer,
	point
):
	var nr_intersections = 0
	var size = adjusted_polygon.size()
	var limit = 2
	if point in adjusted_polygon:
		limit = 3
	for i in size:
		var p1 = adjusted_polygon[i]
		var p2 = adjusted_polygon[(i+1) % size]
		var exist = GeometryUtils.intersection_exists(p1, p2, observer, point)
		if exist:
			nr_intersections += 1
		if nr_intersections == limit:
			return true
	return false
		
			
static func get_visible_corners_for_observer(
	adjusted_polygons: Array,
	observer: Vector2
):
	var visibile_corners = []
	var corner_rotations = []
	for polygon in adjusted_polygons:
		var corner_pair = get_visible_corners_from_polygon(
			polygon,
			adjusted_polygons,
			observer
		)
		var corners = corner_pair["visible_corners"]
		var corner_rotation = corner_pair["corner_rotation_clock_wise"]
		visibile_corners.append_array(
			corners
		)
		corner_rotations.append_array(
			corner_rotation
		)
	return {
		"visible_corners": visibile_corners,
		"corner_rotations": corner_rotations
	}

static func get_visible_corners_from_polygon(
	polygon,
	adjusted_polygons,
	observer : Vector2
):
	var visibile_corners = []
	var corner_left_wise_rotated = []
	for i in polygon.size():
		var point = polygon[i]		
		var visible = true
		for p in adjusted_polygons:
			if intersect_polygon_two_times(
				p,
				observer,
				point
			):
				visible = false
		if visible:
			visibile_corners.append(point)
			var dir: Vector2 = (point - observer).normalized()
			dir.rotated(PI/2)
			var next_point = polygon[(i+1) % polygon.size()]
			var left_wise_rotated = dir.dot(point- next_point) < 0
			corner_left_wise_rotated.append(left_wise_rotated)
			
	return { 
		"visible_corners": visibile_corners,
		"corner_rotation_clock_wise": corner_left_wise_rotated
	}

# Helper: Check if two polygons are exactly equal (vertex‐by‐vertex).
static func are_polygons_equal(poly1: Array, poly2: Array) -> bool:
	if poly1.size() != poly2.size():
		return false
	for i in range(poly1.size()):
		if poly1[i] != poly2[i]:
			return false
	return true

"""
# Remove duplicate polygons from the input list.
static func deduplicate_polygons(polygons: Array) -> Array:
	var unique_polys = []
	for poly in polygons:
		var duplicate = false
		for upoly in unique_polys:
			if VisibilityHelper.are_polygons_equal(poly, upoly):
				duplicate = true
				break
		if not duplicate:
			unique_polys.append(poly)
	return unique_polys
"""

# Optional: Ensure that a polygon has a consistent (counterclockwise) winding.
static func ensure_polygon_winding(poly: Array) -> Array:
	var area = 0.0
	var n = poly.size()
	for i in range(n):
		var p1 = poly[i]
		var p2 = poly[(i + 1) % n]
		area += p1.x * p2.y - p2.x * p1.y
	# If the area is negative, reverse the order.
	if area < 0:
		var poly_reversed = poly.duplicate()
		poly_reversed.reverse()
		return poly_reversed
	return poly

# Liang-Barsky clipping: clips a segment (p1 to p2) to the rectangle (0,0)-(dim_x, dim_y).
static func clip_segment_to_rect(p1: Vector2, p2: Vector2, dim_x: float, dim_y: float) -> Variant:
	var x_min = 0.0
	var y_min = 0.0
	var x_max = dim_x
	var y_max = dim_y
	
	var dx = p2.x - p1.x
	var dy = p2.y - p1.y
	var t0 = 0.0
	var t1 = 1.0
	var p_val: float
	var q_val: float
	var r: float

	# Left boundary: x >= x_min
	p_val = -dx
	q_val = p1.x - x_min
	if abs(p_val) < 1e-6:
		if q_val < 0:
			return null
	else:
		r = q_val / p_val
		if p_val < 0:
			t0 = max(t0, r)
		else:
			t1 = min(t1, r)
	
	# Right boundary: x <= x_max
	p_val = dx
	q_val = x_max - p1.x
	if abs(p_val) < 1e-6:
		if q_val < 0:
			return null
	else:
		r = q_val / p_val
		if p_val < 0:
			t0 = max(t0, r)
		else:
			t1 = min(t1, r)
	
	# Bottom boundary: y >= y_min
	p_val = -dy
	q_val = p1.y - y_min
	if abs(p_val) < 1e-6:
		if q_val < 0:
			return null
	else:
		r = q_val / p_val
		if p_val < 0:
			t0 = max(t0, r)
		else:
			t1 = min(t1, r)
	
	# Top boundary: y <= y_max
	p_val = dy
	q_val = y_max - p1.y
	if abs(p_val) < 1e-6:
		if q_val < 0:
			return null
	else:
		r = q_val / p_val
		if p_val < 0:
			t0 = max(t0, r)
		else:
			t1 = min(t1, r)
	
	if t0 > t1:
		return null
	var new_p1 = p1 + t0 * (p2 - p1)
	var new_p2 = p1 + t1 * (p2 - p1)
	return [new_p1, new_p2]

# Compute the intersection between a ray (origin, angle) and a segment.
# Returns an array: [intersection_point (Vector2), t] or null if no valid intersection.
static func get_intersection(ray_origin: Vector2, ray_angle: float, segment: Array) -> Variant:
	var rx = ray_origin.x
	var ry = ray_origin.y
	var dx = cos(ray_angle)
	var dy = sin(ray_angle)
	
	var p1: Vector2 = segment[0]
	var p2: Vector2 = segment[1]
	var seg_dx = p2.x - p1.x
	var seg_dy = p2.y - p1.y
	
	var denom = dx * seg_dy - dy * seg_dx
	if abs(denom) < 1e-6:
		return null

	var t = ((p1.x - rx) * seg_dy - (p1.y - ry) * seg_dx) / denom
	var u = ((p1.x - rx) * dy - (p1.y - ry) * dx) / denom

	if t < 0 or u < 0 or u > 1:
		return null

	var ix = rx + t * dx
	var iy = ry + t * dy
	return [Vector2(ix, iy), t]

# Sorting helper: sort intersections by their ray angle.
static func compare_intersections(a, b) -> int:
	if a[0] < b[0]:
		return -1
	elif a[0] > b[0]:
		return 1
	return 0
