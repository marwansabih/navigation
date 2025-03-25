extends Node2D

var navigation_server : NavigationServer

var adjusted_polygons

var visibile_corners

var observer

var lines

var area

var areas 

#var edge_boxes

# Called when the node enters the scene tree for the first time.
func _ready():

	navigation_server = NavigationServer.new()
	navigation_server.setup_mesh_data($Polygons, "test_map")
	
	print("corners_old")
	print(navigation_server.mesh_data.corners)
	
	var mesh_data = navigation_server.mesh_data
	
	#print(mesh_data.edges_to_dist)
	var old = mesh_data.edges_to_path.duplicate()
	#var l_polygons = navigation_server.mesh_data.obstacles
	#edge_boxes = PolygonUtils.generate_polygon_edge_boxes(l_polygons)
	
	navigation_server.setup_mesh_data($Polygons, "test_map_4")
	
	var new_data = navigation_server.mesh_data.edges_to_path
	
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
	
	print("areas")
	print(areas)
	area = areas[0]
	
	
	print("visible corners")
	print(visibile_corners)
	
	print("adjusted polygons")
	print(adjusted_polygons)
	
	print("corners_new")
	print(navigation_server.mesh_data.corners)
	
	
	
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
		navigation_server.register_agent(actor, 50, 50,8)
		navigation_server.set_agent_destination(actor, Vector2(1079, 264))
		#break
	
	for actor in $Actors2.get_children():
		#break
		navigation_server.register_agent(actor, 50, 50, 12)
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
	
	for polygon in adjusted_polygons:
		print("draw polygon")
		print(polygon)
		for i in polygon.size():
			var p1 = polygon[i]
			var p2 = polygon[(i+1) % polygon.size()]
			draw_circle(p1, 8, Color.RED)
			draw_circle(p2, 8, Color.RED)
			draw_line(p1, p2, Color.DARK_BLUE, 6)
		
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
	
	draw_circle(
		observer,
		6,
		Color.BLUE_VIOLET
	)	
	
	for visible_corner in visibile_corners["visible_corners"]:
		draw_circle(
			visible_corner,
			6,
			Color.ORANGE
		)
		
	for line in lines:
		if not line:
			continue
		draw_line(
			line[0],
			line[1],
			Color.DARK_GOLDENROD,
			5
		)
		
	# Generate and draw view lines
	for point in visibile_corners["visible_corners"]:
		var line = VisibilityHelper.generate_view_line(observer, point, 1152, 648)
		if line.size() == 2:
			draw_circle(point, 5, Color(0, 1, 0))  # Mark the start point
			draw_line(line[0], line[1], Color(1, 0, 0), 2)  # Draw the view line
			draw_circle(line[1], 5, Color(0, 0, 1))  # Mark the intersection point
		
		"""
		draw_line(
			pos,
			pos + agent_data["new_velocity"],
			Color.RED,
			3
		)
		"""
	for i in area.size():
		var point = area[i]
		var next_point = area[(i+1) % area.size()]
		draw_line(
			point,
			next_point,
			Color.RED,
			5
		)

