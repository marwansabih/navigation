extends Node2D

var point

var dim_x = 800
var dim_y = 800

var base_mesh = []
var occupancy_mesh = []
var edge_mesh = []

var edges = []
var occupied_polygons = []

var pos_to_walls = {}

var walls = []

var small_polygons = []

var mesh_grid_size = 16


func setup_small_polygons():
	for p in $Poly.get_children():
		#var poly = generate_polygon_edges(p, 12)
		small_polygons.append(p.polygon)

func setup_pos_to_wall():
	for i in range(dim_x):
		for j in range(dim_y):
			pos_to_walls[Vector2(mesh_grid_size*i, mesh_grid_size*j)] = []
	
	for polygon in $Poly.get_children():
		var poly = polygon.polygon
		var size = len(poly)
		for i in range(size):
			var next_i = (i+1) % size
			var p1 = poly[i]
			var p2 = poly[next_i]
			var wall = [p1,p2]
			walls.append(wall)
			var ps = GeometryUtils.get_wall_points(wall, 100)
			for p in ps:
				if p in pos_to_walls:
					pos_to_walls[p].append(wall)
		

func generate_wall_velocity(
	pos,
	wall,
	strength
):
	var rel = pos - wall[0]
	var dir = (wall[1] - wall[0]).normalized()
	var orth = rel - rel.dot(dir) * dir
	var dist = orth.length()
	if dist > 8:
		return Vector2(0, 0)
	return orth
	#return (5 - dist) * strength * orth
	#return (orth/dist**2 ) * strength

func vec_ortho(pos, dir, x, y):
	pass
	
func generate_goal_velocity(pos, loc, strength):
	return strength * pos.direction_to(loc)

func generate_source_velocity(pos, loc, strength, dist_power):
	var p_x = pos.x - loc.x
	var p_y = pos.y - loc.y
	var dist = pos.distance_to(loc)
	var v_x =  p_x/sqrt(p_x**2 + p_y**2)
	var v_y =  p_y/sqrt(p_x**2 + p_y**2)
	return strength / dist**dist_power * Vector2(v_x,v_y) * ( 1 +  randf())

func get_local_dir(pos: Vector2, goal: Vector2, delta):
	var pos_m = GeometryUtils.get_closest_mesh_position(pos, mesh_grid_size)
	var map_polys = []
	var actor_positions = []
	for i in range(9):
		for j in range(9):
			var delta_pos = Vector2((i-mesh_grid_size/2)*mesh_grid_size, (j-mesh_grid_size/2)*mesh_grid_size) + pos_m
			if not delta_pos in actor_position_mesh:
				continue
			if true:
				continue
			#var actors = actor_position_mesh[delta_pos]
			#actor_positions.append_array(actors)
	
	#for actor in fake_characters:
	#	actor_positions.append(actor)
	
	if pos.distance_to(fake_character["position"]) > 0.01:
		actor_positions.append(fake_character["position"])
			
	for actor in fake_chars:
		var f_pos = actor["position"]
		if pos.distance_to(f_pos) > 0.01:
			actor_positions.append(f_pos)
		#break
	
	var in_poly_range = false
	
	for polygon in $Poly.get_children():
		in_poly_range = GeometryUtils.in_polygon_range(
			polygon.polygon,
			16,
			pos
		)
		
	return VFUtils.get_dir(
		pos,
		actor_positions,
		goal,
		8,
		$Poly,
		delta,
		in_poly_range
	)
	"""

	var dir_source = Vector2(0,0)
	var dist = pos.distance_to(goal)
	for point in actor_positions:
		dir_source += generate_source_velocity(pos, point, 3000,2)
	var dir_wall = Vector2(0,0)
	if pos_m in pos_to_walls:
		for wall in pos_to_walls[pos_m]:
			dir_wall += generate_wall_velocity(pos, wall, 10000000)
	#var dir_goal = generate_source_velocity(pos, goal, -100 - dist, 0)
	var dir_goal = generate_goal_velocity(pos, goal, 50)
	#if dir_goal.length()/ dir_wall.length() < 1.2:
	#	dir_goal *= 10
	#if dir_source.length() / dir_goal.length() < 1.2:
	#	dir_source * 4
	#if dir_source.length() / dir_wall.length() < 1.2:
	#	dir_wall * 4
	# added random addition to prevent  "stuck in back and forth loop"
	if dir_wall.length() > 0.1:
		return 2*dir_wall.normalized()
	return (dir_goal + dir_source).normalized()
	"""

func plane_in_dir(dir):
	pass
	
func outside_region(point):
	for polygon in $Poly.get_children():
		if Geometry2D.is_point_in_polygon(point, polygon.polygon):
			return true
	return false

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
	#if dir_1.angle_to(-dir_2)/ PI < -0.5 and dir_1.angle_to(-dir_2)/PI > 0.5:
	#	signum = - 1
	
	var polys = []
	for p in $Poly.get_children():
		polys.append(p.polygon)
	
	var to_b = -(dir_1 - dir_1.dot(dir_2)*dir_2).normalized() * corner_distance
	var to_e =  -(dir_2 - dir_2.dot(dir_1)*dir_1).normalized() * corner_distance
	
	var b: Vector2 = point + to_b
	var e: Vector2 = point + to_e
	
	if inside_polygons(e, polys):
		e = point - to_e #-e point - to_e
	if inside_polygons(b, polys):
		b = point - to_b # -b#point - to_b
	
	var t_1 = - b.x/dir_2.x * dir_2.y + b.y
	var m_1 = dir_2.y/dir_2.x
	var t_2 = - e.x/dir_1.x * dir_1.y + e.y
	var m_2 = dir_1.y/dir_1.x
	var x = (t_2-t_1)/(m_1-m_2)
	var y = m_1*x + t_1
	
	#var result = 
	return Vector2(x,y)
	
	if inside_polygons(e, polys):
		e = point + to_e 
	if inside_polygons(b, polys):
		b = point + to_b
	var f = ((b.y - e.y)*dir_1.x+ dir_1.y*(e.x-b.x))/(dir_2.y*dir_1.x-dir_2.x*dir_1.y)

	return e + f * dir_2
	return point -(dir_1 - dir_1.dot(dir_2) * dir_2).normalized() * corner_distance #e #+ f * dir_2
	
	
	var p_1 = (dir_1 + dir_2).normalized().dot(dir_1)
	var p_2 = (dir_1 + dir_2).normalized().dot(dir_2)
	var min_p = min(p_1, p_2)
	var n_dir = (dir_1 + dir_2) * corner_distance / min_p
	
	var new_point = point - n_dir
	if not outside_region(new_point):
		return new_point
	return point + n_dir

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

var large_polygons = []

func setup_large_polygons():
	for p in $Poly.get_children():
		var poly = generate_polygon_edges(p, 12)
		large_polygons.append(poly)
		#large_polygons.append(p.polygon)
	

func generate_edges():
	var edges = []
	for polygon in $Poly.get_children():
		edges.append_array(generate_polygon_edges(polygon, 16))
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
var polygon_position_mesh = {}

func setup_polygon_position_mesh():
	for i in range(dim_x):
		for j in range(dim_y):
			var pos = Vector2(i*8, j*8)
			polygon_position_mesh[pos] = []
			for poly in $Poly.get_children():
				if not Geometry2D.is_point_in_polygon(pos, poly.polygon):
					continue
				polygon_position_mesh[pos].append(poly.polygon)

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
	var pos_m = GeometryUtils.get_closest_mesh_position(pos, mesh_grid_size)
	var map_polys = []
	for i in range(9):
		for j in range(9):
			var delta_pos = Vector2((i-mesh_grid_size/2)*mesh_grid_size, (j-mesh_grid_size/2)*mesh_grid_size) + pos_m
			if not delta_pos in actor_position_mesh:
				continue
			map_polys.append_array(polygon_position_mesh[delta_pos])
			var actors = actor_position_mesh[delta_pos]
			actor_positions.append_array(actors)
	
	
	var polygons = map_polys
	var l_edges = [pos]
	var dir = pos.direction_to(goal)
	
	for p in actor_positions:
		var poly = generate_sourounding_square( p, 16, dir )
		var l_es = generate_sourounding_square( p, 24, dir )
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
			var pos = Vector2(i*mesh_grid_size, j*mesh_grid_size)
			for k in range(len(edges)):
				if not inside_polygons(pos, shadow_polygons[k]):
					visible_edges.append(k)
			position_to_visible_edges[pos] = visible_edges
	return 
	for key in position_to_visible_edges.keys():
		if not position_to_visible_edges[key]:
			var up = Vector2(key.x, key.y + mesh_grid_size)
			var down = Vector2(key.x, key.y - mesh_grid_size)
			var left = Vector2(key.x - mesh_grid_size, key.y)
			var right = Vector2(key.x + mesh_grid_size, key.y)
			for dir in [up, down, right, left]:
				if dir in position_to_visible_edges:
					position_to_visible_edges[key] = position_to_visible_edges[dir] #[GeometryUtils.get_closest_edge(edges, key)]
			
func generate_position_to_visible_edges():
	for i in range(dim_x):
		for j in range(dim_y):
			var pos = Vector2(i*mesh_grid_size, j*mesh_grid_size)
			add_visible_edges(pos)

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
	if not intersect_with_occupied_polygons(p1, p2):
		return [p1,p2]
	
	var p1_m = GeometryUtils.get_closest_mesh_position(p1, mesh_grid_size)
	var p2_m = GeometryUtils.get_closest_mesh_position(p2, mesh_grid_size)
	
	var neigh_1 = position_to_visible_edges[p1_m]
	var neigh_2 = position_to_visible_edges[p2_m]
	var min_dist = INF
	var edge_1
	var edge_2
	for i in neigh_1:
		var dist_1 = GeometryUtils.isometric_distance(p1_m, edges[i])
		for j in neigh_2:
			var dist_2 = GeometryUtils.isometric_distance(p2_m, edges[j])
			var dist = dist_1 + edges_to_dist[i][j] + dist_2
			if dist < min_dist:
				edge_1 = i
				edge_2 = j
				min_dist = dist
	
	if not edge_1 or not edge_2:
		return
	
	var path = edges_to_path[edge_1][edge_2]
	var s_path = [p1]
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

func generate_fake_chars():
	return
	for i in range(8):
		var char = {
			"velocity" =50,
			"position" = Vector2(16 + 36*i,100),
			"dir" = null,
			"org_dir" = Vector2(0,0),
			"local_path" = null
		}
		fake_chars.append(char)
		continue
		var char2 = {
			"velocity" =50,
			"position" = Vector2(16 + 36*i,50),
			"dir" = null,
			"org_dir" = Vector2(0,0),
			"local_path" = null
		}
		fake_chars.append(char2)
	

var fake_characters = []

func inisde_polygon(pos):
	for poly in $Poly.get_children():
		if Geometry2D.is_point_in_polygon(pos,poly.polygon):
			return true
	return false

func generate_fake_characters():
	return
	for poly in $Poly.get_children():
		for ele in poly.polygon:
			fake_characters.append(ele)
	return
	for i in range(100):
		for j in range(7):
			var pos = Vector2(i*32 + i*3 + j * 64, i*16)
			if not inisde_polygon(pos):
				fake_characters.append(pos)
		
		#fake_characters.append(Vector2((i+3)*32,i*16))
		#fake_characters.append(Vector2((i+6)*32,i*16))
		#fake_characters.append(Vector2((i+9)*32,i*16))
		#fake_characters.append(Vector2((i+12)*32,i*16))
		#fake_characters.append(Vector2((i+15)*32,i*16))
		#fake_characters.append(Vector2((i+18)*32,i*16))
	
func put_characters_to_mesh():
	for char in fake_characters:
		var pos = GeometryUtils.get_closest_mesh_position(char, mesh_grid_size)
		if pos in actor_position_mesh:
			actor_position_mesh[pos].append(char)
		
		
var cycle = 0
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
	if pos.direction_to(path[0]).dot(character["org_dir"]) < 0:
		path.pop_front()
		if path:
			character["dir"] = pos.direction_to(path[0])
			character["org_dir"] = pos.direction_to(path[0])
	if path and path[0].distance_to(pos) < 10:
		path.pop_front()
		if path:
			character["dir"] = pos.direction_to(path[0])
			character["org_dir"] = pos.direction_to(path[0])
	if len(path) > 1 and not intersect_with_occupied_polygons(pos, path[1]):
		if (path[1]-path[0]).dot(pos-path[0]) > 0:
			pass
			#path.pop_front()
	if path:
		"""
		if not character["dir"]:
			character["dir"] = pos.direction_to(path[0])
			character["org_dir"] = pos.direction_to(path[0])
		if true:#cycle % 15 == 0:
			var new_dir = get_local_dir(pos, path[0], delta * velocity)
			#build_position_graph(pos, path[0])
			character["dir"] = new_dir
		"""
		var factor = 1
		for char in fake_chars:
			if char == character:
				continue
			var next_pos =  character["position"] + character["new_velocity"] * delta
			if char["position"].distance_to(next_pos) <  16:
				print ("warning warning warning")
				print(char["position"])
				print(character["position"])
				print(char["new_velocity"])
				print(character["new_velocity"])
				print(char["opt_velocity"])
				print(character["opt_velocity"])
				print ("warning warning warning")
				factor = 0
				
		character["position"] += character["new_velocity"] * delta * factor#velocity * character["dir"] * delta
		cycle += 1
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
	
var shortest_paths = []
	
# Called when the node enters the scene tree for the first time.
func _ready():
	return
	setup_small_polygons()
	setup_pos_to_wall()
	generate_fake_chars()
	setup_polygon_position_mesh()
	setup_large_polygons()
	occupied_polygons = large_polygons
	#for polygon in $Poly.get_children():
		#occupied_polygons = large_polygons
	#	occupied_polygons.append(polygon.polygon)
	var es = generate_edges()
	
	edges = []
	
	var ps = []
	for p in $Poly.get_children():
		var poly = p.polygon
		ps.append(poly)
	
	for e in es:
		if e.x > 0 and e.y > 0:
			if not inside_polygons(e, ps):
				edges.append(e)
	
	
	var connections = generate_connections()
	
		
	graph = Dijstra.generate_graph(edges, connections)
	generate_dists(graph)
	generate_position_to_visible_edges_2()
	shortest_path = shortest_path_between_positions(
		fake_character["position"],
		Vector2(800, 400)
	)
	for fake_char in fake_chars:
		var short_path = shortest_path_between_positions(
			fake_char["position"],
			Vector2(800, 400)
		)
		shortest_paths.append(short_path)
	
	
	OrcaUtils.set_velocities(fake_chars, shortest_paths, walls)
	
	#generate_fake_characters()
	#setup_actor_position_mesh()
	#put_characters_to_mesh()
	
func _input(event):
	if event is InputEventMouseButton:
		print("Mouse Click/Unclick at: ", event.position)
		shortest_path = shortest_path_between_positions(
			fake_character["position"],
			event.position
		)
		for i in len(shortest_paths):
			var short_path = shortest_path_between_positions(
				fake_chars[i]["position"],
				event.position
			)
			shortest_paths[i] = short_path
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				pos = event.position
				c1_ = event.position
			MOUSE_BUTTON_RIGHT:
				v = event.position - pos
				opt_v = event.position - c1_ 
		
func _physics_process(delta):
	#OrcaUtils.test_randomized_bounded_lp_2()
	queue_redraw()
	return
	
	for i in range(len(fake_chars)):
		var f_c = fake_chars[i]
		var s_p = shortest_paths[i]
		move_along_direction(f_c, s_p, delta)
	
	OrcaUtils.set_velocities(fake_chars, shortest_paths, walls)
	
	#move_along_direction(
	#	fake_character,
	#	shortest_path,
	##	delta
	#)

		
var v = Vector2(-20, -20)
var pos = Vector2(200, 300)

#var c1_ = Vector2(250, 200)
var c1_ = Vector2(768.4091, 379.506)
var opt_v = Vector2(80,0)
	
func _draw():
	
	var area = [
		100*Vector2(0,0),
		100*Vector2(0,1),
		100*Vector2(1,1),
		100*Vector2(1,0)
	]
	
	var polys = [
		100*Vector2(0.5, 0.0),
		100*Vector2(0.5, 0.75),
		100*Vector2(1.2, 0.75),
		100*Vector2(1.2, 0.0)
	]
	
	var polys_1 = [
		100*Vector2(0.5, -0.5),
		100*Vector2(0.5, 0.75),
		100*Vector2(1.5, 0.75),
		100*Vector2(1.5, -0.5)
	]
	
	
	# Not working right now
	var polys_2 = [
		100*Vector2(0.5, -0.5),
		100*Vector2(0.5, 0.75),
		100*Vector2(0.75, 0.75),
		100*Vector2(0.75, -0.5)
	] 
	
	var polys_3 = [
		100*Vector2(-0.5, -0.5),
		100*Vector2(-0.5, 0.75),
		100*Vector2(0.75, 0.75),
		100*Vector2(0.75, -0.5)
	]
	
	var polys_4 = [
		100*Vector2(-0.5, 0.5),
		100*Vector2(-0.5, 0.75),
		100*Vector2(0.75, 0.75),
		100*Vector2(0.75, 0.5)
	]
	
	var polys_5 = [
		100*Vector2(-0.5, 0.5),
		100*Vector2(-0.5, 1.75),
		100*Vector2(0.75, 1.75),
		100*Vector2(0.75, 0.5)
	]
	
	var polys_6 = [
		100*Vector2(0.5, 0.5),
		100*Vector2(0.5, 1.75),
		100*Vector2(0.75, 1.75),
		100*Vector2(0.75, 0.5)
	]
	
	var polys_7 = [
		100*Vector2(0.5, 0.5),
		100*Vector2(0.5, 1.75),
		100*Vector2(1.75, 1.75),
		100*Vector2(1.75, 0.5)
	]
	
	var polys_8 = [
		100*Vector2(0.5, 0.25),
		100*Vector2(0.5, 0.75),
		100*Vector2(1.75, 0.75),
		100*Vector2(1.75, 0.25)
	]
	
	var polys_9 = [
		100*Vector2(-0.25, 0.50),
		100*Vector2(-0.25, 1.25),
		100*Vector2(1.25, 1.25),
		100*Vector2(1.25, -0.25),
		100*Vector2(0.75, 0.25),
		100*Vector2(0.8, 0.7),
		100*Vector2(0.6, 0.85),
		100*Vector2(0.25, 0.25)
	]
	
	var inner_polygon = [
		100*Vector2(0.25, 0.25),
		100*Vector2(0.25, 0.75),
		100*Vector2(0.75, 0.75),
		100*Vector2(0.75, 0.25)
	]
	
	var inner_polygon_2 = [
		100*Vector2(-0.1, -0.1),
		100*Vector2(0.0, 0.2),
		100*Vector2(0.2, 0.2),
		100*Vector2(0.2, -0.1)
	]
	
	var inner_polygon_3 = [
		100*Vector2(0.3, 0.1),
		100*Vector2(0.3, 0.2),
		100*Vector2(0.95, 0.2),
		100*Vector2(0.95, 0.1)
	]
	
	var used_polygon = inner_polygon
	
	#var new_area = PolygonUtils.reshape_area(area, used_polygon, 100 , 100)
	
	for i in range( area.size()):
		var next_i = (i+1) % area.size()
		draw_line(area[i] + Vector2(50,50), area[next_i] + Vector2(50,50), Color.RED, 3)
		
	for i in range( used_polygon.size()):
		var next_i = (i+1) % used_polygon.size()
		draw_line(used_polygon[i] + Vector2(50,50), used_polygon[next_i] + Vector2(50,50), Color.DARK_GREEN, 3)
	
	#var new_area = PolygonUtils.add_poylgon_inside_area(area, used_polygon)
	
	var new_area = PolygonUtils.extract_allowed_area([inner_polygon, inner_polygon_2, inner_polygon_3], 100, 100)
	
	for i in range( new_area.size()):
		var next_i = (i+1) % new_area.size()
		draw_line(new_area[i] + Vector2(50,50), new_area[next_i] + Vector2(50,50), Color.BLUE, 3)
	
	return
	
	var triangle_clockwise = [Vector2(0,0), Vector2(50,50), Vector2(100,0)]
	var triangle_counter_clockwise = [Vector2(0,0), Vector2(100,0), Vector2(50,50)]

	
	var lines = PolygonUtils.split_line_on_height([Vector2(5,5), Vector2(10,10), Vector2(15, 29)], 19.5, true)
	
	print(lines)
	
	var polygons = [] 
	
	for poly in $Poly.get_children():
		polygons.append(poly.polygon)
		
	PolygonUtils.order_clockwise(polygons)
	
	for poly in polygons:
		print(poly)
		print(PolygonUtils.clockwise_rotation(poly))
		draw_circle(poly[0],5, Color.BLUE)
		draw_circle(poly[1], 5, Color.GREEN)
	return
	
	#var radius = 8
	#var p1 = Vector2(500, 500)
	#var v1 = Vector2(1,0).normalized() * 100
	#var p2 = Vector2(550, 400)
	#var v2 = Vector2(0.8,1) * 100
	#var overlap = GeometryUtils.get_time_overlaps(p1, v1, p2, v2, 8)
	

	
	#draw_circle(p1, radius, Color.VIOLET)
	#draw_line(p1, p1 + v1, Color.BLUE, 3)
	
	#draw_circle(p2, radius, Color.VIOLET)
	#draw_line(p2, p2 + v2, Color.BLUE, 3)
	
	var l1 = Vector2(500,500)
	var l2 = Vector2(550,700)
	var p = Vector2(400, 600)
	var online = GeometryUtils.get_closest_point_on_line(l1, l2, p)
	
	draw_line(l1, l2, Color.BLUE)
	draw_circle(p, 5, Color.RED)
	draw_circle(online, 5, Color.RED)
	
	var p1 = Vector2(0, 0)
	var p2 = Vector2(-50, -50)
	
	var v_opt = Vector2(-50,100)
	
	var xs = OrcaUtils.closest_point_on_vo_boundary(
		p1,
		p2,
		8,
		8,
		10,
		v_opt
	)
	var shift = Vector2(250, 250)
	
	v_opt += shift
	
	var m1 = xs[0] + shift
	var m2 = xs[1] + shift
	var r1 = xs[2] 
	var r2 = xs[3] 
	var s1_up = xs[4] + shift
	var s2_up = xs[5] + shift
	var s1_down = xs[6] + shift
	var s2_down = xs[7] + shift
	var closest_point = xs[8] + shift
	var u = xs[9] + shift
	var n = xs[10] 

	
	#draw_circle(m1, r1, Color.DARK_GREEN)
	#draw_circle(m2, r2, Color.DARK_BLUE)
	#draw_circle(v_opt, 8, Color.DARK_VIOLET)
	#draw_circle(closest_point, 8, Color.DARK_RED)
	
	#draw_line(s1_up, s2_up, Color.VIOLET, 3)
	#draw_line(s1_down, s2_down, Color.VIOLET, 3)
	#draw_line(s1_down, s1_up, Color.VIOLET, 3)#
	#draw_circle(s2_up, 3, Color.GREEN)
	#draw_circle(s2_down, 3, Color.GREEN)
	
	#draw_line(s2_up, s2_down, Color.DARK_BLUE, 3)
	
	#var c_p = GeometryUtils.get_closest_point_on_line(s2_up, s2_down, m1)
	#draw_circle(c_p, 3, Color.RED)
	#draw_circle(m1, 3, Color.RED)
	#draw_line(closest_point, (closest_point + 20*n), Color.GHOST_WHITE, 3)
	
	#[m1, m2, r1, r2, s1_up, s2_up, s1_down, s2_down]
	#[m1, m2, r1, r2, s1_up, s2_up, s1_down, s2_down]
	
	#draw_circle(overlap, radius, Color.RED)
	
	for edge in edges:
		draw_circle(edge, 4, Color.BLUE)
		
	#if shortest_path:
		#draw_line(fake_character["position"], shortest_path[0], Color.RED)
		#for i in range(len(shortest_path) - 1):
		#	var start = shortest_path[i]
		#	var end = shortest_path[i+1]
		#	draw_line(start, end, Color.RED)
	
	
	for path in shortest_paths:
		if not path:
			continue 
		for i in range(len(path) - 1):
			var start = path[i]
			var end = path[i+1]
			draw_line(start, end, Color.RED)
	
	#var v_e_1 = position_to_visible_edges[Vector2(64, 64)]
	#var v_e_2 = position_to_visible_edges[Vector2(800, 400)]
	
	#for e in v_e_1:
	#	draw_circle(edges[e], 4, Color.WHITE)
		
	#for e in v_e_2:
	#	draw_circle(edges[e], 4, Color.RED)
	var color = Color.NAVY_BLUE
	
	if GeometryUtils.in_polygons_range(
		$Poly,
		8,
		fake_character["position"]
	):
		color = Color.RED
		
	#draw_circle(fake_character["position"], 8, color)
	
	for fake_char in fake_chars:
		draw_circle(fake_char["position"], 8, Color.NAVY_BLUE)
		draw_line(fake_char["position"], fake_char["position"] + fake_char["new_velocity"], Color.RED, 3 )
	
	if fake_character["local_path"]:
		var path = fake_character["local_path"]
		for i in range(len(path) -1):
			draw_line(path[i], path[i+1], Color.BLACK, 1)
	
	for polygon in occupied_polygons:
		for point in polygon:
			draw_circle(point, 2, Color.NAVY_BLUE)
	
	"""
	var obs_ps = [
		#Vector2(50, 50),
		#Vector2(75, 75),
		#Vector2(125, 75),
		Vector2(104, 104)
	]
	
	for p in obs_ps:
		draw_circle(p, 24, Color.NAVY_BLUE)
		
	draw_circle(Vector2(256, 256,), 8, Color.RED)
		
	for i in range(200):
		for j in range(200):
			var x = i * 16
			var y = j * 16
			var dir = VFUtils.get_dir(
				Vector2(x,y),
				obs_ps,
				Vector2(256,256),
				24
			)
			draw_line(Vector2(x,y), Vector2(x,y) + 8 * dir, Color.WHITE, 3)
			draw_circle(Vector2(x,y) + 8 * dir, 2, Color.RED)
	
	"""
	
	
	#var xss = OrcaUtils.test_intersection_with_circle()
	#var inter = xss[0]
	#var m = xss[1]
	#var r = xss[2]
	#var hp = xss[3]
	
	
	#draw_circle(m,r, Color.VIOLET)
	#draw_circle(inter["left"], 8, Color.GREEN)
	#draw_circle(inter["right"], 8, Color.RED)
	#draw_circle(m + r* hp.l_dir, 8, Color.GREEN)
	#draw_circle(m - r * hp.l_dir, 8, Color.RED)
	#draw_circle(inter["right"], 8, Color.RED)
	#draw_line(hp.p + 1000 * hp.l_dir, hp.p - 1000 * hp.l_dir, Color.CADET_BLUE, 3)
		
	#for pos in pos_to_walls:
	#	if pos_to_walls[pos]:
	#		draw_circle(pos, 2, Color.WHITE)
	#	for wall in pos_to_walls[pos]:
	#		draw_line(wall[0], wall[1], Color.GREEN, 3)
	
	#var pos_m = GeometryUtils.get_closest_mesh_position(fake_character["position"])
	#var actor_positions = []
	#for i in range(9):
	#	for j in range(9):
	#		var delta_pos = Vector2((i-4)*8, (j-4)*8) + pos_m
	#		if not delta_pos in actor_position_mesh:
	#			continue
	#		var actors = actor_position_mesh[delta_pos]
	#		actor_positions.append_array(actors)

	
	for f_c in fake_characters:
		draw_circle(f_c, 8, Color.DARK_VIOLET)
		#var square = generate_sourounding_square(f_c, 16, Vector2(1,0))
		#draw_polyline(square, Color.RED, 1)
		#draw_line(square[0], square[3], Color.RED, 1)
		#var square2 = generate_sourounding_square(f_c, 24, Vector2(1,0))
		#draw_polyline(square2, Color.BLUE, 1)
		#draw_line(square2[0], square2[3], Color.BLUE, 1)
	
	"""
	var pos = fake_character["position"]
	var f_c_pos = GeometryUtils.get_closest_mesh_position(pos)
	if f_c_pos in pos_to_walls:
		for wall in pos_to_walls[f_c_pos]:
			var dir = generate_wall_velocity(pos, wall, 15)
			draw_line(pos, pos + 30 * dir, Color.RED, 3)
	"""
	
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
	
	var c1 = Vector2(500, 500)
	var c2 = Vector2(550, 600)
	var radius = 25
	
	#draw_circle(c1/2, radius/2, Color.WHITE)
	#draw_circle(c2/2, radius/2, Color.WHITE)
	
	#var qs = OrcaUtils.determine_closest_point_on_wall_v_object(Vector2(0,0), c1, c2, radius, v, 2)
	#draw_line(qs[0], 2 * qs[0]  , Color.WHITE, 3)
	#draw_line(qs[1], 2 * qs[1], Color.WHITE, 3)
	#draw_line(qs[0], qs[1], Color.WHITE, 3)
	#draw_line(qs[4], qs[5], Color.WHITE, 3)
	
	#draw_circle(v, 5, Color.INDIGO)
	#draw_circle(qs[2], 5, Color.RED)
	#draw_line(qs[2], qs[2] + qs[3]*16, Color.OLIVE, 3)
	
	var w1 = Vector2(200, 200)
	var w2 = Vector2(500, 210)
	var w3 = Vector2(450, 600)
	
	
	var qq = OrcaUtils.determine_closest_point_on_wall_segment(
		pos,
		w1,
		w2,
		8,
		v,
		1
	)
	
	draw_line(
		w1,
		w2,
		Color.BLACK,
		3
	)
	

	
	var qq2 = OrcaUtils.determine_closest_point_on_wall_segment(
		pos,
		w2,
		w3,
		8,
		v,
		1
	)
	
	draw_line(
		w2,
		w3,
		Color.BLACK,
		3
	)
	

	
	draw_circle(
		pos,
		8,
		Color.DARK_MAGENTA
	)
	
	draw_line(
		pos,
		pos + v,
		Color.DARK_RED,
		3
	)
	
	var hps : Array[OrcaUtils.HalfPlane] = []
	
	if qq:
		var u_n = qq[0]
		var n_n = qq[1]
		
		draw_circle(pos + u_n + v, 8, Color.YELLOW_GREEN)
		var half_plane = OrcaUtils.HalfPlane.new(
			v +  u_n,
			n_n.rotated(-PI/2),
			n_n
		)
		draw_line(pos + u_n + v, pos + u_n + v + 16 * n_n, Color.WHITE, 3)
		draw_line(pos + qq[2], pos + qq[3], Color.WHITE, 3)
		
		hps.append(half_plane)
	
	if qq2:
		var u_n = qq2[0]
		var n_n = qq2[1]
		
		draw_circle(pos + u_n + v, 8, Color.YELLOW_GREEN)
		var half_plane = OrcaUtils.HalfPlane.new(
			v +  u_n,
			n_n.rotated(-PI/2),
			n_n
		)
		draw_line(pos + u_n + v, pos + u_n + v + 16 * n_n, Color.WHITE, 3)
		draw_line(pos + qq2[2], pos + qq2[3], Color.WHITE, 3)
		
		hps.append(half_plane)
	
	if not qq and not qq2:
		var vs = OrcaUtils.determine_closest_edge_point(pos, w2, 8, v, 1, [w1 - pos, w3 - pos])
		var u_n = vs[0]
		var n_n = vs[1]
		
		var half_plane = OrcaUtils.HalfPlane.new(
			v +  u_n,
			n_n.rotated(-PI/2),
			n_n
		)
		draw_line(pos + u_n + v, pos + u_n + v + 16 * n_n, Color.WHITE, 3)
		#draw_line(pos + qq2[2], pos + qq2[3], Color.WHITE, 3)
		
		hps.append(half_plane)
		
		if len(vs) == 4:
			var half_plane2 = OrcaUtils.HalfPlane.new(
				v +  vs[2],
				vs[3].rotated(-PI/2),
				vs[3]
			)
			hps.append(half_plane2)
			
			draw_line(pos + vs[2] + v, pos + vs[2] + v + 16 * vs[3], Color.WHITE, 3)
		
				
	var velocity = OrcaUtils.randomized_bounded_lp(hps,  v, v, 50)
	
	if not velocity:
		velocity = Vector2(0,0)
	
	draw_line(pos, pos + velocity, Color.BLUE, 3)
	
	draw_circle(w3, 8, Color.FIREBRICK)
	#var vs = OrcaUtils.determine_closest_edge_point(pos, w2, 8, v, 1, [w1 - pos, w3 - pos])
	
	#draw_circle(pos + vs[0] + v, 8, Color.YELLOW)
	
	
	return
	
	var qs = OrcaUtils.determine_closest_point_on_wall_v_object(
		pos,
		w1,
		w2,
		8,
		v,
		1
	)
	
	var qs_2 = OrcaUtils.determine_closest_point_on_wall_v_object(
		pos,
		w2,
		w3,
		8,
		v,
		1
	)
	
	#draw_circle(pos, 8, Color.WHITE)
	
	draw_line(
		w1,
		w2,
		Color.BLUE,
		3
	)
	
	draw_line(
		w2,
		w3,
		Color.BLUE,
		3
	)
	
	
	
	return
	
	var u2 = qs[2]
	var n2 = qs[3]
	
	draw_line(pos , pos + v, Color.AQUA)
	draw_line(pos + v, pos + v + u2, Color.RED)
	draw_line(pos + qs[4], pos + qs[5], Color.WHITE, 3)
	
	draw_circle(w1, 8,  Color.NAVY_BLUE)
	draw_circle(w2, 8,  Color.NAVY_BLUE)
	
	draw_line(pos + v + u2, pos + v + u2 + n2*20, Color.WHITE)
	draw_circle(pos + qs[1], 5, Color.RED)
	draw_circle(pos + qs[0], 5, Color.RED)
	draw_line(pos + qs[0], pos + 100 * qs[0], Color.WHITE, 3)
	draw_line(pos + qs[1], pos + 100 * qs[1], Color.WHITE, 3)
	draw_circle(pos + v + u2 + n2*20, 4,  Color.NAVY_BLUE)
	
	var half_plane = OrcaUtils.HalfPlane.new(
		v +  u2,
		n2.rotated(-PI/2),
		n2
	)
	
	
	u2 = qs_2[2]
	n2 = qs_2[3]
	
	
	var half_plane_2 = OrcaUtils.HalfPlane.new(
		v +  u2,
		n2.rotated(-PI/2),
		n2
	)
	
	draw_line(pos , pos + v, Color.AQUA)
	draw_line(pos + v, pos + v + u2, Color.RED)
	draw_line(pos + qs_2[4], pos + qs_2[5], Color.WHITE, 3)
	
	draw_circle(w2, 8,  Color.NAVY_BLUE)
	draw_circle(w3, 8,  Color.NAVY_BLUE)
	
	draw_line(pos + v + u2, pos + v + u2 + n2 * 20, Color.WHITE)
	draw_circle(pos + qs_2[1], 5, Color.RED)
	draw_circle(pos + qs_2[0], 5, Color.RED)
	draw_line(pos + qs_2[0], pos + 100 * qs_2[0], Color.WHITE, 3)
	draw_line(pos + qs_2[1], pos + 100 * qs_2[1], Color.WHITE, 3)
	draw_circle(pos + v + u2 + n2 * 20, 4,  Color.NAVY_BLUE)
	
	draw_circle(pos, 8, Color.RED)
	
	var new_velocity = OrcaUtils.randomized_bounded_lp(
		[half_plane, half_plane_2],
		v,
		v,
		50
	)
	
	
	if not new_velocity:
		new_velocity = Vector2(0,0)
		
	draw_line(pos, pos + new_velocity, Color.VIOLET, 3)
	
	#OrcaUtils.test_find_opt_v()
	
	
	var o_dir = Vector2(1, 1)
	var p_dir = Vector2(0, -1).normalized()
	
	var orientation = o_dir.x
	
	
	#var a = Vector2(0,1)
	#var b = Vector2(1,0)
	#var c = Vector2(-1,0)
	#var alpha = a.angle_to(c)
	#var beta = b.angle_to(c)
	var dir = Vector2(2,-1)
		
	var hp = OrcaUtils.HalfPlane.new(
		Vector2(550, 240),
		dir.rotated(PI/2),
		dir	
	)
	

	#dir.y *= -1
	#var orient = dir.x
	
	var angle = GeometryUtils.polar_angle(dir)
	
	for i in range(361):
		var dir_2 = Vector2(cos(i), sin(i))
		
		var hp2 = OrcaUtils.HalfPlane.new(
			Vector2(550, 240),
			dir_2.rotated(PI/2),
			dir_2	
		)
		
		#var o_2 = dir_2.x
		#if o_2 < 0:
		#	dir_2 = -dir_2
		
		#var ang2 = GeometryUtils.polar_angle(dir_2)
		
		var c = Color.GREEN
		
		
		if OrcaUtils.right_bounded(hp, hp2):
			c = Color.RED
		#if ang2 > angle  and dir.y < 0:
		#	c = Color.RED
		#if ang2 < angle  and dir.y > 0:
		#	c = Color.RED
		
		dir_2.y *= -1
		
		dir_2 = dir_2.rotated(PI/2)
			
		var pos_1 = Vector2(550, 240) - dir_2 * 100
		var pos_2 = Vector2(550, 240) + dir_2 * 100
		
		#draw_line(pos_1, pos_2, c, 1)
	
	#var pos_1 =  Vector2(550, 240) - dir * 100
	#var pos_2 =  Vector2(550, 240) + dir * 100
	#draw_line(pos_1, pos_2, Color.BLUE, 3)
		
		
	#var orientation_2 = half_plane.p_dir.x
	#var o_dir = org_plane.p_dir
	var switch = false
	if orientation < 0:
		p_dir = - p_dir
		switch = true
	#if orientation_2 < 0:
	
	var r1_ = 8
	var r2_ = 8
	var r3_ = 8
	
	var tau_ = 1.0
	
	
	#[m1, m2, r1, r2, s3_up, s2_up, s3_down, s2_down, closest_point, u, n]
	
	draw_circle(c1_, 8, Color.NAVY_BLUE)
	
	var c2_ = Vector2(300, 200)
	var c3_ = Vector2(320, 210)
	var c4_ = Vector2(340, 220)
	var c5_ = Vector2(380, 240)
	var c6_ = Vector2(752.8511, 383.3361)
	
	var cs_ = [c2_, c3_, c4_, c5_, c6_]
	
	var hps_ : Array[OrcaUtils.HalfPlane] = []
	
	for c in cs_:
	
		draw_circle(c, 16, Color.INDIGO)
	
		#var xxs = OrcaUtils.closest_point_on_vo_boundary(
		#	c1_,
		#	c,
		#	r1_,
		#	r2_,
		#	tau_,
		#	opt_v
		#)
	
		#[m1, m2, r1, r2, s3_up, s2_up, s3_down, s2_down, closest_point, u, n]
	
		#draw_circle(c +  xxs[8],4, Color.YELLOW )
	
		var ts = OrcaUtils.closest_point_on_vo_boundary_2(
			c1_,
			c,
			r1_,
			r2_,
			1,
			opt_v
		)
	
		draw_circle(c1_ + ts[0], 2, Color.YELLOW)
		draw_circle(c1_ + ts[1], 2, Color.YELLOW)
		draw_line(c1_ + ts[2] + opt_v, c1_ + opt_v + ts[2] + 20 * ts[3], Color.RED, 1)
		draw_circle(c1_ + opt_v + ts[2] + 20 * ts[3], 4, Color.BLUE)
		draw_line(c1_ + ts[0], c1_ + ts[0]*10000, Color.WHITE, 3)
		draw_line(c1_ + ts[1], c1_ + ts[1]*10000, Color.WHITE, 3)	
		draw_line(c1_, c1_ + opt_v, Color.VIOLET, 2)
	
		var hp_ = OrcaUtils.HalfPlane.new(
			opt_v + ts[2],
			ts[3].rotated(PI/2),
			ts[3]
		)
		
		hps_.append(hp_)
	
		draw_line(c1_ + ts[2] + opt_v, c1_ + ts[2] + opt_v + ts[3].rotated(PI/2) * 50, Color.RED, 3)
		draw_line(c1_ + ts[2] + opt_v, c1_ + ts[2] + opt_v - ts[3].rotated(PI/2) * 50, Color.RED, 3)
	
	var v_ = OrcaUtils.randomized_bounded_lp(
		hps_,
		opt_v,
		opt_v,
		50
	)
	
	if not v_:
		v_ = Vector2(0,0)
	#print("outside_v")
	#print(hp_.p)
	#print(v_)
	#print(v_)
	
	draw_line(
		c1_,
		c1_ + v_,
		Color.LAWN_GREEN,
		3
	)
	
	var agent_1 = {
		"position": Vector2(177.6088, 312.1458),
		"new_velocity": Vector2(0,0),
		"opt_velocity":Vector2(-4.745203, 49.77432)
	}
	
	var agent_2 = {
		"position": Vector2(163.3748, 304.0786),
		"new_velocity": Vector2(0,0),
		"opt_velocity":Vector2(11.27111, 48.71306)
	}
	
	"""
	var paths = agent_1["position]
	
	OrcaUtils.set_velocities(
		[agent_1, agent_2],
		[]
	)
	"""
	
	var v = OrcaUtils.closest_point_on_vo_boundary_2(
		Vector2(483.7, 401.763),
		Vector2(499.079, 406.179),
		8,
		8,
		1,
		Vector2(38.987, 31.305)
	)
	print(Vector2(483.7, 401.763).distance_to(Vector2(499.079, 406.179)))
	
	print(v)
