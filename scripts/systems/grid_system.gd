@tool
extends TileMapLayer  # We're extending TileMapLayer directly

# Signals
signal defender_placed(grid_position)
signal cell_cleared(grid_position)

# Tile source IDs - using the tile IDs provided by the user in the TileSet
enum TileSourceId {
	VALID = 0,  # ID 0 = grass (valid for placement)
	INVALID = 1,  # ID 1 = wall (invalid for placement)
	ENEMY_SPAWN = 2,  # ID 2 = enemy spawn
}

# Grid cell states - for tracking game state in the grid_state array
enum GridState {
	VALID_PLACEMENT = 0,
	INVALID_PLACEMENT = 1,
	OCCUPIED = 2
}

# Grid state - 2D array to track the state of each cell in the grid
var grid_state = []  # Will be initialized as a 2D array
var grid_bounds = Rect2i()  # To store the grid boundaries
var grid_objects = {}  # Maps grid positions to placed objects

func _ready() -> void:
	# Add to grid_system group so enemies can find it
	add_to_group("grid_system")
	
	# Initialize the grid based on the existing tilemap data
	initialize_grid()

func initialize_grid() -> void:
	# Reset tracking structures
	grid_state.clear()
	grid_objects.clear()
	
	# Get all cells from the tilemap using built-in TileMapLayer method
	var used_cells = get_used_cells()
	
	if used_cells.size() == 0:
		print("Warning: No cells found in tilemap")
		return
	
	# Find the bounds of the grid
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	for cell_pos in used_cells:
		min_x = min(min_x, cell_pos.x)
		min_y = min(min_y, cell_pos.y)
		max_x = max(max_x, cell_pos.x)
		max_y = max(max_y, cell_pos.y)
	
	# Store the grid bounds
	grid_bounds = Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	
	# Initialize the grid_state 2D array
	for y in range(grid_bounds.size.y):
		var row = []
		for x in range(grid_bounds.size.x):
			row.append(GridState.INVALID_PLACEMENT)  # Default to invalid
		grid_state.append(row)
	
	# Populate the grid_state based on the tilemap data
	for cell_pos in used_cells:
		var source_id = get_cell_source_id(cell_pos)
		var local_x = cell_pos.x - grid_bounds.position.x
		var local_y = cell_pos.y - grid_bounds.position.y
		
		# Set the grid state based on the source_id
		if source_id == TileSourceId.VALID:
			grid_state[local_y][local_x] = GridState.VALID_PLACEMENT
		else:
			grid_state[local_y][local_x] = GridState.INVALID_PLACEMENT

func is_cell_valid_for_placement(cell: Vector2i) -> bool:
	# Check if the cell is within the grid bounds
	if not grid_bounds.has_point(cell):
		return false
	
	# Convert to local coordinates within the grid_state array
	var local_x = cell.x - grid_bounds.position.x
	var local_y = cell.y - grid_bounds.position.y
	
	# Check if the cell is valid for placement
	return grid_state[local_y][local_x] == GridState.VALID_PLACEMENT

func is_cell_in_bounds(cell: Vector2i) -> bool:
	return grid_bounds.has_point(cell)

func get_cell_position(grid_position: Vector2i) -> Vector2:
	# Get the tile size
	var tile_size_vec = Vector2(tile_set.tile_size)
	
	# First get the local position (relative to the TileMap)
	var local_pos = Vector2(
		grid_position.x * tile_size_vec.x + tile_size_vec.x / 2,
		grid_position.y * tile_size_vec.y + tile_size_vec.y / 2
	)
	
	# Then convert to global position by applying the TileMap's transform
	# Since we're extending TileMapLayer, we can use our own transform
	return to_global(local_pos)

func get_grid_position(world_position: Vector2) -> Vector2i:
	# First convert the world position to local position (relative to the TileMap)
	# Since we're extending TileMapLayer, we can use our own transform
	var local_pos = to_local(world_position)
	
	# Get the tile size
	var tile_size_vec = Vector2(tile_set.tile_size)
	
	# Divide local position by tile size and floor to get grid position
	return Vector2i(
		int(local_pos.x / tile_size_vec.x),
		int(local_pos.y / tile_size_vec.y)
	)

func place_defender(grid_position: Vector2i, defender_node: Node2D) -> bool:
	if not is_cell_valid_for_placement(grid_position):
		return false
	
	# Convert to local coordinates within the grid_state array
	var local_x = grid_position.x - grid_bounds.position.x
	var local_y = grid_position.y - grid_bounds.position.y
	
	# Update the grid state to occupied
	grid_state[local_y][local_x] = GridState.OCCUPIED
	
	# Track the object placed at this position
	grid_objects[grid_position] = defender_node
	
	# Update defender position using the built-in method
	defender_node.position = get_cell_position(grid_position)
	
	emit_signal("defender_placed", grid_position)
	return true

func clear_cell(grid_position: Vector2i) -> void:
	if not grid_objects.has(grid_position):
		return
	
	# Remove from grid_objects
	grid_objects.erase(grid_position)
	
	# Convert to local coordinates within the grid_state array
	var local_x = grid_position.x - grid_bounds.position.x
	var local_y = grid_position.y - grid_bounds.position.y
	
	# Check if this was originally a valid placement cell
	var source_id = get_cell_source_id(grid_position)
	if source_id == TileSourceId.VALID:
		# Set back to valid placement
		grid_state[local_y][local_x] = GridState.VALID_PLACEMENT
	else:
		# Set back to invalid placement
		grid_state[local_y][local_x] = GridState.INVALID_PLACEMENT
	
	emit_signal("cell_cleared", grid_position)

func get_cell_type(grid_position: Vector2i) -> int:
	# Check if the cell is within the grid bounds
	if not grid_bounds.has_point(grid_position):
		return TileSourceId.INVALID
	
	# Convert to local coordinates within the grid_state array
	var local_x = grid_position.x - grid_bounds.position.x
	var local_y = grid_position.y - grid_bounds.position.y
	
	# Return the appropriate type based on the grid state
	match grid_state[local_y][local_x]:
		GridState.OCCUPIED:
			return TileSourceId.VALID  # Return VALID for occupied cells, as they were originally valid
		GridState.VALID_PLACEMENT:
			return TileSourceId.VALID
		_:
			return TileSourceId.INVALID
