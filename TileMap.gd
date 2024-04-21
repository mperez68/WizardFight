extends TileMap

class Set:
	var grid_layer
	var grid_location
	var atlas_location
	func _init(layer, location, atlas):
		grid_layer = layer
		grid_location = location
		atlas_location = atlas

const ATLAS_WATER = Vector2i(1, 3)

var map_rect: Array[Rect2i]
var astar: Array[AStarGrid2D]
var highlighted_tiles: Array[Set]
var targeted_tiles: Array[Set]

# todo cache shadow tracing
#var cache_position: Vector2i
#var cache_visible map Array[Rect2i]

@onready var target_map = $TargetHighlightTileMap
@onready var highlight_map = $HighlightTileMap
@onready var water_map = $WaterTileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	# Populate astar map
	for i in get_layers_count() - 1:
		populate_layer(i)
	
	#start animation
	$WaterTileMap/AnimationPlayer.play("float")

func populate_layer(layer):
	# instantiate grid
	var tile_size = get_tileset().tile_size
	var tilemap_size = get_used_rect().end - get_used_rect().position
	map_rect.push_back(Rect2i(Vector2i(get_used_rect().position), tilemap_size))
	astar.push_back(AStarGrid2D.new())
	
	# instantiate astar
	astar[layer].region = map_rect[layer]
	astar[layer].cell_size = tile_size
	astar[layer].offset = tile_size * 0.5
	astar[layer].default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar[layer].default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar[layer].diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar[layer].update()
	
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			
			# Get temp vars
			var coordinates = Vector2i(i, j)
			var tile_data = get_cell_tile_data(layer, coordinates)
			var terrain_data = get_cell_tile_data(layer + 1, coordinates)
			var wall_data = get_cell_tile_data(layer + 1, coordinates - Vector2i(layer + 1, layer + 1))
			
			# clear invalid terrain or wall tiles
			if tile_data and (tile_data.get_custom_data("type") != "block" and tile_data.get_custom_data("type") != "stairs"):
				tile_data = null
			if terrain_data and (terrain_data.get_custom_data("type") == "block" or terrain_data.get_custom_data("type") == "stairs" or terrain_data.get_custom_data("type") == "traversible"):
				terrain_data = null
			if wall_data and wall_data.get_custom_data("type") == "stairs":
					astar[layer].set_point_weight_scale(coordinates, 2)
			if wall_data and wall_data.get_custom_data("type") != "block":
				wall_data = null
			
			# Move water tiles to WaterTileMap, set walls in place
			if get_cell_atlas_coords(layer, coordinates) == ATLAS_WATER:
				erase_cell(layer, coordinates)
				water_map.set_cell(layer, coordinates, 0, ATLAS_WATER)
				astar[layer].set_point_solid(coordinates)
			
			# set walls
			if astar[layer].is_in_boundsv(coordinates) and (!tile_data or wall_data or terrain_data):
				astar[layer].set_point_solid(coordinates)

func draw_weighted_range(layer, origin, speed, is_higlight):
	clear_highlights()
	var rough_range_start = local_to_map(origin) - Vector2i(speed, speed)
	for i in 2 * speed + 1:
		for j in 2 * speed + 1:
			var temp_loc = Vector2i(i, j) + rough_range_start
			var temp_layer = layer
			if is_stairs(layer, temp_loc):
				temp_layer += 1
				temp_loc -= Vector2i(1, 1)
			var temp_atlas = get_cell_atlas_coords(temp_layer, temp_loc)
			if is_point_in_range_weighted(layer, map_to_local(Vector2i(i, j) + rough_range_start), origin, speed):
				highlighted_tiles.push_front(Set.new(temp_layer, temp_loc, temp_atlas))
				highlight_map.set_cell(temp_layer, temp_loc, 1, temp_atlas, 0)
	if is_higlight:
		$HighlightTileMap/AnimationPlayer.play("highlight")
	else:
		$HighlightTileMap/AnimationPlayer.play("lowlight")

func draw_range(layer, origin, range, is_highlight):
	clear_highlights()
	var rough_range_start = local_to_map(origin) - Vector2i(range, range)
	for i in 2 * range + 1:
		for j in 2 * range + 1:
			var temp_loc = Vector2i(i, j) + rough_range_start
			var temp_atlas = get_cell_atlas_coords(layer, temp_loc)
			if is_visible_target(layer, map_to_local(temp_loc), layer, origin, range):
				highlighted_tiles.push_front(Set.new(layer, temp_loc, temp_atlas))
				highlight_map.set_cell(layer, temp_loc, 1, temp_atlas, 0)
	if is_highlight:
		$HighlightTileMap/AnimationPlayer.play("highlight")
	else:
		$HighlightTileMap/AnimationPlayer.play("lowlight")

func draw_target(layer, origin, radius: int, is_highlight):
	clear_target()
	var rough_range_start = local_to_map(origin) - Vector2i(radius, radius)
	for i in 2 * radius + 1:
		for j in 2 * radius + 1:
			var temp_loc = Vector2i(i, j) + rough_range_start
			var temp_atlas = get_cell_atlas_coords(layer, temp_loc)
			if is_visible_target(layer, map_to_local(temp_loc), layer, origin, radius) or temp_loc == local_to_map(origin):
				targeted_tiles.push_front(Set.new(layer, temp_loc, temp_atlas))
				target_map.set_cell(layer, temp_loc, 1, temp_atlas, 0)
	if is_highlight:
		$TargetHighlightTileMap/AnimationPlayer.play("highlight")
	else:
		$TargetHighlightTileMap/AnimationPlayer.play("lowlight")

func clear_highlights():
	for i in highlighted_tiles.size():
		var temp = highlighted_tiles.pop_front()
		highlight_map.erase_cell(temp.grid_layer, temp.grid_location)

func clear_target():
	for i in targeted_tiles.size():
		var temp = targeted_tiles.pop_front()
		target_map.erase_cell(temp.grid_layer, temp.grid_location)

func is_stairs(layer, grid_position):
	if !grid_position:
		return false
	var wall = get_cell_tile_data(layer + 1, grid_position - Vector2i(1, 1))
	return wall and wall.get_custom_data("type") == "stairs"

func is_drop(layer, grid_position):
	if !grid_position:
		return false
	var stairs = get_cell_tile_data(layer, grid_position)
	return stairs and stairs.get_custom_data("type") == "stairs"

func is_point_walkable(layer, local_position):
	var map_position = local_to_map(local_position)
	if map_rect[layer].has_point(map_position):
		return not astar[layer].is_point_solid(map_position)
	return false

func local_to_map_top_layer(local_position):
	var map_position = local_to_map(local_position)
	for i in astar.size():
		if astar[astar.size() - i - 1].is_in_boundsv(map_position) and !astar[astar.size() - i - 1].is_point_solid(map_position):
			return astar.size() - i - 1
	return -1

func is_point_in_range_weighted(layer, local_position, origin, range):
	var path_weighted_size = distance_to_weighted(layer, local_position, origin)
	return path_weighted_size <= range and path_weighted_size > 0

func distance_to_weighted(layer, local_position, origin):
	var map_position = local_to_map(local_position)
	if !astar[layer].is_in_boundsv(map_position) or astar[layer].is_point_solid(map_position):
		return 0
	var path = astar[layer].get_id_path(
			local_to_map(origin),
			local_to_map(local_position)
		).slice(1)
	var path_weighted_size = 0
	for i in path.size():
		path_weighted_size += astar[layer].get_point_weight_scale(path[i])
	return path_weighted_size

func distance_to(layer, local_position, origin_layer, origin):
	var map_position = local_to_map(local_position)
	var map_origin = local_to_map(origin)
	return abs(layer - origin_layer) + abs(map_position.x - map_origin.x) + abs(map_position.y - map_origin.y)

func is_visible_target(target_layer, target_local_position, origin_layer, origin_local_position, range):
	# Break early if manhattan distance is out of range or target is self
	var distance = distance_to(target_layer, target_local_position, origin_layer, origin_local_position)
	if distance > range or distance == 0:
		return false
	
	# Translate to tilemap grid
	var target_grid = local_to_map(target_local_position)
	var origin_grid = local_to_map(origin_local_position)
	
	# Determine quadrant
	var quad_position = origin_grid - target_grid
	var quad_origin: Vector2i
	var quad_vector: Vector2i
	if quad_position.x <= 0:
		if quad_position.y <= 0: # Upper Left
			quad_origin = Vector2i(0, 0)
			quad_vector = Vector2i(1, 1)
		else: 					# Lower Left
			quad_origin = Vector2i(0, range)
			quad_vector = Vector2i(1, -1)
	else:
		if quad_position.y <= 0: # Upper Right
			quad_origin = Vector2i(range, 0)
			quad_vector = Vector2i(-1, 1)
		else: 					# Lower Right
			quad_origin = Vector2i(range, range)
			quad_vector = Vector2i(-1, -1)
	
	# Create sub-grid of quadrant, mark origin block
	var quad_grid = []
	var quad_rect = Rect2i(origin_grid - quad_origin, Vector2i(range + 1, range + 1))
	
	# Scan for blockers
	for i in quad_rect.size.x:
		quad_grid.push_back([])
		for j in quad_rect.size.y:
			# start at 0 (fully visible)
			quad_grid[i].push_back(0)
			
			# if this tile is blocked, inc self and inc tiles behind it
			var t = get_cell_tile_data(origin_layer + 1, quad_rect.position + Vector2i(i, j) - Vector2i(origin_layer + 1, origin_layer + 1))
			if t and t.get_custom_data("type") == "block":
				quad_grid[i][j] += 1
	
	# Scan for shadows
	for i in quad_rect.size.x:
		var a = i
		if quad_origin.x:
			a = quad_rect.size.x - i - 1
		for j in quad_rect.size.y:
			var b = j
			if quad_origin.y:
				b = quad_rect.size.y - j - 1
			# Valid checks
			var i_is_valid = a - quad_vector.x >= 0 and a - quad_vector.x < quad_rect.size.x
			var j_is_valid = b - quad_vector.y >= 0 and b - quad_vector.y < quad_rect.size.y
			# If previous angle tile is blocker, increment self
			if i_is_valid and j_is_valid and quad_grid[a - quad_vector.x][b - quad_vector.y]:
				quad_grid[a][b] += 1
			if i > j:
				# If previous tile is blocker, increment self
				if i_is_valid and quad_grid[a - quad_vector.x][b]:
					quad_grid[a][b] += 1
			if i < j:
				# If previous tile is blocker, increment self
				if j_is_valid and quad_grid[a][b - quad_vector.y]:
					quad_grid[a][b] += 1
	
	# return false if block value is above threshold
	var temp = target_grid - quad_rect.position
	return !quad_grid[temp.x][temp.y]
