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
		if clockwise_rotation(polygon):
			polygon.reverse()
		clockwise_polygons.append(polygon)
	
	return clockwise_polygons	
	
static func find_polygon_idx_by_wall(polygons: Array, p1: Vector2, p2: Vector2, current_idx: int):
	for i in polygons.size():
		if i == current_idx:
			continue
		var polygon = polygons[i]
		for j in polygon.size():
			var p1_ = polygon[j]
			var p2_ = polygon[(j+1) % polygon.size()]
			if p1_ == p1 and p2_ == p2:
				return i
			if p1_ == p2 and p2_ == p1:
				return i
	return null

static func generate_polygon_neighbour_dict(polygons: Array):
	var polygon_idx_to_wall_idx_to_polygon_idx = {}
	for i in polygons.size():
		var polygon = polygons[i]
		polygon_idx_to_wall_idx_to_polygon_idx[i] = {}
		for j in polygon.size():
			var p1 = polygon[j]
			var p2 = polygon[(j+1) %  polygon.size()]
			var found_idx = find_polygon_idx_by_wall(
				polygons,
				p1,
				p2,
				i
			)
			polygon_idx_to_wall_idx_to_polygon_idx[i][j] = found_idx
	return polygon_idx_to_wall_idx_to_polygon_idx
	
static func find_polygons_by_corner(
	polygons: Array,
	corner: Vector2,
	current_index
):
	var found_polys = []
	for i in polygons.size():
		if i == current_index:
			continue
		if corner in polygons[i]:
			found_polys.append(i)
	return found_polys
		
	
static func generate_polygon_corner_neighbour_dict(polygons: Array):
	var polygon_idx_to_corner_to_polygons = {}
	for i in polygons.size():
		var polygon = polygons[i]
		polygon_idx_to_corner_to_polygons[i] = {}
		for j in polygon.size():
			if j == i:
				continue
			var p = polygon[j]
			if p in polygons[j]:
				polygon
			var found_polys = find_polygons_by_corner(
				polygons,
				p,
				i
			)
			polygon_idx_to_corner_to_polygons[i][j] = found_polys
	return polygon_idx_to_corner_to_polygons
	
static func pos_to_corner_neighbours(
		pos :Vector2,
		polygon_idx,
		polygons,
		polygon_idx_to_corner_to_polygons
	):
	# This function has the purpose to let agent not only
	# travel over borders to other regions, but also over corners
	# if close enough
	var polygon = polygons[polygon_idx]
	for i in polygon.size():
		var corner = polygon[i]
		if corner.distance_to(pos) < 5:
			if i in polygon_idx_to_corner_to_polygons[polygon_idx]:
				return polygon_idx_to_corner_to_polygons[polygon_idx][i]
	return []

	
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
		if polygon[i].distance_to(point) < 0.0001:
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
			minimum = y
	
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
	var inner_segment = polygon.slice(lowest_index, polygon.size()) + polygon.slice(0, lowest_index +1)
	inner_segment.reverse()
	new_area += inner_segment
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
	
	for polygon in polygons:
		if intersects_area(polygon, width, height):
			allowed_area = reshape_area(allowed_area, polygon, width, height)
	for polygon in polygons:
		if not intersects_area(polygon, width, height):
			allowed_area = add_poylgon_inside_area(allowed_area, polygon)
	return allowed_area
	
static func empty_triangle(triangle: Array, polygon: Array):
	for point in polygon:
		if point in triangle:
			continue
		if in_polygon(triangle, point):
			return false
	return true
	
static func triangulate_polygon(polygon: Array):
	var found_triangles = []
	var idx = 0
	while len(polygon) > 2:
		var size = polygon.size()
		var triangle = [polygon[idx % size], polygon[(idx + 1) % size], polygon[(idx + 2) % size]]
		if not clockwise_rotation(triangle) and empty_triangle(triangle, polygon):
			found_triangles.append(triangle)
			polygon.pop_at((idx + 1) % size)
			continue
		
		idx += 1
	
	return found_triangles

static func is_convex_polygon(polygon: Array):
	for i in polygon.size():
		var size = polygon.size()
		var p1 = polygon[i]
		var p2 = polygon[(i+1) % size]
		var p3 = polygon[(i+2) % size]
		if clockwise_rotation([p1, p2, p3]):
			return false
	return true

static func add_triangle_to_poylgon(polygon: Array, triangle: Array):
	var new_polygon = polygon.duplicate()
	var size = polygon.size()
	for i in range(size):
		if new_polygon[i] in triangle and new_polygon[(i+1) % size] in triangle:
			if not triangle[0] in new_polygon:
				new_polygon.insert((i+1) % size, triangle[0])
				break
			if not triangle[1] in new_polygon:
				new_polygon.insert((i+1) % size, triangle[1])
				break
			if not triangle[2] in new_polygon:
				new_polygon.insert((i+1) % size, triangle[2])
				break
	return new_polygon

static func  allowed_area_splitted_convex(
		polyogons : Array,
		width,
		height
	):
		polyogons = order_clockwise(polyogons)
		var allowed_area = extract_allowed_area(
			polyogons,
			width,
			height
		)
		#return [allowed_area]
		
		var triangles = triangulate_polygon(allowed_area)
		
		
		var convex_polygons = []
		
		var recent_polygon = triangles.pop_front()
		var latest_triangle = recent_polygon
		
		while triangles:
			for i in triangles.size():
				var nr_common_points = 0
				var triangle = triangles[i] 
				if triangle[0] in latest_triangle:
					nr_common_points += 1
				if triangle[1] in latest_triangle:
					nr_common_points += 1
				if triangle[2] in latest_triangle:
					nr_common_points += 1
				if nr_common_points == 2:
					triangles.pop_at(i)
					var polygon_candidate = add_triangle_to_poylgon(
						recent_polygon,
						triangle
					)
					if is_convex_polygon(polygon_candidate):
						recent_polygon = polygon_candidate
						latest_triangle = triangle
					else:
						convex_polygons.append(recent_polygon)
						recent_polygon = triangle
						latest_triangle = triangle
					break
			convex_polygons.append(recent_polygon)
			recent_polygon = triangles.pop_front()
			latest_triangle = recent_polygon
		
		if not recent_polygon in convex_polygons:
			convex_polygons.append(recent_polygon)			
		
		return convex_polygons
					
					
			 

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
