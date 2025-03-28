extends Node2D

var navigation_server : NavigationServer

var adjusted_polygons

var visibile_corners

var observer

var lines

var area

var areas 

var wall = [Vector2(380,250), Vector2(400, 350)]

var pos = Vector2(300, 300)

var wall_normals = []

#var edge_boxes

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	navigation_server = NavigationServer.new()
	
	navigation_server.setup_mesh_data($Polygons, "wall_map_new_new")
	
	var mesh_data = navigation_server.mesh_data
	
	for entry in mesh_data.grid_position_to_walls:
		for k in mesh_data.grid_position_to_walls[entry]:
			for wall in mesh_data.grid_position_to_walls[entry][k]:
				var mid_point = (wall[0] + wall[1])/2
				wall_normals.append([mid_point, mid_point + 16 * wall[2]])
					
	adjusted_polygons = VisibilityHelper.adjust_polygons(
		mesh_data.polygons,
		1152,
		648
	)
	
	observer = mesh_data.corners[19]
	
	visibile_corners = VisibilityHelper.get_visible_corners_for_observer(
		adjusted_polygons,
		observer,
		1152,
		648
	)
	
	lines = VisibilityHelper.generate_view_lines(
		observer,
		adjusted_polygons,
		visibile_corners["visible_corners"],
		1152,
		648
	)
	
	
	area = VisibilityHelper.gernerate_visible_area(
		observer,
		adjusted_polygons,
		visibile_corners,
		1152,
		648
	)
	
	areas = VisibilityHelper.generate_visible_areas(
		mesh_data.corners,
		mesh_data.polygons,
		1152,
		648
	)
	
	area = areas[0]
	
	
	
	
	#print(mesh_data.edges_to_path)
	
	#print(new_data == old)
	
	#for key in old:
	#	for key_2 in old[key]:
	#		if old[key][key_2] != new_data[key][key_2]:
	#			print()
	#			print("old")
	#			print(old[key][key_2])
	#			print("new")
	#			print(new_data[key][key_2])

	for actor in $Actors.get_children():
		navigation_server.register_agent(actor, 50, 150,8)
		navigation_server.set_agent_destination(actor, Vector2(1079, 264))
		#break
	
	for actor in $Actors2.get_children():
		#break
		navigation_server.register_agent(actor, 50, 150, 12)
		navigation_server.set_agent_destination(actor, Vector2(300, 264))
	


func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				for actor in $Actors.get_children():
					navigation_server.set_agent_destination(actor, event.position)
					#break
			MOUSE_BUTTON_RIGHT:
				for actor in $Actors2.get_children():
					#break
					navigation_server.set_agent_destination(actor, event.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	queue_redraw()
	#queue_redraw()

func _physics_process(delta):
	queue_redraw()
	navigation_server._physics_process(delta)

func _draw():
	var mesh_data : MeshData = navigation_server.mesh_data



	for h in mesh_data.convex_polygons.size():
		var poly = mesh_data.convex_polygons[h]
		#var region = mesh_data.polygon_regions[h]
		for i in poly.size():
			var p1 = poly[i]
			var p2 = poly[(i+1) % poly.size()]
			var color = Color.BLACK
			var size = 3
			draw_line(p1, p2, color, size)

	for h in mesh_data.obstacles.size():
		var poly = mesh_data.obstacles[h]
		for i in poly.size():
			var p1 = poly[i]
			var p2 = poly[(i+1) % poly.size()]
			var color = Color.VIOLET
			var size = 6
			draw_line(p1, p2, color, size)
	
	for h in mesh_data.occupied_polygons.size():
		var poly = mesh_data.occupied_polygons[h]
		for i in poly.size():
			var p1 = poly[i]
			var p2 = poly[(i+1) % poly.size()]
			var color = Color.WHITE
			var size = 3
			draw_line(p1, p2, color, size)
	
	for h in mesh_data.polygons.size():
		var poly = mesh_data.occupied_polygons[h]
		for i in poly.size():
			var p1 = poly[i]
			var p2 = poly[(i+1) % poly.size()]
			var color = Color.BLACK
			var size = 3
			draw_line(p1, p2, color, size)
	
	"""
	for box in mesh_data.edge_boxes:
		draw_line(
			box[0],
			box[1],
			Color.BLUE,
			5
		)
	"""
	
	for i in mesh_data.edges_to_path:
		break
		for j in mesh_data.edges_to_path[i]:
			var path = mesh_data.edges_to_path[i][j]
			for k in len(path) - 1:
				draw_line(path[k], path[k+1], Color.WHITE, 3)
	
	for corner in mesh_data.corners:
		draw_circle(corner, 3, Color.RED)
	"""
	for i in mesh_data.visibility_polygons[0].size():
		var p1 = mesh_data.visibility_polygons[0][i]
		var p2 = mesh_data.visibility_polygons[0][(i+1) % mesh_data.visibility_polygons[0].size()]
		draw_line(p1, p2, Color.DARK_BLUE, 6)
	draw_circle(mesh_data.corners[0], 6, Color.GREEN)
	"""
	"""
	for polygon in adjusted_polygons:
		for i in polygon.size():
			var p1 = polygon[i]
			var p2 = polygon[(i+1) % polygon.size()]
			draw_circle(p1, 8, Color.RED)
			draw_circle(p2, 8, Color.RED)
			draw_line(p1, p2, Color.DARK_BLUE, 6)
	"""
	
	for agent_id in navigation_server.agent_id_to_agent_data:
		var agent_data = navigation_server.agent_id_to_agent_data[agent_id]
		var pos = agent_data["agent"].position
		var path = agent_data["shortest_path"]
		
		if path:
			draw_line(pos, path[0], Color.VIOLET)
			
		draw_circle(
			pos,
			agent_data["radius"],
			Color.BLACK
		)
	
	var radius = 20
	
	draw_line(wall[0], wall[1], Color.BLUE, 4)
	draw_circle(pos, radius, Color.YELLOW )
	
	var opt_velocity = Vector2(50, 80)
	
	for normal in wall_normals:
		draw_line(normal[0], normal[1], Color.GREEN, 2)
	
	"""
	var points = OrcaUtils.closest_point_on_wall_boundary(
		pos,
		wall,
		radius,
		1,
		opt_velocity
	)
	"""
	#draw_line(pos, pos + opt_velocity, Color.WEB_PURPLE, 2)
	
	#[p1, p2, t1_dir, t2_dir, p1_t, p2_t]
	# 0   1    2        3       4    5    6    7   8   9
	#[p1, p2, t1_dir, t2_dir, p1_t, p2_t, t1 , t2, c1, c2]
	"""
	var p1 = pos + points[0]
	var p2 = pos + points[1]
	
	
	var t1_dir = points[2]
	var t2_dir = points[3]
	
	var p1_t = pos + points[4]
	var p2_t = pos + points[5]
	
	var t1 = pos + points[6]
	var t2 = pos + points[7]
	
	var c1 = pos + points[8]
	var c2 = pos + points[9]
	
	var u_velocity = pos + points[10]
	var normal = u_velocity + 16* points[11]
	
	#draw_circle(p1, 2, Color.NAVAJO_WHITE)
	#draw_circle(p2, 2, Color.NAVAJO_WHITE)
	draw_circle(c1, radius, Color.WHITE)
	draw_circle(c2, radius, Color.WHITE)
	draw_circle(c1, 2, Color.RED)
	draw_circle(c2, 2, Color.RED)
	draw_line(p1_t, p1_t + 1000 * t1_dir, Color.DARK_RED, 2)
	draw_line(p2_t, p2_t + 1000 * t2_dir, Color.DARK_BLUE, 2)
	draw_circle(p1_t, 2, Color.DARK_RED)
	draw_circle(p2_t, 2, Color.DARK_BLUE)
	
	draw_circle(t1, 2, Color.DARK_RED)
	draw_circle(t2, 2, Color.DARK_BLUE)    
	draw_line(p1, p2, Color.WHITE, 2)
	
	draw_circle(u_velocity, 3, Color.RED)
	draw_line(u_velocity, normal, Color.WHITE, 2)
	"""
