extends Node2D

var navigation_server : NavigationServer

#var edge_boxes

# Called when the node enters the scene tree for the first time.
func _ready():

	navigation_server = NavigationServer.new()
	navigation_server.setup_mesh_data($Polygons, "test_map")

	#var l_polygons = navigation_server.mesh_data.obstacles
	#edge_boxes = PolygonUtils.generate_polygon_edge_boxes(l_polygons)


	for actor in $Actors.get_children():
		navigation_server.register_agent(actor, 50, 20,8)
		navigation_server.set_agent_destination(actor, Vector2(1079, 264))
	
	for actor in $Actors2.get_children():
		navigation_server.register_agent(actor, 50, 20, 8)
		navigation_server.set_agent_destination(actor, Vector2(300, 264))
	


func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				for actor in $Actors.get_children():
					navigation_server.set_agent_destination(actor, event.position)
			MOUSE_BUTTON_RIGHT:
				for actor in $Actors2.get_children():
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

	for corner in mesh_data.corners:
		draw_circle(corner, 3, Color.WHITE)

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
			var size = 6
			draw_line(p1, p2, color, size)


	for box in mesh_data.edge_boxes:
		draw_line(
			box[0],
			box[1],
			Color.BLUE,
			5
		)
		
	var l1 = Vector2(300,200)
	var l2 = Vector2(380,210)
	if PolygonUtils.cuts_edge_boxs(
		l1,
		l2,
		mesh_data.edge_boxes
	):
		draw_line(
			l1,
			l2,
			Color.RED,
			10
		)
	else:
		draw_line(
			l1,
			l2,
			Color.BLUE,
			10
		)

	for agent_id in navigation_server.agent_id_to_agent_data:
		var agent_data = navigation_server.agent_id_to_agent_data[agent_id]
		var pos = agent_data["agent"].position
		var path = agent_data["shortest_path"]
		
		if path:
			draw_line(pos, path[0], Color.BLUE)
			
		draw_circle(
			pos,
			agent_data["radius"],
			Color.BLACK
		)		
		
		continue
		"""
		var walls = OrcaUtils.get_close_walls(
			pos,
			mesh_data.grid_position_to_walls,
			mesh_data.current_max_wall_vision
		)
		if walls == []:
			print("no walls found")
		#print(walls)

		for wall in walls:
			draw_line(
				wall[0],
				wall[1],
				Color.RED,
				4
			)
			var w_p = GeometryUtils.get_closest_point_on_line(
				wall[0],
				wall[1],
				pos
			)
			draw_circle(
				w_p,
				5,
				Color.BLACK
			)

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

		"""

