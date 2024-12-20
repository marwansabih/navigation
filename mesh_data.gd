extends Resource
class_name MeshData

@export var position_to_visible_edges = {}
#@export var small_polygons = [] # can be removed in the future
@export var occupied_polygons = []
#@export var large_polygons = []
@export var convex_polygons = []
@export var polygon_neighbours_dict = {}
@export var polygon_corner_neighbour_dict = {}
@export var polygon_regions = []
#@export var pos_to_walls = {} # can be removed in the future
@export var pos_to_region = {}
@export var corners = [] 
#@export var graph = []
@export var edges_to_dist = {}
@export var edges_to_path = {}


func _init():
	pass
