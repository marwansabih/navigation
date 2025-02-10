class_name NavigationServer

extends Node


#TODO Fix problem with convex polygon generation
#TODO Better version of position access in agent_data
#TODO Fix saving "created halfplanes"

var mesh_data
var agent_id_to_agent_data = {}
var mesh_grid_size = 1

func setup_mesh_data(obstacle_region, id):
	
	mesh_data = MeshData.new()
	mesh_data.setup_mesh_data(obstacle_region, id)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func register_agent(
	agent,
	velocity: float,
	delta_v: float
):	
	var agent_id = agent.get_instance_id()
	var agent_data = {
		"velocity" = velocity,
		"agent" = agent,
		"dir" = null,
		"org_dir" = Vector2(0,0),
		"local_path" = null,
		"destination" = null,
		"idx" = len(agent_id_to_agent_data)
	}
	
	agent_id_to_agent_data[agent_id] = agent_data
	
func set_agent_destination(
	agent,
	destination: Vector2
):
	var agent_id = agent.get_instance_id()
	agent_id_to_agent_data[agent_id]["destination"] = destination
	set_shortest_path(false)

var cycle = 0
func _physics_process(delta):
	#print(cycle)
	cycle += 1
	set_shortest_path(true)
	
	OrcaUtils.set_velocities_2(
		agent_id_to_agent_data,
		mesh_data.convex_polygons,
		mesh_data.polygon_regions,
		mesh_data.polygon_neighbours_dict,
		mesh_data.polygon_corner_neighbour_dict,
		mesh_data.pos_to_region,
		mesh_data.grid_position_to_walls
	)
	move_actors(delta)
	

func set_shortest_path(forced):
	var new_cycle = cycle % (agent_id_to_agent_data.size() * 4)
	
	for agent_id in agent_id_to_agent_data:
		var agent_data = agent_id_to_agent_data[agent_id]
		if not new_cycle == agent_data["idx"] and cycle > 10 and not forced:
			continue
		if not agent_data["destination"]:
			continue
			
		var short_path = shortest_path_between_positions(
			agent_data["agent"].position,
			agent_data["destination"]
		)
		
		if not short_path:
			short_path = agent_data["last_shortest_path"]
		
		agent_data["last_shortest_path"] = short_path
		
		if short_path and len(short_path) > 1:
			var pos = agent_data["agent"].position
			var dist =  pos.distance_to(short_path[0])
			if dist < 3:
				short_path.pop_front()
		
		agent_data["shortest_path"] = short_path


func shortest_path_between_positions(
	p1: Vector2,
	p2: Vector2
):
	
	"""
	var dir = p2 - p1
	
	var region_idx = -1
	
	var neighbour_idx = -1
	
	for i in mesh_data.convex_polygons.size():
		var p = mesh_data.convex_polygons[i]
		var p1_inside = PolygonUtils.in_polygon(p, p1)
		var p2_inside = PolygonUtils.in_polygon(p, p2)
		if p1_inside:
			region_idx = i
		if p2_inside:
			neighbour_idx = i
		if p1_inside and p2_inside:
			return [p2]
	
	if region_idx == -1:
		mesh_data.polygon_neighbours_dict[region_idx] = []
	for wall_idx in mesh_data.polygon_neighbours_dict[region_idx]:
		if mesh_data.polygon_neighbours_dict[region_idx][wall_idx] == neighbour_idx:
			return [p2]
	"""	
	
	
	if not PolygonUtils.cuts_edge_boxs(
		p1,
		p2,
		mesh_data.edge_boxes
	):
		return [p2]
	
	"""
	
	var d = dir.rotated(PI/2).normalized()
	
	#var criterea_1 = intersect_with_occupied_polygons(p1 + d * 12, p2 + d*9)
	#var criterea_2 = intersect_with_occupied_polygons(p1 - d * 12, p2 - d*9)
	#dirty but fast
	var criterea_3 = intersect_with_occupied_polygons(p1, p2)
	
	if not criterea_3:
		return [p2]
	
	#if not criterea_1 and not criterea_2 and not criterea_3:
	#	return [p2]
	"""
	
	var p1_m = GeometryUtils.get_closest_mesh_position(p1, mesh_grid_size)
	var p2_m = GeometryUtils.get_closest_mesh_position(p2, mesh_grid_size)
	
	var groups = mesh_data.corner_groups
	var pos_to_corner_group_id = mesh_data.position_to_corner_group_id
	
	
	var neigh_1 = mesh_data.corner_groups[
		mesh_data.position_to_corner_group_id[p1_m]
	]
	var neigh_2 = mesh_data.corner_groups[
		mesh_data.position_to_corner_group_id[p2_m]
	]
	
	
	var min_dist = INF
	var edge_1
	var edge_2
	for i in neigh_1:
		var dist_1 = GeometryUtils.isometric_distance(p1_m, mesh_data.corners[i])
		for j in neigh_2:
			var dist_2 = GeometryUtils.isometric_distance(p2_m, mesh_data.corners[j])
			var dist = dist_1 + mesh_data.edges_to_dist[i][j] + dist_2
			
			if dist < min_dist:
				edge_1 = i
				edge_2 = j
				min_dist = dist
	
	if not edge_1 or not edge_2:
		return 
	
	var path = mesh_data.edges_to_path[edge_1][edge_2]
	var s_path = [] #[p1]
	s_path.append_array(path)
	s_path.append(p2)
	#s_path = subdivide_shortest_path(s_path)
	return s_path

func intersect_with_obstacle_box(obstacle_box, p, q):
	var x_min = obstacle_box[0]
	var x_max = obstacle_box[1]
	var y_min = obstacle_box[2]
	var y_max = obstacle_box[3]
	if p.x > x_max and q.x > x_max:
		return false
	if p.y < x_min and q.x < x_min:
		return false
	var p_in_x_range = x_min <= p.x and p.x <= x_max
	var p_in_y_range = y_min <= p.y and p.y <= y_max
	var q_in_x_range = x_min <= q.x and q.x <= x_max
	var q_in_y_range = y_min <= q.y and q.y <= y_max
	if p_in_x_range and p_in_y_range:
		return true
	if q_in_x_range and q_in_y_range:
		return true
	if p_in_x_range and q_in_y_range:
		return false
	if p_in_y_range and q_in_y_range:
		return false
	# we don't check every case we assume cuts which might not exist
	return true

func intersect_with_occupied_polygons(p,q):
	for i in mesh_data.occupied_polygons.size():
		var obstacle_box = mesh_data.obstacle_boxes[i]
		#if not intersect_with_obstacle_box(obstacle_box, p, q):
		#	continue
		var polygon = mesh_data.occupied_polygons[i]
		var dir = (q-p).normalized().rotated(PI/2)
		var critera_1 = GeometryUtils.interset_with_shape(polygon, p + 8 * dir,q + 8 * dir )
		var critera_2 = GeometryUtils.interset_with_shape(polygon, p - 8 * dir,q - 8 * dir )
		if GeometryUtils.interset_with_shape(polygon, p,q) or critera_1 or critera_2:
			return true
	return false

func move_actors(delta):
	for agent_id in agent_id_to_agent_data:
		var agent_data = agent_id_to_agent_data[agent_id]
		move_along_direction(
			agent_data,
			agent_data["shortest_path"],
			delta
		)
		

func move_along_direction(
	agent_data,
	path,
	delta
):
	agent_data["agent"].position += agent_data["new_velocity"] * delta
	
	if not path:
		agent_data["dir"] = null
		return
	var dir = agent_data["dir"]
	var velocity = agent_data["velocity"]
	var pos = agent_data["agent"].position
	while path and path[0].distance_to(pos) < 2:
		path.pop_front()
	if path and path[0].distance_to(pos) < 2:
		path.pop_front()
		if not path:
			agent_data["destination"] = null
			agent_data["new_velocity"] = Vector2(0,0)
		if path:
			agent_data["dir"] = pos.direction_to(path[0])
			agent_data["org_dir"] = pos.direction_to(path[0])
			agent_data["new_velocity"] = velocity * agent_data["org_dir"]

