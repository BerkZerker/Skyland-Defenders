@tool
class_name TilemapGridSystem
extends TileMapLayer  # We're extending TileMapLayer directly

# Signals
signal defender_placed(grid_position)
signal cell_cleared(grid_position)

# Tile types - using the tile IDs provided by the user
enum TileType {
	VALID = 0,
	INVALID = 1,
	ENEMY_SPAWN = 2,
	OCCUPIED = 3  # Used for tracking, not an actual tile
}

# Grid state - only track valid placement cells and occupied cells
var valid_placement_cells: Array = []
var occupied_cells: Dictionary = {}  # Maps grid positions to placed objects

func _ready() -> void:
	# Add to grid_system group so enemies can find it
	add_to_group("grid_system")
	
	# Initialize the grid based on the existing tilemap data
	initialize_grid()

func initialize_grid() -> void:
	# Reset tracking arrays
	valid_placement_cells.clear()
	occupied_cells.clear()
	
	# Get all cells from the tilemap using built-in TileMapLayer method
	var used_cells = get_used_cells()
	
	# Process each cell to find valid placement cells
	for cell_pos in used_cells:
		var source_id = get_cell_source_id(cell_pos)
		
		# Add valid placement cells to the array
		if source_id == TileType.VALID:
			valid_placement_cells.append(cell_pos)

func is_cell_valid_for_placement(cell: Vector2i) -> bool:
	# Check if the cell exists in our tilemap and is a valid placement tile
	if not is_cell_in_bounds(cell):
		return false
	
	# Check if the cell is a valid tile and not occupied
	var source_id = get_cell_source_id(cell)
	return source_id == TileType.VALID and not occupied_cells.has(cell)

func is_cell_in_bounds(cell: Vector2i) -> bool:
	# Check if the cell exists in our tilemap using built-in TileMapLayer method
	var used_cells = get_used_cells()
	return used_cells.has(cell)

func get_cell_position(grid_position: Vector2i) -> Vector2:
	# Use TileMapLayer's built-in method to convert grid position to world position
	# map_to_local returns the top-left corner of the cell, so add half cell size to get center
	return map_to_local(grid_position) + Vector2(tile_set.tile_size) / 2

func get_grid_position(world_position: Vector2) -> Vector2i:
	# Use TileMapLayer's built-in method to convert world position to grid position
	return local_to_map(world_position)

func place_defender(grid_position: Vector2i, defender_node: Node2D) -> bool:
	if not is_cell_valid_for_placement(grid_position):
		return false
	
	# Track the occupied cell and its object
	occupied_cells[grid_position] = defender_node
	
	# Update defender position using the built-in method
	defender_node.position = get_cell_position(grid_position)
	
	# Update valid placement cells
	if valid_placement_cells.has(grid_position):
		valid_placement_cells.erase(grid_position)
	
	emit_signal("defender_placed", grid_position)
	return true

func clear_cell(grid_position: Vector2i) -> void:
	if not occupied_cells.has(grid_position):
		return
	
	# Remove from occupied cells
	occupied_cells.erase(grid_position)
	
	# Check if this was originally a valid placement cell
	var source_id = get_cell_source_id(grid_position)
	if source_id == TileType.VALID:
		# Add back to valid placement cells
		if not valid_placement_cells.has(grid_position):
			valid_placement_cells.append(grid_position)
	
	emit_signal("cell_cleared", grid_position)

func get_cell_type(grid_position: Vector2i) -> int:
	# If the cell is occupied, return OCCUPIED
	if occupied_cells.has(grid_position):
		return TileType.OCCUPIED
	
	# Otherwise, return the type based on the source_id using built-in method
	var source_id = get_cell_source_id(grid_position)
	if source_id >= 0 and source_id < TileType.size():
		return source_id
	
	# Default to INVALID if the source_id is not recognized
	return TileType.INVALID
