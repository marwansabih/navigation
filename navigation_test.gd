extends Node2D

var navigation_server : NavigationServer

#var edge_boxes

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	navigation_server = NavigationServer.new()
	
	navigation_server.setup_mesh_data($Polygons, "wall_map_new_new")

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

	for h in mesh_data.obstacles.size():
		break
		var poly = mesh_data.obstacles[h]
		for i in poly.size():
			var p1 = poly[i]
			var p2 = poly[(i+1) % poly.size()]
			var color = Color.VIOLET
			var size = 6
			draw_line(p1, p2, color, size)
	
	for h in mesh_data.occupied_polygons.size():
		break
		var poly = mesh_data.occupied_polygons[h]
		for i in poly.size():
			var p1 = poly[i]
			var p2 = poly[(i+1) % poly.size()]
			var color = Color.WHITE
			var size = 3
			draw_line(p1, p2, color, size)
	
	for h in mesh_data.polygons.size():
		break
		var poly = mesh_data.occupied_polygons[h]
		for i in poly.size():
			var p1 = poly[i]
			var p2 = poly[(i+1) % poly.size()]
			var color = Color.BLACK
			var size = 3
			draw_line(p1, p2, color, size)
	
	
	for i in mesh_data.edges_to_path:
		break
		for j in mesh_data.edges_to_path[i]:
			var path = mesh_data.edges_to_path[i][j]
			for k in len(path) - 1:
				draw_line(path[k], path[k+1], Color.WHITE, 3)
	
	#for corner in mesh_data.corners:
	#	draw_circle(corner, 3, Color.RED)
	
	for agent_id in navigation_server.agent_id_to_agent_data:
		var agent_data = navigation_server.agent_id_to_agent_data[agent_id]
		var pos = agent_data["agent"].position
		#var path = agent_data["shortest_path"]
		
		#if path:
		#	draw_line(pos, path[0], Color.BLUE)
			
		draw_circle(
			pos,
			agent_data["radius"],
			Color.BLACK
		)
	
	
