extends Node

class_name PolygonUtils

static func clockwise_rotation(polygon):
	var sum = 0
	for i in range(polygon.size()):
		var p1 = polygon[i]
		var p2 = polygon[(i+1)% polygon.size()]
		sum += (p2.x - p1.x) * (p2.y + p1.y)
	return sum < 0
	
static func order_clockwise(polygons):
	var clockwise_polygons = []
	
	for polygon in polygons:
		if not clockwise_rotation(polygon):
			polygon.reverse()
		clockwise_polygons.append(polygon)
	
	return clockwise_polygons	
	
static func start_from_lowest_point(polygon: Array):
	var lowest_point_index = 0
	var size = polygon.size()
	for i in size:
		if polygon[i].y < polygon[lowest_point_index].y :
			lowest_point_index = i
			
	var end = polygon.slice(0, lowest_point_index)
	return polygon.slice(lowest_point_index, size) + end
	
	
static func intersects_area(polygon, width, height):
	var min_y = INF
	var max_y = -INF
	var min_x = INF
	var max_x = -INF
	
	for point in polygon:
		var x = point.x
		var y = point.y
		if x <= 0 or x >= width:
			return true
		if y <= 0 or y >= height:
			return true
	return false
	

static func point_in_area(point: Vector2, width, height):
	if point.x < 0 or point.x > width:
		return false
	if point.y < 0 or point.y > height:
		return false
	return true
	
static func rotate_positions(polygon: Array):
	var front = polygon.pop_front()
	return polygon + [front]
	
static func get_line_segement(polygon: Array, start_idx, end_idx):
	if start_idx > end_idx:
		var start_segment = polygon.slice(start_idx, polygon.size())
		var end_segment = polygon.slice(0, end_idx +1 )
		return start_segment + end_segment
	return polygon.slice(start_idx, end_idx +1)
	
static func in_polygon(
	polygon,
	point : Vector2
):
	# using angle test
	var angle_sum = 0
	
	for i in polygon.size():
		var angle = (polygon[i] - point).angle_to(polygon[(i+1) % polygon.size()] - point)
		angle_sum += angle
		if abs(abs(angle) -PI) < 0.001:
			return true
	if abs(angle_sum) > 0.1:
		return true
	return false
	
static func get_area_path_between_intersections(
	area: Array,
	intersection: Vector2,
	next_intersection: Vector2,
	start_idx,
	end_index
):
	print("blog start")
	print("start id")
	print(start_idx)
	print(end_index)
	print(intersection)
	print(next_intersection)
	print("blog end")
	var before_intersection : Vector2 = area[start_idx]
	#if end_index < start_idx:
	#	var swap = start_idx
	#	start_idx = end_index
	#	end_index = swap
	if start_idx == end_index:
		var start_distance = before_intersection.distance_to(intersection)
		var end_distance = before_intersection.distance_to(next_intersection)
		if start_distance < end_distance:
			return [intersection, next_intersection]
		else:
			var segement = area.slice((start_idx + 1) % area.size(), area.size())
			var segment_2 = area.slice(0, (end_index + 1) % area.size())
			return [intersection] + segement + segment_2 + [next_intersection]
	if end_index < start_idx:
		var segement = area.slice(start_idx + 1 , area.size())
		var segment_2 = area.slice(0, (end_index + 1) % area.size())
		print(segement)
		print(segment_2)
		return [intersection] + segement + segment_2 + [next_intersection]
	return [intersection] + area.slice(start_idx + 1, end_index + 1) + [next_intersection]
	
	
static func get_polygon_path_between_intersections(
	polygon,
	start_idx,
	end_idx,
	area
):
	var poly_size = polygon.size()
	var path = polygon.slice((start_idx+1) % poly_size, end_idx +1)
	var start = polygon[(start_idx+1) % poly_size]
	var end = polygon[end_idx]

	if not in_polygon(area, polygon[start_idx]):
		start_idx = (start_idx + 1) % poly_size
	
	if not in_polygon(area, polygon[end_idx]):
		end_idx = (end_idx + 1 ) % poly_size
	
	var segment = []
	var found = true
	
	var s = start_idx
	
	while s != (end_idx + 1) % poly_size:
		if not in_polygon(area, polygon[s]):
			found = false
			break  
		segment.append(polygon[s])
		s = (s + 1) % poly_size
	
	if found and segment:
		return segment
	
	found = true
	
	segment = []
	s = start_idx
	while s !=  (end_idx + poly_size - 1) % poly_size:
		if not in_polygon(area, polygon[s]):
			found = false
			break  
		segment.append(polygon[s])
		s = (s - 1) % poly_size
		if s == -1:
			s = poly_size-1
	
	if not found:
		return []
	
	return segment
	
	
	if end_idx < start_idx:
		end_idx 
	if end_idx < start_idx:
		var segment_1 = polygon.slice((start_idx+1) % poly_size, poly_size)
		var segment_2 = polygon.slice(0, end_idx + 1)
		return segment_1
		#return segment_1 + segment_2
	var checkpoint = path[0] 
	if path.size() > 1 :
		checkpoint = (path[1] - path[0])/2.0
	if in_polygon(area, checkpoint):
		return path
	return path
	
static func reshape_area(area: Array, polygon: Array, width, height):
	var wall_intersections = []
	var polygon_intersections = []
	var intersection_points = []
	for i in area.size():
		for j in polygon.size():
			var next_i = (i + 1) % area.size()
			var next_j = (j + 1) % polygon.size()
			var wall = [area[i], area[next_i]]
			var p_wall = [polygon[j], polygon[next_j]]
			var dir_wall = (wall[1] - wall[0]).normalized()
			var dir_p_wall = (p_wall[1] - p_wall[0]).normalized()
			
			var intersection = GeometryUtils.get_intersection(
				wall[0],
				dir_wall,
				p_wall[0],
				dir_p_wall
			)
			if intersection == null:
				continue
			if (intersection - wall[0]).length() > (wall[1] - wall[0]).length():
				continue
			if (intersection - p_wall[0]).length() > (p_wall[1] - p_wall[0]).length():
				continue
			if (intersection - wall[0]).dot(wall[1] - wall[0]) < 0:
				continue
			if (intersection - p_wall[0]).dot(p_wall[1] - p_wall[0]) < 0:
				continue
				
			wall_intersections.append(i)
			polygon_intersections.append(j)
			intersection_points.append(intersection)
	
	
	var start_idx_polygon = polygon_intersections[0] + 1
	var new_area = []
	
	for i in polygon_intersections.size():
		var intersection = intersection_points[i]
		var next_intersection = intersection_points[(i+1) % intersection_points.size()]
		var area_index = wall_intersections[i]
		var next_area_index = wall_intersections[(i+1)% wall_intersections.size()]
		var follow_area_path = true
		
		var intersection_path = get_area_path_between_intersections(
			area,
			intersection,
			next_intersection,
			area_index,
			next_area_index
		)
		
		var p1 = intersection_path[0]
		var p2 = intersection_path[1]
		
		var check_point = (p2 + p1)/2
		
		if in_polygon(polygon, check_point):
			var start_idx = polygon_intersections[i]
			var end_idx = polygon_intersections[(i+1) % polygon_intersections.size()]
			var polygon_path = get_polygon_path_between_intersections(
				polygon,
				start_idx,
				end_idx,
				area
			) 
			new_area += polygon_path 
			continue
			
		new_area += intersection_path
			
	
	return new_area		
		
static func add_poylgon_inside_area(area: Array, polygon: Array):
	var lowest_index = 0
	var minimum = INF
	
	for i in polygon.size():
		var y = polygon[i].y
		if y < minimum:
			lowest_index = i
	
	var x_min = polygon[lowest_index].x
	var y_min = polygon[lowest_index].y
	
	var found_intersection = Vector2(-INF, -INF)
	var intersection_idx
	
	# all intersections must lie below the lowest point
	for i in range(area.size()):
		var p1 = area[i]
		var p2 = area[(i+1) % area.size()]
		var left = min(p1.x, p2.x)
		var right = max(p1.x, p2.x)
		if not (left <= x_min and x_min <= right):
			continue
		var y_intersection = (x_min - p1.x)/ (p2.x - p1.x) * (p2.y - p1.y) + p1.y
		if y_intersection > y_min:
			continue
		if y_intersection > found_intersection.y:
			found_intersection = Vector2(x_min, y_intersection)
			intersection_idx = i
			print("HERE")
		
	var new_area =  area.slice(0, intersection_idx + 1) 
	new_area += [found_intersection]
	new_area += polygon.slice(lowest_index, polygon.size()) + polygon.slice(0, lowest_index + 1)
	new_area += [found_intersection]
	new_area += area.slice(intersection_idx + 1, area.size())
	
	return new_area 
	
		
static func insert_into_area(polygon, area, width, height):
	# If a polygon intersects with area of the border, corresponding parts will be used as new outerline
	# ohterwise two vertical lines from the lowest point of the polygon will be used to exclude the polygon
	# from the area
	
	if intersects_area(polygon, width, height):
		pass
		
static func smallest_y(polygon):
	var smallest = INF
	for p in polygon:
		if p.y < smallest:
			smallest = p.y
	return smallest
	
static func extract_allowed_area(polygons: Array, width, height):
	
	var allowed_area = [
		Vector2(0,0),
		Vector2(0, height),
		Vector2(width, height),
		Vector2(width, 0)
	]
	
	polygons.sort_custom(func(v1, v2): return smallest_y(v1) < smallest_y(v2))
	print(polygons)
	
	for polygon in polygons:
		if intersects_area(polygon, width, height):
			allowed_area = reshape_area(allowed_area, polygon, width, height)
		else:
			allowed_area = add_poylgon_inside_area(allowed_area, polygon)
	return allowed_area
		

static func height_in_between(height, y1, y2):
	var minimum = min(y1, y2)
	var maximum = max(y1, y2)
	if minimum < height and height < maximum:
		return true
	return false

static func split_line_on_height(line: Array, height: float, from_left: bool):
	var intersection = null
	var split_index_above = null
	var split_index_below = null
	
	
	# Determine most left (or right intersection with line
	var factor = 1
	if not from_left:
		factor = - 1
	
	for i in range(line.size()-1):
		var l1 = line[i]
		var l2 = line[i+1]
		var upper_point = l1
		var lower_point = l2
		var upper_index = i
		var lower_index = i+1
		
		if l1.y < l2.y:
			upper_point = l2
			lower_point = l1
		
		if not (lower_point.y <= height and upper_point.y >= height):
			continue
			
		
		var s = (height - lower_point.y)/(upper_point.y - lower_point.y)
		var new_intersection = lower_point + s * (upper_point-lower_point)
		if not intersection or (new_intersection.x < factor * intersection.x):
			split_index_above = i
			split_index_below = i + 1
			intersection = new_intersection
		
	var split_above = line.slice(0, split_index_above+1)
	if height != line[split_index_above].y:
		split_above.append(intersection)
	var split_below = line.slice(split_index_below, line.size())
	if height != line[split_index_below].y:
		split_below.push_front(intersection)
		
	return [split_above, split_below]
	
	

	

static func split_line(line, split_heights):
	pass
	

static func get_indices_heighest_and_loweset_point(polygon):
	var max = -INF
	var min = INF
	var heighest_point
	var lowest_point
	for i in polygon.size():
		var p = polygon[i]
		if p.y > max:
			heighest_point = i
			max = p.y
		if p.y < min:
			lowest_point = i
			min = p.y
	return [heighest_point, lowest_point]
	
func split_polygon(polygon, heighest_index, lowest_index):
	var left_side = []
	var right_side = []
	var heighest_points = []
	var lowest_points = []
	for p in polygon:
		if p.y == polygon[heighest_index].y:
			heighest_points.append(p)
		if p.y == polygon[lowest_index].y: 
			lowest_points.append(p)
			
	heighest_points.sort()
	lowest_points.sort()

static func extract_interior_triangles(polygons, width, height):
	var heighest_points = []
	var lowest_points = []
	for polygon in polygons:
		var ps = get_indices_heighest_and_loweset_point(polygon)
		heighest_points.append(ps[0])
		lowest_points.append(ps[1])
	
	var indices = range(polygons.size())
	
	indices.sort_custom(func(idx_1, idx_2): return polygons[idx_1][heighest_points[idx_1]].y > polygons[idx_2][heighest_points[idx_2]].y)
