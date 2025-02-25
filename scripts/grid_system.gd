@tool
extends Node2D

# Grid properties
@export var CELL_SIZE: Vector2 = Vector2(64, 64)
@export var VALID_GRID_SIZE: Vector2i = Vector2i(6, 6)  # 6x6 valid placement area
@export var TOTAL_GRID_SIZE: Vector2i = Vector2i(12, 12)  # Total visible grid size

# Grid state
var grid_cells: Array = []
var valid_placement_cells: Array = []

# Visual properties
const VALID_COLOR = Color(0, 1, 0, 0.3)  # Semi-transparent green
const INVALID_COLOR = Color(1, 0, 0, 0.3)  # Semi-transparent red
const GRID_COLOR = Color(1, 1, 1, 0.2)     # Semi-transparent white

# Calculate valid area offset from the origin
var valid_area_offset: Vector2i

func _ready() -> void:
	# Calculate offset for valid area within total grid
	valid_area_offset = Vector2i(
		(TOTAL_GRID_SIZE.x - VALID_GRID_SIZE.x) / 2,
		(TOTAL_GRID_SIZE.y - VALID_GRID_SIZE.y) / 2
	)
	initialize_grid()

	# Set position to origin (0,0)
	position = Vector2.ZERO
	queue_redraw()

func initialize_grid() -> void:
	# Initialize the grid array for the valid placement area only
	grid_cells.clear()
	for y in range(VALID_GRID_SIZE.y):
		var row = []
		for x in range(VALID_GRID_SIZE.x):
			row.append({
				"occupied": false,
				"type": "empty",
				"object": null
			})
		grid_cells.append(row)
	
	# Mark valid placement cells
	calculate_valid_placement_cells()
	queue_redraw()

func calculate_valid_placement_cells() -> void:
	valid_placement_cells.clear()
	for y in range(VALID_GRID_SIZE.y):
		for x in range(VALID_GRID_SIZE.x):
			if is_cell_valid_for_placement(Vector2i(x, y)):
				valid_placement_cells.append(Vector2i(x, y))

func is_cell_valid_for_placement(cell: Vector2i) -> bool:
	# Check if the cell is within the valid placement area
	if cell.x < 0 or cell.x >= VALID_GRID_SIZE.x or cell.y < 0 or cell.y >= VALID_GRID_SIZE.y:
		return false
	return not grid_cells[cell.y][cell.x].occupied

func get_cell_position(grid_position: Vector2i) -> Vector2:
	# Convert valid area grid position to world position
	var cell_center_offset = CELL_SIZE / 2
	var world_pos = Vector2(
		(grid_position.x + valid_area_offset.x) * CELL_SIZE.x, 
		(grid_position.y + valid_area_offset.y) * CELL_SIZE.y
	) + cell_center_offset
	
	# Return position in world coordinates
	return world_pos

func get_grid_position(world_position: Vector2) -> Vector2i:
	# Convert world position to valid area grid position
	# Calculate grid coordinates
	var x = int(world_position.x / CELL_SIZE.x) - valid_area_offset.x
	var y = int(world_position.y / CELL_SIZE.y) - valid_area_offset.y
	return Vector2i(x, y)

func place_defender(grid_position: Vector2i, defender_node: Node2D) -> bool:
	if not is_cell_valid_for_placement(grid_position):
		return false
	
	var cell = grid_cells[grid_position.y][grid_position.x]
	cell.occupied = true
	cell.type = "defender"
	cell.object = defender_node
	
	# Update defender position
	defender_node.position = get_cell_position(grid_position)
	
	calculate_valid_placement_cells()
	queue_redraw()
	
	emit_signal("defender_placed", grid_position)
	return true

func clear_cell(grid_position: Vector2i) -> void:
	if grid_position.x < 0 or grid_position.x >= VALID_GRID_SIZE.x or \
	   grid_position.y < 0 or grid_position.y >= VALID_GRID_SIZE.y:
		return
	
	var cell = grid_cells[grid_position.y][grid_position.x]
	cell.occupied = false
	cell.type = "empty"
	cell.object = null
	
	calculate_valid_placement_cells()
	queue_redraw()
	
	emit_signal("cell_cleared", grid_position)

func _draw() -> void:
	# Draw all grid cells (including those outside valid area)
	for y in range(TOTAL_GRID_SIZE.y):
		for x in range(TOTAL_GRID_SIZE.x):
			var rect = Rect2(
				Vector2(x * CELL_SIZE.x, y * CELL_SIZE.y),
				CELL_SIZE
			)
			
			# Check if this cell is in the valid placement area
			var valid_grid_pos = Vector2i(
				x - valid_area_offset.x,
				y - valid_area_offset.y
			)
			
			if valid_grid_pos.x >= 0 and valid_grid_pos.x < VALID_GRID_SIZE.x and \
			   valid_grid_pos.y >= 0 and valid_grid_pos.y < VALID_GRID_SIZE.y:
				# Draw valid area cells with fill color
				if valid_grid_pos in valid_placement_cells:
					draw_rect(rect, VALID_COLOR, true)
				else:
					draw_rect(rect, INVALID_COLOR, true)
			
			# Draw grid lines for all cells
			draw_rect(rect, GRID_COLOR, false)

# Signals
signal defender_placed(grid_position)
signal cell_cleared(grid_position)
