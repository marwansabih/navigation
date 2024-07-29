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

func get_edge_point(
	polygon,
	p_point,
	point,
	n_point
):
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
var actor_position_mesh = {}

func setup_actor_position_mesh():
	for i in range(dim_x):
		for j in range(dim_y):
			var pos = Vector2(i*8, j*8)
			actor_position_mesh[pos] = []


func generate_sourounding_square(pos, size, dir):
	if not dir:
		return [pos, pos, pos, pos]
	var left_dir = size * dir.rotated(PI/2)
	var right_dir = size * dir.rotated(-PI/2)
	var down_dir = -size * dir
	var up_dir = size * dir 
	var left = pos + left_dir
	var right = pos + right_dir
	var down = pos + down_dir
	var up = pos + up_dir
	return [
		left,
		up,
		right,
		down
	]
		

func intersects_with_polys(polies, p, q):
	for poly in polies:
		if GeometryUtils.interset_with_shape(poly, p, q):
			return true
	return false

func build_position_graph(pos, goal):
	var actor_positions = []
	var pos_m = GeometryUtils.get_closest_mesh_position(pos)
	for i in range(9):
		for j in range(9):
			var delta_pos = Vector2((i-4)*8, (j-4)*8) + pos_m
			if not delta_pos in actor_position_mesh:
				continue
			var actors = actor_position_mesh[delta_pos]
			actor_positions.append_array(actors)
	
	
	var polygons = []
	var l_edges = [pos]
	var dir = pos.direction_to(goal)
	
	for p in actor_positions:
		var poly = generate_sourounding_square( p, 12, dir )
		var l_es = generate_sourounding_square( p, 16, dir )
		if Geometry2D.is_point_in_polygon(goal, l_es):
			goal += dir * 10
		polygons.append(poly)
		l_edges.append_array(l_es)
	
	# add goal
	l_edges.append(goal)
	
	
	var connections = []
	
	for i in range(len(l_edges)):
		var line = []
		for j in range(len(l_edges)):
			if i == j or intersects_with_polys(polygons, l_edges[i], l_edges[j]):
				line.append(false)
			else:
				line.append(true)
		connections.append(line)
	
	
	graph = Dijstra.generate_graph(l_edges, connections)
	if graph[0]["neighbours"] and graph[len(graph)-1]["neighbours"]:
		var node = Dijstra.find_shortest_path(graph, graph[0], graph[len(graph)-1])
		var path = node["path"]
		var new_dir = pos.direction_to(path[1])
		fake_character["local_path"] = path
		return new_dir
		
	#print("whole graph")
	#for node in graph:
	#	print(node)
	
	fake_character["local_path"] = null
	return dir
	
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
	var p1_m = GeometryUtils.get_closest_mesh_position(p1)
	var p2_m = GeometryUtils.get_closest_mesh_position(p2)
	for i in neigh_1:
		var dist_1 = GeometryUtils.isometric_distance(p1_m, edges[i])
		for j in neigh_2:
			var dist_2 = GeometryUtils.isometric_distance(p2_m, edges[j])
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
	

var fake_character = {
	"velocity" =50,
	"position" = Vector2(8,8),
	"dir" = null,
	"local_path" = null
} 

var fake_characters = []


func generate_fake_characters():
	for i in range(100):
		fake_characters.append(Vector2(i*32,i*32))
		fake_characters.append(Vector2((i+2)*32,i*32))
		fake_characters.append(Vector2((i-3)*32,i*32))
		fake_characters.append(Vector2((i+5)*32,i*32))
		fake_characters.append(Vector2((i+3)*32,i*32))
		fake_characters.append(Vector2((i+12)*32,i*32))
		fake_characters.append(Vector2((i+15)*32,i*32))
		
func put_characters_to_mesh():
	for char in fake_characters:
		var pos = GeometryUtils.get_closest_mesh_position(char)
		if pos in actor_position_mesh:
			actor_position_mesh[pos].append(char)
		
#func get_c
		
		
func move_along_direction(
	character,
	path,
	delta
):
	if not path:
		character["dir"] = null
		return
	var dir = character["dir"]
	var velocity = character["velocity"]
	var pos = character["position"]
	if path[0].distance_to(pos) < 3:
		path.pop_front()
		if path: 
			character["dir"] = pos.direction_to(path[0])
	if path:
		if not character["dir"]:
			character["dir"] = pos.direction_to(path[0])
		var new_dir = build_position_graph(pos, path[0])
		character["position"] += velocity * new_dir * delta
		#character["position"] += velocity * character["dir"] * delta
	
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

func generate_connections():
	var connections = []
	
	for i in range(len(edges)):
		var line = []
		for j in range(len(edges)):
			if i == j or intersect_with_occupied_polygons(edges[i], edges[j]):
				line.append(false)
			else:
				line.append(true)
		connections.append(line)
	return connections
	
# Called when the node enters the scene tree for the first time.
func _ready():
	for polygon in $Poly.get_children():
		occupied_polygons.append(polygon.polygon)
	edges = generate_edges()
	
	var connections = generate_connections()
		
	graph = Dijstra.generate_graph(edges, connections)
	generate_dists(graph)
	generate_position_to_visible_edges_2()
	shortest_path = shortest_path_between_positions(
		fake_character["position"],
		Vector2(800, 400)
	)
	generate_fake_characters()
	setup_actor_position_mesh()
	put_characters_to_mesh()
		
	
func _physics_process(delta):
	queue_redraw()
	move_along_direction(
		fake_character,
		shortest_path,
		delta
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
		
	draw_circle(fake_character["position"], 8, Color.NAVY_BLUE)
	
	if fake_character["local_path"]:
		var path = fake_character["local_path"]
		#for i in range(len(path) -1):
		#	draw_line(path[i], path[i+1], Color.BLACK, 1)
	
	#var pos_m = GeometryUtils.get_closest_mesh_position(fake_character["position"])
	
	#print("actor_pos")
	#print(pos_m)
	#var actor_positions = []
	#for i in range(9):
	#	for j in range(9):
	#		var delta_pos = Vector2((i-4)*8, (j-4)*8) + pos_m
	#		if not delta_pos in actor_position_mesh:
	#			continue
	#		var actors = actor_position_mesh[delta_pos]
	#		actor_positions.append_array(actors)

	
	for f_c in fake_characters:
		draw_circle(f_c, 4, Color.DARK_VIOLET)
		#var square = generate_sourounding_square(f_c, 16, Vector2(1,0))
		#draw_polyline(square, Color.RED, 1)
		#draw_line(square[0], square[3], Color.RED, 1)
		#var square2 = generate_sourounding_square(f_c, 24, Vector2(1,0))
		#draw_polyline(square2, Color.BLUE, 1)
		#draw_line(square2[0], square2[3], Color.BLUE, 1)
		
	"""
	for p_c in actor_positions:
		draw_circle(p_c, 8, Color.RED)
		var dir = fake_character["dir"]
		var square2 = generate_sourounding_square(p_c, 24, dir)
		draw_polyline(square2, Color.BLUE, 1)
		draw_line(square2[0], square2[3], Color.BLUE, 1)
	
	for i in range(dim_x):
		for j in range(dim_y):
			draw_circle(Vector2(i*8, j*8), 1, Color.BLACK)
	"""
