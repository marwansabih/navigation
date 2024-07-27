extends Node2D

var point

var dim_x = 120
var dim_y = 120

var base_mesh = []
var occupancy_mesh = []
var edge_mesh = []

var edges = []

var occupied_polygons = []

	
func outside_region(point):
	for polygon in $Poly.get_children():
		if Geometry2D.is_point_in_polygon(point, polygon.polygon):
			return true
	return false

func get_edge_point(polygon, p_point, point, n_point):
	var dir_1 = (p_point - point).normalized()
	var dir_2 = (n_point - point).normalized()
	var n_dir = (dir_1 + dir_2).normalized() * 20
	var new_point = point - n_dir
	if not outside_region(new_point):
		return new_point
	return point + n_dir

func generate_polygon_edges(polygon):
	var p = polygon.polygon
	var size = len(p)
	var p_index = size - 1
	var edge_points = []
	for i in range(size):
		var p_point = p[p_index]
		var n_point = p[(i+1)%size]
		var point = p[i]
		var edge = get_edge_point(p, p_point, point, n_point)
		edge_points.append(edge)
		p_index = i
	return edge_points

func generate_edges():
	var edges = []
	for polygon in $Poly.get_children():
		edges.append_array(generate_polygon_edges(polygon))
	return edges
		
	
			
		
func intersect_with_occupied_polygons(p,q):
	for polygon in occupied_polygons:
		if GeometryUtils.interset_with_shape(polygon, p,q):
			return true
	return false

var shortest_path
var graph


var position_to_units = {}
var position_to_visible_edges = {}

func inside_polygons(p, polygons):
	for polygon in polygons:
		if Geometry2D.is_point_in_polygon(p, polygon):
			return true
	return false

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
			

func add_visible_edges(point):
	var visible_edges = []
	position_to_visible_edges[point] = []
	
	for i in len(edges):
		if not intersect_with_occupied_polygons(point, edges[i]):
			position_to_visible_edges[point].append(i)

func generate_position_to_visible_edges_2():
	var shadow_polygons = []
	for edge in edges:
		var polys = generate_shadow_polygons(edge)
		shadow_polygons.append(polys)
		
	for i in range(dim_x):
		for j in range(dim_y):
			var visible_edges = []
			var pos = Vector2(i*8, j*8)
			for k in range(len(edges)):
				if not inside_polygons(pos, shadow_polygons[k]):
					visible_edges.append(k)
			position_to_visible_edges[pos] = visible_edges
			
			
func generate_position_to_visible_edges():
	for i in range(dim_x):
		for j in range(dim_y):
			var pos = Vector2(i*8, j*8)
			add_visible_edges(pos)	

func shortest_path_between_positions(
	p1: Vector2,
	p2: Vector2
):
	if not intersect_with_occupied_polygons(p1, p2):
		return [p1,p2]
	
	var neigh_1 = position_to_visible_edges[p1]
	var neigh_2 = position_to_visible_edges[p2]
	var min_dist = INF
	var edge_1
	var edge_2
	for i in neigh_1:
		var dist_1 = GeometryUtils.isometric_distance(p1, edges[i])
		for j in neigh_2:
			var dist_2 = GeometryUtils.isometric_distance(p2, edges[j])
			var dist = dist_1 + edges_to_dist[i][j] + dist_2
			if dist < min_dist:
				edge_1 = i
				edge_2 = j
				min_dist = dist
	
	var path = edges_to_path[edge_1][edge_2]
	var s_path = [p1]
	s_path.append_array(path)
	s_path.append(p2)
	return s_path
	
	
	

var edges_to_dist = {}
var edges_to_path = {}

func generate_dists(graph):
	var size = len(edges)
	for i in range(size):
		edges_to_dist[i] = {}
		edges_to_path[i] = {}
		for j in range(size):
			var node = Dijstra.find_shortest_path(graph, graph[i], graph[j])
			edges_to_dist[i][j] = node["distance"]
			edges_to_path[i][j] = node["path"]

# Called when the node enters the scene tree for the first time.
func _ready():
	for polygon in $Poly.get_children():
		occupied_polygons.append(polygon.polygon)
	edges = generate_edges()
	
	var connections = []
	
	for i in range(len(edges)):
		var line = []
		for j in range(len(edges)):
			if i == j or intersect_with_occupied_polygons(edges[i], edges[j]):
				line.append(false)
			else:
				line.append(true)
		connections.append(line)
		
	graph = Dijstra.generate_graph(edges, connections)
	generate_dists(graph)
	generate_position_to_visible_edges_2()
	shortest_path = shortest_path_between_positions(
		Vector2(64, 64),
		Vector2(800, 400)
	)
	
	
	
func _draw():
	for edge in edges:
		draw_circle(edge, 4, Color.BLUE)
	for i in range(len(shortest_path) - 1):
		var start = shortest_path[i]
		var end = shortest_path[i+1]
		draw_line(start, end, Color.RED)
	
	var v_e_1 = position_to_visible_edges[Vector2(64, 64)]
	var v_e_2 = position_to_visible_edges[Vector2(800, 400)]
	
	for e in v_e_1:
		draw_circle(edges[e], 4, Color.WHITE)
		
	for e in v_e_2:
		draw_circle(edges[e], 4, Color.RED)
	
