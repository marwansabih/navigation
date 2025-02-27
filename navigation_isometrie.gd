extends Node2D

#TODO Fix polygon bug
#TODO Fix bug in large polygon generation (point to check if it's inside lies outside area)

#TODO Try out determine u first and then "use 1/2" to split the work

#TODO contraint by "angle" for movement... instead of "distance" only

#TODO Clean up code

#TODO Make useable as part of a programm

#TODO README

var dim_x = null
var dim_y = null

var mesh_grid_size = 1

var mesh_data : MeshData		

func setup_pos_to_region():
	var pos_to_region = {}
	for i in mesh_data.convex_polygons.size():
		var convex_polygon = mesh_data.convex_polygons[i] 
		for k in range(dim_x):
			for l in range(dim_y):
				var point = Vector2(mesh_grid_size*k, mesh_grid_size*l)
				if PolygonUtils.in_polygon(convex_polygon, point):
					pos_to_region[point] = mesh_data.polygon_regions[i]
	return pos_to_region

func get_edge_point(
	polygon,
	p_point,
	point,
	n_point,
	corner_distance
):
	var dir_1: Vector2 = (p_point - point).normalized()
	var dir_2: Vector2 = (n_point - point).normalized()
	var signum = 1 
	
	var polys = []
	for p in $Poly.get_children():
		polys.append(p.polygon)
	
	var to_b = -(dir_1 - dir_1.dot(dir_2)*dir_2).normalized() * corner_distance
	var to_e =  -(dir_2 - dir_2.dot(dir_1)*dir_1).normalized() * corner_distance
	
	var b: Vector2 = point + to_b
	var e: Vector2 = point + to_e
	
	if inside_polygons(e, polys):
		e = point - to_e 
	if inside_polygons(b, polys):
		b = point - to_b 
	
	var t_1 = - b.x/dir_2.x * dir_2.y + b.y
	var m_1 = dir_2.y/dir_2.x
	var t_2 = - e.x/dir_1.x * dir_1.y + e.y
	var m_2 = dir_1.y/dir_1.x
	var x = (t_2-t_1)/(m_1-m_2)
	var y = m_1*x + t_1
	
	return Vector2(x,y)

func generate_polygon_edges(polygon, corner_distance):
	var p = polygon.polygon
	var size = len(p)
	var p_index = size - 1
	var edge_points = []
	for i in range(size):
		var p_point = p[p_index]
		var n_point = p[(i+1)%size]
		var point = p[i]
		var edge = get_edge_point(
			p,
			p_point,
			point,
			n_point,
			corner_distance
		)
		edge_points.append(edge)
		p_index = i
	return edge_points



func setup_large_polygons():
	var large_polygons = []
	var occupied_polygons = []
	for p in $Poly.get_children():
		var poly = generate_polygon_edges(p, 8)
		large_polygons.append(poly)
		var poly_2 = generate_polygon_edges(p, 19)
		occupied_polygons.append(poly)
		
	occupied_polygons = PolygonUtils.order_clockwise(occupied_polygons)
	large_polygons = PolygonUtils.order_clockwise(large_polygons)
	return [occupied_polygons, large_polygons]
	


func generate_corners():
	var corners = []
	for polygon in $Poly.get_children():
		corners.append_array(generate_polygon_edges(polygon, 19))
	return corners
		
func in_polygons(edge, mesh_data):
	for poly in mesh_data.convex_polygons:
		if PolygonUtils.in_polygon(poly, edge):
			return true
	return false	
		
func intersect_with_occupied_polygons(p,q):
	for polygon in mesh_data.occupied_polygons:
		var dir = (q-p).normalized().rotated(PI/2)
		var critera_1 = GeometryUtils.interset_with_shape(polygon, p + 8 * dir,q + 8 * dir )
		var critera_2 = GeometryUtils.interset_with_shape(polygon, p - 8 * dir,q - 8 * dir )
		if GeometryUtils.interset_with_shape(polygon, p,q) and critera_1 and critera_2:
			return true
	return false


func intersects_with_polys(polies, p, q):
	for poly in polies:
		if GeometryUtils.interset_with_shape(poly, p, q):
			return true
	return false
	
func inside_polygons(p, polygons):
	for polygon in polygons:
		if Geometry2D.is_point_in_polygon(p, polygon):
			return true
	return false

func generate_shadow_polygons(point):
	var shadow_polygons = []
	for polygon in mesh_data.occupied_polygons:
		var size = len(polygon)
		var shadow_polygon = []
		for i in range(size):
			var next_i = (i + 1) % size
			var p = polygon[i]
			var q = polygon[next_i]
			var r = q + (q-point).normalized() * 10000
			var s = p + (p-point).normalized() * 10000
			shadow_polygons.append([p, q, r, s])
	return shadow_polygons
			

func generate_position_to_visible_edges():
	
	var position_to_visible_corner_ids = {}
	
	
	var shadow_polygons = []
	for edge in mesh_data.corners:
		var polys = generate_shadow_polygons(edge)
		shadow_polygons.append(polys)
		
	for i in range(dim_x):
		for j in range(dim_y):
			var visible_edges = []
			var pos = Vector2(i*mesh_grid_size, j*mesh_grid_size)
			for k in range(len(mesh_data.corners)):
				if inside_polygons(pos, shadow_polygons[k]):
					continue
				var c_edge = mesh_data.corners[k]
				var d = (c_edge - pos).normalized().rotated(PI/2)
				
				var criterea_1 = intersect_with_occupied_polygons(pos + d * 9, c_edge + d*9)
				var criterea_2 = intersect_with_occupied_polygons(pos - d * 9, c_edge - d*9)
				var criterea_3 = intersect_with_occupied_polygons(pos, c_edge)
				if not criterea_1 and not criterea_2 and not criterea_3:
					visible_edges.append(k)
				
			position_to_visible_corner_ids[pos] = visible_edges
			
	var position_to_visible_corner_group_id = {}
	var corner_groups = []
	
	for pos in position_to_visible_corner_ids:
		var corners = position_to_visible_corner_ids[pos]
		corners.sort()
		var idx = corner_groups.find(corners, 0)
		if idx == -1:
			position_to_visible_corner_group_id[pos] = len(corner_groups)
			corner_groups.append(corners)
		else:
			position_to_visible_corner_group_id[pos] = idx
	
	return [position_to_visible_corner_group_id, corner_groups]
	

func subdivide_shortest_path(path):
	var new_path = [path[0]]
	for i in range(len(path)-1):
		var p1: Vector2 = new_path.back()
		var p2: Vector2 = path[i+1]
		
		var dist = p1.distance_to(p2)
		var nr_sub_points = max(int(dist/25),1)
		var dir = p1.direction_to(p2).normalized()
		for j in range(nr_sub_points):
			var delta = float(j+1) / float(nr_sub_points) * dist
			new_path.append(p1 + delta * dir)
	return new_path
		
	
		
func shortest_path_between_positions(
	p1: Vector2,
	p2: Vector2
):
	var dir = p2 - p1
	
	var region_idx = -1
	
	var neighbour_idx = -1
	
	for i in mesh_data.convex_polygons.size():
		var p = mesh_data.convex_polygons[i]
		var p1_inside = PolygonUtils.in_polygon(p, p1)
		var p2_inside = PolygonUtils.in_polygon(p, p2)
		if p1_inside:
			region_idx = i
		if p2_inside:
			neighbour_idx = i
		if p1_inside and p2_inside:
			return [p2]
	
	if region_idx == -1:
		mesh_data.polygon_neighbours_dict[region_idx] = []
	for wall_idx in mesh_data.polygon_neighbours_dict[region_idx]:
		if mesh_data.polygon_neighbours_dict[region_idx][wall_idx] == neighbour_idx:
			return [p2]
		
			
	
	#var d = dir.rotated(PI/2).normalized()
	
	#var criterea_1 = intersect_with_occupied_polygons(p1 + d * 12, p2 + d*9)
	#var criterea_2 = intersect_with_occupied_polygons(p1 - d * 12, p2 - d*9)
	#dirty but fast
	var criterea_3 = intersect_with_occupied_polygons(p1, p2)
	
	if not criterea_3:
		return [p2]
	
	#if not criterea_1 and not criterea_2 and not criterea_3:
	#	return [p2]
	
	
	var p1_m = GeometryUtils.get_closest_mesh_position(p1, mesh_grid_size)
	var p2_m = GeometryUtils.get_closest_mesh_position(p2, mesh_grid_size)
	
	var groups = mesh_data.corner_groups
	var pos_to_corner_group_id = mesh_data.position_to_corner_group_id
	
	
	var neigh_1 = mesh_data.corner_groups[
		mesh_data.position_to_corner_group_id[p1_m]
	]
	var neigh_2 = mesh_data.corner_groups[
		mesh_data.position_to_corner_group_id[p2_m]
	]
	
	
	var min_dist = INF
	var edge_1
	var edge_2
	for i in neigh_1:
		var dist_1 = GeometryUtils.isometric_distance(p1_m, mesh_data.corners[i])
		for j in neigh_2:
			var dist_2 = GeometryUtils.isometric_distance(p2_m, mesh_data.corners[j])
			var dist = dist_1 + mesh_data.edges_to_dist[i][j] + dist_2
			
			if dist < min_dist:
				edge_1 = i
				edge_2 = j
				min_dist = dist
	
	if not edge_1 or not edge_2:
		return 
	
	var path = mesh_data.edges_to_path[edge_1][edge_2]
	var s_path = [] #[p1]
	s_path.append_array(path)
	s_path.append(p2)
	#s_path = subdivide_shortest_path(s_path)
	return s_path
	

var fake_character = {
	"velocity" =50,
	"position" = Vector2(8,8),
	"org_dir" = Vector2(0,0),
	"dir" = null,
	"local_path" = null
}

var fake_chars = []
var fake_chars_2 = []

func generate_fake_chars():
	#return
	for i in range(8):
		var char = {
			"velocity" =50,
			"position" = Vector2(16 + 36*i,100),
			"dir" = null,
			"org_dir" = Vector2(0,0),
			"local_path" = null,
			"destination" = null
		}
		fake_chars.append(char)
		#continue
		var char2 = {
			"velocity" =50,
			"position" = Vector2(16 + 36*i,50),
			"dir" = null,
			"org_dir" = Vector2(0,0),
			"local_path" = null,
			"destination" = null
		}
		fake_chars.append(char2)
		
	for i in range(8):
		var char = {
			"velocity" =50,
			"position" = Vector2(516 + 36*i,500),
			"dir" = null,
			"org_dir" = Vector2(0,0),
			"local_path" = null,
			"destination" = null
		}
		fake_chars_2.append(char)
		#continue
		var char_2 = {
			"velocity" =50,
			"position" = Vector2(100 + 36*i,500),
			"dir" = null,
			"org_dir" = Vector2(0,0),
			"local_path" = null,
			"destination" = null
		}
		fake_chars_2.append(char_2)
	

func inisde_polygon(pos):
	for poly in $Poly.get_children():
		if Geometry2D.is_point_in_polygon(pos,poly.polygon):
			return true
	return false
		
var cycle = 0
func move_along_direction(
	character,
	path,
	delta
):
	character["position"] += character["new_velocity"] * delta
	
	if not path:
		character["dir"] = null
		return
	var dir = character["dir"]
	var velocity = character["velocity"]
	var pos = character["position"]
	while path and path[0].distance_to(pos) < 2:
		path.pop_front()
	if path and path[0].distance_to(pos) < 2:
		path.pop_front()
		if not path:
			character["destination"] = null
			character["new_velocity"] = Vector2(0,0)
		if path:
			character["dir"] = pos.direction_to(path[0])
			character["org_dir"] = pos.direction_to(path[0])
			character["new_velocity"] = velocity * character["org_dir"]

func generate_dists(graph):
	var edges_to_dist = {}
	var edges_to_path = {}
	var size = len(mesh_data.corners)
	for i in range(size):
		edges_to_dist[i] = {}
		edges_to_path[i] = {}
		for j in range(size):
			var node = Dijstra.find_shortest_path(graph, graph[i], graph[j])
			edges_to_dist[i][j] = node["distance"]
			edges_to_path[i][j] = node["path"]
	return [edges_to_dist, edges_to_path]

func generate_connections():
	var connections = []
	
	for i in range(len(mesh_data.corners)):
		var line = []
		for j in range(len(mesh_data.corners)):
			if i == j or intersect_with_occupied_polygons(mesh_data.corners[i], mesh_data.corners[j]):
				line.append(false)
			else:
				line.append(true)
		connections.append(line)
	return connections
	
var shortest_paths = []
var shortest_paths_2 = []

func setup_mesh_data():
	
	var rect = $Poly.get_viewport().get_visible_rect().size		
	dim_x = rect.x
	dim_y = rect.y
	
	mesh_data = MeshData.new()
	# gnerating polygon_regions because self defined datastructure can't be saved
	if ResourceLoader.exists("res://mesh_data.tres"):
		mesh_data = ResourceLoader.load("res://mesh_data.tres")
		mesh_data.polygon_regions = OrcaUtils.generate_allowed_area_regions(mesh_data.convex_polygons)
		return
	
	var large_polygons = []

	var polys = setup_large_polygons()
	mesh_data.occupied_polygons = polys[0]
	large_polygons = polys[1]
		
	mesh_data.convex_polygons = PolygonUtils.allowed_area_splitted_convex(
		large_polygons,
		rect[0],
		rect[1]
	)
	
	mesh_data.polygon_neighbours_dict = PolygonUtils.generate_polygon_neighbour_dict(mesh_data.convex_polygons)
	
	mesh_data.polygon_corner_neighbour_dict = PolygonUtils.generate_polygon_corner_neighbour_dict(mesh_data.convex_polygons)
		
	mesh_data.pos_to_region = setup_pos_to_region()
	
	#mesh_data.occupied_polygons = mesh_data.large_polygons
	
	var es = generate_corners()
	
	var corners = []
	
	var ps = []
	for p in $Poly.get_children():
		var poly = p.polygon
		ps.append(poly)
	
	for e in es:
		if e.x > 0 and e.y > 0:
			if not inside_polygons(e, ps):
				corners.append(e)
	mesh_data.corners = corners
		
	var connections = generate_connections()
	var graph = Dijstra.generate_graph(mesh_data.corners, connections)	
	var ds = generate_dists(graph)
	mesh_data.edges_to_dist = ds[0]
	mesh_data.edges_to_path = ds[1]
		
	var gs =  generate_position_to_visible_edges()
	mesh_data.position_to_corner_group_id = gs[0]
	mesh_data.corner_groups = gs[1]
	ResourceSaver.save(mesh_data, "res://mesh_data.tres")
		
	# can't be saved because of HalfPlaneClass
	mesh_data.polygon_regions = OrcaUtils.generate_allowed_area_regions(mesh_data.convex_polygons)

func _ready():
	
	setup_mesh_data()
	
	generate_fake_chars()

	for fake_char in fake_chars:
		fake_char["destination"] = Vector2(800, 400)
		var short_path = shortest_path_between_positions(
			fake_char["position"],
			Vector2(800, 400)
		)
		shortest_paths.append(short_path)
		
	for fake_char in fake_chars_2:
		fake_char["destination"] = Vector2(631, 195)
		var short_path = shortest_path_between_positions(
			fake_char["position"],
			Vector2(800, 400)
		)
		shortest_paths_2.append(short_path)
	
	OrcaUtils.set_velocities(
		fake_chars + fake_chars_2,
		shortest_paths + shortest_paths_2,
		mesh_data.convex_polygons,
		mesh_data.polygon_regions,
		mesh_data.polygon_neighbours_dict,
		mesh_data.polygon_corner_neighbour_dict
	)
	
func set_shortest_path():
	var new_cycle = cycle % ((len(shortest_paths) + len(shortest_paths_2)) * 4)
	for i in len(shortest_paths):
		if not new_cycle == i:
			continue
		if not fake_chars[i]["destination"]:
			continue
			
		var short_path = shortest_path_between_positions(
			fake_chars[i]["position"],
			fake_chars[i]["destination"]
		)
		
		if not short_path:
			short_path = fake_chars[i]["last_shortest_path"]
		
		fake_chars[i]["last_shortest_path"] = short_path
		
		if short_path and len(short_path) > 1:
			var dist =  fake_chars[i]["position"].distance_to(short_path[0])
			if dist < 3:
				short_path.pop_front()
		shortest_paths[i] = short_path
	
	for i in len(shortest_paths_2):
		
		if new_cycle == i + len(shortest_paths):
			continue
		
		if not fake_chars_2[i]["destination"]:
			continue
			
		var short_path = shortest_path_between_positions(
			fake_chars_2[i]["position"],
			fake_chars_2[i]["destination"]
		)
		
		if not short_path:
			short_path = fake_chars_2[i]["last_shortest_path"]
		
		fake_chars_2[i]["last_shortest_path"] = short_path
		
		if short_path and len(short_path) > 1:
			var dist =  fake_chars_2[i]["position"].distance_to(short_path[0])
			if dist < 3:
				short_path.pop_front()
		shortest_paths_2[i] = short_path
	
func _input(event):
	if event is InputEventMouseButton:

		match event.button_index:
			MOUSE_BUTTON_LEFT:
				for i in len(shortest_paths):
					fake_chars[i]["destination"] = event.position
					var short_path = shortest_path_between_positions(
						fake_chars[i]["position"],
						event.position
					)
					shortest_paths[i] = short_path
			MOUSE_BUTTON_RIGHT:
				for i in len(shortest_paths_2):
					fake_chars_2[i]["destination"] = event.position
					var short_path = shortest_path_between_positions(
						fake_chars[i]["position"],
						event.position
					)
					shortest_paths_2[i] = short_path 
		


func _physics_process(delta):
	queue_redraw()
	
	set_shortest_path()
	
	cycle += 1
	
	for i in range(len(fake_chars)):
		var f_c = fake_chars[i]
		var s_p = shortest_paths[i]
		move_along_direction(f_c, s_p, delta)
		
	for i in range(len(fake_chars_2)):
		var f_c = fake_chars_2[i]
		var s_p = shortest_paths_2[i]
		move_along_direction(f_c, s_p, delta)
	
	OrcaUtils.set_velocities(
		fake_chars + fake_chars_2,
		shortest_paths + shortest_paths_2,
		mesh_data.convex_polygons,
		mesh_data.polygon_regions,
		mesh_data.polygon_neighbours_dict,
		mesh_data.polygon_corner_neighbour_dict
	)

		
	
func _draw():
	
	for h in mesh_data.convex_polygons.size():
		var poly = mesh_data.convex_polygons[h]
		var region = mesh_data.polygon_regions[h]
		for i in poly.size():
			var p1 = poly[i]
			var p2 = poly[(i+1) % poly.size()]
			var color = Color.BLACK
			var size = 3

			draw_line(p1, p2, color, size)

			
	#for j in fake_chars.size():
	#	var pth = shortest_paths[j]
	#	var pos = fake_chars[j]["position"]
	#	if not pth:
	#		continue
	#	var color = Color.GRAY
	#	color.a = 0.2
	#	draw_line(pos, pth[0], color, 3) 
	#	for i in pth.size() - 1:
	#		draw_line(pth[i], pth[i+1], color, 3)
	
	for corner in mesh_data.corners:
		draw_circle(corner, 3, Color.AZURE)
	
	
	for fake_char in fake_chars:
		draw_circle(fake_char["position"], 8, Color.NAVY_BLUE)
	#	draw_line(fake_char["position"], fake_char["position"] + fake_char["new_velocity"] * 0.3, Color.LIGHT_BLUE, 3 )
		
	for fake_char in fake_chars_2:
		draw_circle(fake_char["position"], 8, Color.RED)
		
