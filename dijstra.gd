class_name Dijstra
extends Node

static func generate_graph(points, connections):
	var graph = []
	for i in len(points):
		
		var node = {
			"id": i,
			"point": points[i],
			"neighbours": [],
			"visited": false,
			"dist": 0,
			"visted_from": null
		}
		graph.append(node)
		
	for i in len(graph):
		var node = graph[i]
		for j in len(graph):
			if i == j:
				continue
			if connections[i][j]:
				node["neighbours"].append(j)
	
	return graph
				
				
static func find_shortest_path(graph, start, goal):
	
	# add vistied from so that path can be reconstructed
	
	for node in graph:
		var dist = INF
		var visited = false
		if node == start:
			dist = 0
			visited = true
		node["dist"] = dist
		node["visited"] = visited
		node["visited_from"] = null
	
	var found_nodes = [start]
	var current_node = start
	
	while current_node != goal:
		for neighbour_id in current_node["neighbours"]:
			var neighbour = graph[neighbour_id]
			var p = current_node["point"]
			var q = neighbour["point"]
			var dist = GeometryUtils.isometric_distance(p,q)
			#var dist = current_node["point"].distance_to(neighbour["point"])
			if neighbour["dist"] > current_node["dist"] + dist:
				neighbour["dist"] = current_node["dist"] + dist
				neighbour["visited_from"] = current_node["id"]
			if neighbour not in found_nodes:
				found_nodes.append(neighbour)
		
		var distance = INF
		for found_node in found_nodes:
			if found_node["visited"]:
				continue
			if distance > found_node["dist"]:
				current_node = found_node
				distance = found_node["dist"]
	
		
		current_node["visited"] = true
		
	
	var shortest_path = [goal["point"]]
	var previous_node = goal		
	
	while true:
		var id = previous_node["visited_from"]
		if not id:
			break
		previous_node = graph[id]
		shortest_path.append(previous_node["point"])
		
	shortest_path.append(start["point"])
	shortest_path.reverse()
		
	return {
		"path": shortest_path,
		"distance": goal["dist"]
	}
