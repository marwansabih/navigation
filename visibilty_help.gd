class_name VisibilityAreaGenerator
extends Node




#─────────────────────────────────────────────#
#                CLIPPING HELPERS             #
#─────────────────────────────────────────────#

## Returns the intersection point between a line segment (p1->p2) and the box boundaries.
## The box is defined from (0,0) to (dim_x, dim_y). It assumes one of the points is inside.
static func get_box_line_intersection(p1: Vector2, p2: Vector2, dim_x: float, dim_y: float) -> Vector2:
	# Ensure p1 is inside the box.
	if not (p1.x >= 0 and p1.x <= dim_x and p1.y >= 0 and p1.y <= dim_y):
		var temp = p1
		p1 = p2
		p2 = temp
	
	var direction = p2 - p1
	var t: float = 0.0
	
	# Check against the left boundary (x = 0)
	if direction.x != 0:
		t = (0 - p1.x) / direction.x
		if t > 0 and t <= 1:
			var y_val = p1.y + t * direction.y
			if y_val >= 0 and y_val <= dim_y:
				return p1 + t * direction
				
	# Check against the right boundary (x = dim_x)
	if direction.x != 0:
		t = (dim_x - p1.x) / direction.x
		if t > 0 and t <= 1:
			var y_val = p1.y + t * direction.y
			if y_val >= 0 and y_val <= dim_y:
				return p1 + t * direction
				
	# Check against the top boundary (y = dim_y)
	if direction.y != 0:
		t = (dim_y - p1.y) / direction.y
		if t > 0 and t <= 1:
			var x_val = p1.x + t * direction.x
			if x_val >= 0 and x_val <= dim_x:
				return p1 + t * direction
				
	# Check against the bottom boundary (y = 0)
	if direction.y != 0:
		t = (0 - p1.y) / direction.y
		if t > 0 and t <= 1:
			var x_val = p1.x + t * direction.x
			if x_val >= 0 and x_val <= dim_x:
				return p1 + t * direction
	
	# Fallback: return a default point (should not occur with valid inputs)
	return Vector2(0, 0)

## Returns true if the point is strictly inside the box (excluding boundaries).
static func in_area(point: Vector2, dim_x: float, dim_y: float) -> bool:
	return (point.x > 0 and point.x < dim_x and point.y > 0 and point.y < dim_y)

## Starting at a given index, collects the contiguous segment of polygon vertices that lie inside the box.
## The segment ends with the first intersection point.
static func get_polygon_part(polygon: Array, dim_x: float, dim_y: float, idx: int) -> Array:
	var part = []
	var last_idx = idx
	while in_area(polygon[idx], dim_x, dim_y):
		part.append(polygon[idx])
		last_idx = idx
		idx = (idx + 1) % polygon.size()
	var intersection = get_box_line_intersection(polygon[last_idx], polygon[idx], dim_x, dim_y)
	return part + [intersection]

## Adjusts a polygon by “cutting” out the parts that lie outside the box.
## Returns an array of polygon parts (each a valid inside segment).
static func adjust_polygon(polygon: Array, dim_x: float, dim_y: float) -> Array:
	var inside_polys = []
	var found_intersection = false
	for i in range(polygon.size()):
		var p1 = polygon[i]
		var p2 = polygon[(i + 1) % polygon.size()]
		if not in_area(p1, dim_x, dim_y) and in_area(p2, dim_x, dim_y):
			found_intersection = true
			var intersection = get_box_line_intersection(p1, p2, dim_x, dim_y)
			var part = get_polygon_part(polygon, dim_x, dim_y, (i + 1) % polygon.size())
			inside_polys.append([intersection] + part)
	if not found_intersection:
		inside_polys.append(polygon)
	return inside_polys

## Processes a list of obstacle polygons and adjusts them to lie within the box.
static func adjust_polygons(polygons: Array, dim_x: float, dim_y: float) -> Array:
	var adjusted = []
	for poly in polygons:
		adjusted.append_array(adjust_polygon(poly, dim_x, dim_y))
	return adjusted

#─────────────────────────────────────────────#
#             VIEW LINE GENERATION            #
#─────────────────────────────────────────────#

## Generates a view line for a given visible corner.
## The line extends from the corner toward the scene boundary (away from the observer).
static func generate_view_line(observer: Vector2, point: Vector2, dim_x: float, dim_y: float) -> Array:
	# Do not generate a line if the corner lies on the boundary.
	if point.x == 0 or point.x == dim_x or point.y == 0 or point.y == dim_y:
		return []
	
	var direction = observer.direction_to(point)
	var border_point: Vector2
	
	# Handle vertical directions
	if direction.x == 0:
		if direction.y > 0:
			return [point, Vector2(point.x, dim_y)]
		elif direction.y < 0:
			return [point, Vector2(point.x, 0)]
	# Handle horizontal directions
	if direction.y == 0:
		if direction.x > 0:
			return [point, Vector2(dim_x, point.y)]
		elif direction.x < 0:
			return [point, Vector2(0, point.y)]
	
	# For general directions, compute intersection factors.
	var factor_x = INF
	var factor_y = INF
	if direction.x > 0:
		factor_x = (dim_x - point.x) / direction.x
	elif direction.x < 0:
		factor_x = -point.x / direction.x
	
	if direction.y > 0:
		factor_y = (dim_y - point.y) / direction.y
	elif direction.y < 0:
		factor_y = -point.y / direction.y
	
	# Choose the closer intersection.
	if factor_x < factor_y:
		border_point = point + direction * factor_x
	else:
		border_point = point + direction * factor_y
	
	return [point, border_point]

## Adjusts a view line by clipping it against an obstacle polygon.
## Uses external GeometryUtils and PolygonUtils (ensure these are defined in your project).
static func adjust_line(line: Array, polygon: Array) -> Array:
	var poly_size = polygon.size()
	var line_starts_in_poly = false
	for i in range(poly_size):
		var next_i = (i + 1) % poly_size
		var p1 = polygon[i]
		var p2 = polygon[next_i]
		# If the line's starting point is a vertex of the polygon, mark it.
		if p1 == line[0] or p2 == line[0]:
			line_starts_in_poly = true
			continue
		# If the line intersects an edge, update the line to end at the intersection.
		if GeometryUtils.intersection_exists(line[0], line[1], p1, p2):
			var intersection = GeometryUtils.get_intersection(p1, p2 - p1, line[0], line[1] - line[0])
			line = [line[0], intersection]
	if line_starts_in_poly:
		var mid_point = (line[0] + line[1]) / 2
		if PolygonUtils.in_polygon(polygon, mid_point):
			return []  # Discard line if it lies inside the polygon.
	return line

## For each visible corner, generate and adjust its view line against all obstacle polygons.
static func generate_view_lines(observer: Vector2, adjusted_polygons: Array, visible_corners: Array, dim_x: float, dim_y: float) -> Array:
	var lines = []
	# First, generate raw view lines.
	for corner in visible_corners:
		lines.append(generate_view_line(observer, corner, dim_x, dim_y))
	
	# Then, adjust each line against every obstacle.
	var adjusted_lines = []
	for line in lines:
		var new_line = line
		for polygon in adjusted_polygons:
			if not new_line:
				break
			new_line = adjust_line(new_line, polygon)
		adjusted_lines.append(new_line)
	
	return adjusted_lines

#─────────────────────────────────────────────#
#         VISIBLE CORNER GENERATION           #
#─────────────────────────────────────────────#

## Checks if a ray from the observer to a point intersects an obstacle polygon the required number of times.
## If the point is a vertex of the polygon, a limit of 3 intersections is used; otherwise, 2.
static func intersect_polygon_two_times(adjusted_polygon: Array, observer: Vector2, point: Vector2) -> bool:
	var count = 0
	var limit = 3 if point in adjusted_polygon else 2
	for i in range(adjusted_polygon.size()):
		var p1 = adjusted_polygon[i]
		var p2 = adjusted_polygon[(i + 1) % adjusted_polygon.size()]
		if GeometryUtils.intersection_exists(p1, p2, observer, point):
			count += 1
		if count == limit:
			return true
	return false

## For a given obstacle polygon, returns visible vertices and a rotation flag for each.
## The rotation flag (boolean) helps determine the ordering of points later.
static func get_visible_corners_from_polygon(polygon: Array, adjusted_polygons: Array, observer: Vector2) -> Dictionary:
	var visible_corners = []
	var corner_rotations = []
	for i in range(polygon.size()):
		var point = polygon[i]
		var visible = true
		for other_poly in adjusted_polygons:
			if intersect_polygon_two_times(other_poly, observer, point):
				visible = false
				break
		if visible:
			visible_corners.append(point)
			# Calculate a rotation flag based on the vector between the point and its neighbor.
			var dir: Vector2 = (point - observer).normalized()
			dir = dir.rotated(PI / 2)
			var next_point = polygon[(i + 1) % polygon.size()]
			var left_wise_rotated = dir.dot(point - next_point) < 0
			corner_rotations.append(left_wise_rotated)
	return {
		"visible_corners": visible_corners,
		"corner_rotations": corner_rotations
	}

## Combines visible corners from all obstacle polygons into one dictionary.
static func get_visible_corners_for_observer(adjusted_polygons: Array, observer: Vector2, dim_x: float, dim_y: float) -> Dictionary:
	var all_corners = []
	var all_rotations = []
	for polygon in adjusted_polygons:
		var result = get_visible_corners_from_polygon(polygon, adjusted_polygons, observer)
		all_corners.append_array(result["visible_corners"])
		all_rotations.append_array(result["corner_rotations"])
	return {
		"visible_corners": all_corners,
		"corner_rotations": all_rotations
	}

#─────────────────────────────────────────────#
#          VISIBILITY POLYGON GENERATION      #
#─────────────────────────────────────────────#

## Helper function to sort entries by angle.
static func sort_by_angle(a, b) -> bool:
	return a[1] < b[1]

## Generates the final visibility polygon for the observer.
## Parameters:
##   - observer: The observer's position.
##   - adjusted_polygons: A list of obstacle polygons adjusted to lie within the scene.
##   - visible_corner_pairs: A dictionary with keys "visible_corners" and "corner_rotations".
##   - dim_x, dim_y: The scene dimensions.
static func generate_visible_area(observer: Vector2, adjusted_polygons: Array, visible_corner_pairs: Dictionary, dim_x: float, dim_y: float) -> Array:
	# Combine each visible corner with its computed angle and rotation flag.
	var corner_data = []
	for i in range(visible_corner_pairs["visible_corners"].size()):
		var corner = visible_corner_pairs["visible_corners"][i]
		var rotation = visible_corner_pairs["corner_rotations"][i]
		var angle = observer.angle_to_point(corner)
		corner_data.append([corner, angle, rotation])
	
	# Sort the corners by their angle relative to the observer.
	corner_data.sort_custom(VisibilityAreaGenerator.sort_by_angle)
	
	# Separate the sorted corners and their rotation flags.
	var sorted_corners = []
	var rotations = []
	for data in corner_data:
		sorted_corners.append(data[0])
		rotations.append(data[2])
	
	# Generate view lines for each sorted corner.
	var view_lines = generate_view_lines(observer, adjusted_polygons, sorted_corners, dim_x, dim_y)
	var visibility_polygon = []
	
	# Construct the final polygon by combining corners with their view line endpoints.
	for i in range(view_lines.size()):
		var corner = sorted_corners[i]
		var rotation = rotations[i]
		var line = view_lines[i]
		if not line:
			visibility_polygon.append(corner)
		else:
			# Use the rotation flag to determine the order of points.
			if not rotation:
				visibility_polygon.append(line[1])
				visibility_polygon.append(corner)
			else:
				visibility_polygon.append(corner)
				visibility_polygon.append(line[1])
	return visibility_polygon

#─────────────────────────────────────────────#
#          MULTIPLE OBSERVERS HANDLER         #
#─────────────────────────────────────────────#

## Generates visible areas for multiple observers.
## Parameters:
##   - observers: An array of Vector2 positions for the observers.
##   - polygons: An array of obstacle polygons (unadjusted).
##   - dim_x, dim_y: Scene dimensions.
## Returns:
##   An array of visible area polygons, in the same order as the observers.
##   If an observer is outside the allowed area, an empty polygon ([]) is added.
static func generate_visible_areas(observers: Array, polygons: Array, dim_x: float, dim_y: float) -> Array:
	var visible_areas = []
	# Adjust the polygons once.
	var adjusted_polys = adjust_polygons(polygons, dim_x, dim_y)
	
	for observer in observers:
		# Check if the observer is inside the allowed area.
		if not in_area(observer, dim_x, dim_y):
			visible_areas.append([])  # Add empty polygon if outside.
		else:
			# Get visible corners for the observer.
			var visible_corner_pairs = get_visible_corners_for_observer(adjusted_polys, observer, dim_x, dim_y)
			# Generate the visibility polygon.
			var area_polygon = generate_visible_area(observer, adjusted_polys, visible_corner_pairs, dim_x, dim_y)
			visible_areas.append(area_polygon)
	
	return visible_areas
