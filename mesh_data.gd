extends Resource
class_name MeshData

@export var position_to_corner_group_id = {}
@export var corner_groups = []
@export var occupied_polygons = []
@export var convex_polygons = []
@export var polygon_neighbours_dict = {}
@export var polygon_corner_neighbour_dict = {}
@export var polygon_regions = []
@export var pos_to_region = {}
@export var corners = [] 
@export var edges_to_dist = {}
@export var edges_to_path = {}
@export var obstacle_boxes = []
@export var obstacle_map = {}
@export var grid_position_to_walls = {}
@export var obstacles = []
@export var edge_boxes = []

var dim_x
var dim_y

var polygons =  []


func _init():
	pass
	

func setup_mesh_data(
	obstacle_region,
	id: String
):
	
	var map_path = "res://maps/{id}.tres".format({"id": id})
	
	if ResourceLoader.exists(map_path) or false:
		var mesh_data = ResourceLoader.load(map_path)
		position_to_corner_group_id = mesh_data.position_to_corner_group_id
		corner_groups = mesh_data.corner_groups
		occupied_polygons = mesh_data.occupied_polygons
		convex_polygons = mesh_data.convex_polygons
		polygon_neighbours_dict = mesh_data.polygon_neighbours_dict
		polygon_corner_neighbour_dict = mesh_data.polygon_corner_neighbour_dict
		
		setup_polygons(obstacle_region) 
		
		var polys = setup_large_polygons()
		occupied_polygons = polys[0]
		print("first occupied  polys")
		print(occupied_polygons)
		var large_polygons = polys[0]
		print("large polygons")
		print(large_polygons)
		
		edge_boxes = PolygonUtils.generate_polygon_edge_boxes(
			occupied_polygons
		)
		
		setup_obstacle_boxes()
		
		#obstacle_boxes = mesh_data.obstacle_boxes
		pos_to_region = mesh_data.pos_to_region
		corners = mesh_data.corners
		edges_to_dist = mesh_data.edges_to_dist
		edges_to_path = mesh_data.edges_to_path
		
		var rect = obstacle_region.get_viewport().get_visible_rect().size		
		dim_x = rect.x
		dim_y = rect.y
		
		setup_polygons(obstacle_region)
		
		PolygonUtils.generate_obstacle_map(
			polygons,
			16,
			obstacle_map,
			[],
			0,
			dim_x,
			0,
			dim_y,
			16
		)
		
		obstacles = []
		
		for obst in obstacle_region.get_children():
			obstacles.append(obst.polygon)
		
		grid_position_to_walls = PolygonUtils.generate_grid_position_to_walls(
			dim_x,
			dim_y,
			32,
			obstacles
		)
		
		#ResourceSaver.save(self, map_path)
		polygon_regions = OrcaUtils.generate_allowed_area_regions(convex_polygons)
		return
	
	var rect = obstacle_region.get_viewport().get_visible_rect().size		
	dim_x = rect.x
	dim_y = rect.y
	
	print("Dim x {dim_x}".format({"dim_x": dim_x}))
	print("Dim y {dim_y}".format({"dim_y": dim_y}))
	
	setup_polygons(obstacle_region)
	
	var large_polygons = []

	var polys = setup_large_polygons()
	occupied_polygons = polys[0]
	large_polygons = polys[1]
	
	
	print("Occupied polygons and large polygons were setup")
	
	setup_obstacle_boxes()
	
	print("Obstacle boxes setup")	
	
	convex_polygons = PolygonUtils.allowed_area_splitted_convex(
		large_polygons,
		dim_x,
		dim_y
	)
	
	print("Convex polygons were setup")
	
	# gnerating polygon_regions because self defined datastructure can't be saved
	polygon_regions = OrcaUtils.generate_allowed_area_regions(convex_polygons)
	
	print("Polygon regions were setup")
	
	polygon_neighbours_dict = PolygonUtils.generate_polygon_neighbour_dict(convex_polygons)
	
	print("Polygon neighbours dict was setup")
	
	polygon_corner_neighbour_dict = PolygonUtils.generate_polygon_corner_neighbour_dict(convex_polygons)
	
	print("Polygon corner neighbour dict was setup")
		
	pos_to_region = setup_pos_to_region(dim_x, dim_y)
	
	print("Pos to region was setup")
	
	var es = generate_corners()
	
	for e in es:
		if e.x > 0 and e.y > 0:
			if not inside_polygons(e, polygons):
				corners.append(e)
		
	var connections = generate_connections()
	var graph = Dijstra.generate_graph(corners, connections)	
	var ds = generate_dists(graph)
	edges_to_dist = ds[0]
	edges_to_path = ds[1]
		
	var gs =  generate_position_to_visible_edges()
	position_to_corner_group_id = gs[0]
	corner_groups = gs[1]
	ResourceSaver.save(self, map_path)
	
	print("Map was setup")
		
	# can't be saved because of HalfPlaneClass
	polygon_regions = OrcaUtils.generate_allowed_area_regions(convex_polygons)
	print("Setup complete")
	
func setup_polygons(obstacle_region):
	for obstacle in obstacle_region.get_children():
		polygons.append(obstacle.polygon)
	polygons = PolygonUtils.order_clockwise(polygons)
	
func setup_pos_to_region(dim_x, dim_y):
	for i in convex_polygons.size():
		var convex_polygon = convex_polygons[i] 
		for k in range(dim_x):
			for l in range(dim_y):
				var point = Vector2(k, l)
				if PolygonUtils.in_polygon(convex_polygon, point):
					pos_to_region[point] = polygon_regions[i]
	return pos_to_region

func setup_large_polygons():
	var large_polygons = []
	var occupied_polygons = []
	for p in polygons:
		var poly = expand_polygon(p, 8)
		large_polygons.append(poly)
		var poly_2 = expand_polygon(p, 19)
		occupied_polygons.append(poly)
		
	occupied_polygons = PolygonUtils.order_clockwise(occupied_polygons)
	large_polygons = PolygonUtils.order_clockwise(large_polygons)
	return [occupied_polygons, large_polygons]
	
func setup_obstacle_boxes():
	
	for polygon in occupied_polygons:
		var min_x = INF
		var max_x = -INF
		var min_y = INF
		var max_y = -INF
		for p in polygon:
			if p.x < min_x:
				min_x = p.x
			if p.x > max_x:
				max_x =  p.x
			if p.y < min_y:
				min_y = p.y
			if p.y > max_y:
				max_y = p.y
		obstacle_boxes.append(
			[min_x, max_x, min_y, max_y]
		)

func expand_polygon(polygon, corner_distance):
	var p = polygon
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
	
	var to_b = -(dir_1 - dir_1.dot(dir_2)*dir_2).normalized() * corner_distance
	var to_e =  -(dir_2 - dir_2.dot(dir_1)*dir_1).normalized() * corner_distance
	
	var b: Vector2 = point + to_b
	var e: Vector2 = point + to_e
	
	if inside_polygons(e, polygons):
		e = point - to_e 
	if inside_polygons(b, polygons):
		b = point - to_b 
	
	var t_1 = - b.x/dir_2.x * dir_2.y + b.y
	var m_1 = dir_2.y/dir_2.x
	var t_2 = - e.x/dir_1.x * dir_1.y + e.y
	var m_2 = dir_1.y/dir_1.x
	var x = (t_2-t_1)/(m_1-m_2)
	var y = m_1*x + t_1
	
	return Vector2(x,y)
	
func inside_polygons(p, polys):
	for polygon in polys:
		if PolygonUtils.in_polygon(polygon, p):
			return true
	return false
	
func generate_corners():
	var corners = []
	for polygon in polygons:
		corners.append_array(expand_polygon(polygon, 19))
	return corners

func generate_connections():
	var connections = []
	
	for i in range(len(corners)):
		var line = []
		for j in range(len(corners)):
			if i == j or intersect_with_occupied_polygons(corners[i],corners[j]):
				line.append(false)
			else:
				line.append(true)
		connections.append(line)
	return connections

func intersect_with_occupied_polygons(p,q):
	for polygon in occupied_polygons:
		var dir = (q-p).normalized().rotated(PI/2)
		var critera_1 = GeometryUtils.interset_with_shape(polygon, p + 8 * dir,q + 8 * dir )
		var critera_2 = GeometryUtils.interset_with_shape(polygon, p - 8 * dir,q - 8 * dir )
		if GeometryUtils.interset_with_shape(polygon, p,q) and critera_1 and critera_2:
			return true
	return false

func generate_dists(graph):
	var edges_to_dist = {}
	var edges_to_path = {}
	var size = len(corners)
	for i in range(size):
		edges_to_dist[i] = {}
		edges_to_path[i] = {}
		for j in range(size):
			var node = Dijstra.find_shortest_path(graph, graph[i], graph[j])
			edges_to_dist[i][j] = node["distance"]
			edges_to_path[i][j] = node["path"]
	return [edges_to_dist, edges_to_path]

func generate_position_to_visible_edges():
	
	var position_to_visible_corner_ids = {}
	
	
	var nr_corners = corners.size()
	
	
	var shadow_polygons = []
	for edge in corners:
		var polys = generate_shadow_polygons(edge)
		shadow_polygons.append(polys)
		
	var nr_
		
	for i in range(dim_x):
		for j in range(dim_y):
			var visible_edges = []
			var pos = Vector2(i, j)
			for k in range(len(corners)):
				if inside_polygons(pos, shadow_polygons[k]):
					continue
				var c_edge = corners[k]
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
	
func generate_shadow_polygons(point):
	var shadow_polygons = []
	for polygon in occupied_polygons:
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
