extends Node2D

var point

var dim_x = 50
var dim_y = 50

var base_mesh = []
var occupancy_mesh = []
var edge_mesh = []

var edges = []

var occupied_polygons = []

func pad_mesh(mesh, value):
	var padded_mesh = []
	for i in range(dim_x +2):
		var line = []
		for j in range(dim_y +2):
			line.append(value)
		padded_mesh.append(line)
		
	for i in range(dim_x):
		for j in range(dim_y):
			padded_mesh[i+1][j+1] = mesh[i][j]
	
	return padded_mesh
	
func occupied_neigbour_exist(i,j, mesh):
	pass
	
func generate_shapes():
	"""
	Used to generate the shapes representing...
	maybe not needed
	"""
	var p_occupancy_mesh = pad_mesh(occupancy_mesh, false)
	for i in range(dim_x+1):
		for j in range(dim_y+1):
			pass
			
		
func outside_region(point):
	for polygon in $Poly.get_children():
		if Geometry2D.is_point_in_polygon(point, polygon.polygon):
			return true
	return false

func mark_specific_corner(corner_check):
	for ele in corner_check:
		if ele[0] < 0 or ele[1] < 0:
			return
		if ele[0] == dim_x or ele[1] == dim_y:
			return
		if occupancy_mesh[ele[0]][ele[1]]:
			return
	var c = corner_check[0]
	edge_mesh[c[0]][c[1]] = true
	edges.append(base_mesh[c[0]][c[1]])
	
func mark_corner(i, j):
	var upper_left = [[i-1, j-1], [i, j-1], [i-1, j]]
	var upper_right = [[i+1, j-1], [i+1,j], [i, j-1]]
	var lower_left = [[i-1, j+1], [i, j+1], [i-1, j]]
	var lower_right = [[i+1, j+1], [i, j+1], [i+1, j]]
	mark_specific_corner(upper_left)
	mark_specific_corner(upper_right)
	mark_specific_corner(lower_left)
	mark_specific_corner(lower_right)
	

func mark_corners():
	for i in range(dim_x):
		for j in range(dim_x):
			if occupancy_mesh[i][j]:
				mark_corner(i,j)

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

func get_neighbours(i,j, visited):
	var neighbours = []
	if i != 0 and not visited[i-1][j] and occupancy_mesh[i-1][j]:	
		neighbours.append([i-1,j])
		visited[i-1][j] = true
	if not i+1 == dim_x and not visited[i+1][j] and occupancy_mesh[i+1][j]:
		neighbours.append([i+1,j])
		visited[i+1][j] = true
	if not j+1 == dim_y and not visited[i][j+1] and occupancy_mesh[i][j+1]:
		neighbours.append([i,j+1])
		visited[i][j+1] = true
	if not visited[i][j-1] and occupancy_mesh[i][j-1]:
		neighbours.append([i,j-1])
		visited[i][j-1] = true
	return neighbours
		

func create_shape(i,j, visited):
	var shape = []
	var neighbours = [[i,j]]
	while neighbours:
		var pos = neighbours.pop_front()
		shape.append(pos)
		var k = pos[0]
		var l = pos[1]
		visited[k][l] = true
		var neigh = get_neighbours(k, l, visited)
		neighbours.append_array(neigh)
	return shape
	
	
func create_shapes():
	var visited = []
	for i in range(dim_x):
		var line = []
		for j in range(dim_y):
			line.append(false)
		visited.append(line)
		
	var found_shapes = []
		
	for i in range(dim_x):
		for j in range(dim_y):
			if visited[i][j]:
				continue
			if not occupancy_mesh[i][j]:
				continue
			var shape_raw = create_shape(i, j, visited)
			shape_raw.sort()
			var shape = []
			var start = null
			var last = null
			for ele in shape_raw:
				if not start:
					start = ele[0]
					shape.append(ele)
					continue
				if start == ele[0]:
					last = ele
				else:
					if not last in shape:
						shape.append(last)
					shape.append(ele)
					start = ele[0]
			shape.append(last) 
			found_shapes.append(shape)
			
	return found_shapes
	
			
		
func intersect_with_occupied_polygons(p,q):
	for polygon in occupied_polygons:
		if GeometryUtils.interset_with_shape(polygon, p,q):
			return true
	return false

var shortest_path
var graph
# Called when the node enters the scene tree for the first time.
func _ready():
	for polygon in $Poly.get_children():
		occupied_polygons.append(polygon.polygon)
	edges = generate_edges()
	print(len(edges))
	#mark_corners()
	
	var connections = []
	
	for i in range(len(edges)):
		var line = []
		for j in range(len(edges)):
			if i == j or intersect_with_occupied_polygons(edges[i], edges[j]):
				line.append(false)
			else:
				line.append(true)
			
		connections.append(line)
	#print(connections)
	graph = Dijstra.generate_graph(edges, connections)
	shortest_path = Dijstra.find_shortest_path(graph, graph[0], graph[14])
	#print(GeometryUtils.isometric_distance(Vector2(0,0), Vector2(2,1)))
	
	
func _draw():
	for edge in edges:
		draw_circle(edge, 4, Color.BLUE)
	for i in range(len(shortest_path) - 1):
		var start = shortest_path[i]
		var end = shortest_path[i+1]
		draw_line(start, end, Color.RED)
	"""
	for i in dim_x:
		for j in dim_y:
			var point = base_mesh[i][j]
			if edge_mesh[i][j]:
				draw_circle(point, 4, Color.BLUE)
			else:
				draw_circle(point, 2, Color.BLACK)
						
	for i in range(len(shortest_path) - 1):
		var start = shortest_path[i]
		var end = shortest_path[i+1]
		draw_line(start, end, Color.RED)
	"""
	
