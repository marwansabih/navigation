extends Node2D

var navigation_server : NavigationServer

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var p = PolygonUtils._intersection_with_line(
		Vector2( 5, 0.5),
		Vector2( -5, 0.6),
		0,
		1,
		0,
		1
	)
	print(p)
	
	var min_x = 0
	var max_x = 400
	var min_y = 0
	var max_y = 400
	var obstacle_dict = {}
	
	#PolygonUtils.generate_obstacle_dict(
	#	obstacle_dict,
	#	[],
	#	min_x,
	#	max_x,
	#	min_y,
	#	max_y,
	#	8
	#)
	
	#print(obstacle_dict)
	
	#var entry = PolygonUtils.get_entry_from_map(
	#	obstacle_dict,
	#	Vector2(50, 50),
	#	0,
	#	400,
	#	0,
	#	400,
	#	8
	#)
	#sprint(entry)
	
	navigation_server = NavigationServer.new()
	navigation_server.setup_mesh_data($Polygons, "test_map")
	print(navigation_server.mesh_data.obstacle_map)
	
	for actor in $Actors.get_children():
		navigation_server.register_agent(actor, 50, 200)
		navigation_server.set_agent_destination(actor, Vector2(1079, 264))


func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				for actor in $Actors.get_children():
					navigation_server.set_agent_destination(actor, event.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#queue_redraw()
	
func _physics_process(delta):
	navigation_server._physics_process(delta)
	queue_redraw()
	
func _draw():
	var mesh_data : MeshData = navigation_server.mesh_data
	
	for corner in mesh_data.corners:
		draw_circle(corner, 3, Color.WHITE)
		
	for h in mesh_data.convex_polygons.size():
		var poly = mesh_data.convex_polygons[h]
		var region = mesh_data.polygon_regions[h]
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
	
	
	for agent_id in navigation_server.agent_id_to_agent_data:
		var agent_data = navigation_server.agent_id_to_agent_data[agent_id]
		var pos = agent_data["agent"].position
		var path = agent_data["shortest_path"]
		print(len(path))
		if not path:
			continue
		draw_line(pos, path[0], Color.BLUE)
		var in_range = OrcaUtils.in_wall_range(
			pos,
			mesh_data.grid_position_to_walls
		)
		if in_range:
			draw_circle(
				pos,
				16,
				Color.RED
			)
	
	for x in mesh_data.grid_position_to_walls:
		for y in mesh_data.grid_position_to_walls[x]:
			var walls = mesh_data.grid_position_to_walls[x][y]
			var x_dim = mesh_data.grid_position_to_walls.size()
			var y_dim = mesh_data.grid_position_to_walls[x].size()
			var r_color = Color(float(x)/x_dim, float(y)/y_dim, (float(x) +  float(y))/(x_dim+ y_dim))
			if walls:
				var rect = Rect2(x*32, y* 32, 32, 32)
				#draw_rect(rect, r_color)
				draw_circle(
					Vector2(x*32, y* 32),
					4,
					r_color
				)
			else:
				draw_circle(
					Vector2(x*32, y* 32),
					4,
					Color.BLUE
				)
			
			for wall in walls:
				draw_line(
					wall[0],
					wall[1],
					r_color,
					10					
				)
