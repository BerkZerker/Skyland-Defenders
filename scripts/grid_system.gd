extends Node2D

# Grid properties
const CELL_SIZE: Vector2 = Vector2(64, 64)
const GRID_SIZE: Vector2i = Vector2i(6, 6)  # 6x6 grid
# Grid position offset to center it on screen
var grid_offset: Vector2

# Grid state
var grid_cells: Array = []
var valid_placement_cells: Array = []

# Visual properties
const VALID_COLOR = Color(0, 1, 0, 0.3)  # Semi-transparent green
const INVALID_COLOR = Color(1, 0, 0, 0.3)  # Semi-transparent red
const GRID_COLOR = Color(1, 1, 1, 0.2)     # Semi-transparent white

func _ready() -> void:
    # Calculate grid offset to center it on screen
    var viewport_size = get_viewport_rect().size
    var grid_pixel_size = Vector2(GRID_SIZE.x * CELL_SIZE.x, GRID_SIZE.y * CELL_SIZE.y)
    grid_offset = (viewport_size - grid_pixel_size) / 2
    
    initialize_grid()

func initialize_grid() -> void:
    # Initialize the grid array
    grid_cells.clear()
    for y in range(GRID_SIZE.y):
        var row = []
        for x in range(GRID_SIZE.x):
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
    for y in range(GRID_SIZE.y):
        for x in range(GRID_SIZE.x):
            if is_cell_valid_for_placement(Vector2i(x, y)):
                valid_placement_cells.append(Vector2i(x, y))

func is_cell_valid_for_placement(cell: Vector2i) -> bool:
    if cell.x < 0 or cell.x >= GRID_SIZE.x or cell.y < 0 or cell.y >= GRID_SIZE.y:
        return false
    return not grid_cells[cell.y][cell.x].occupied

func get_cell_position(grid_position: Vector2i) -> Vector2:
    # Add grid_offset and center within cell
    var cell_center_offset = CELL_SIZE / 2
    return Vector2(grid_position.x * CELL_SIZE.x, grid_position.y * CELL_SIZE.y) + grid_offset + cell_center_offset

func get_grid_position(world_position: Vector2) -> Vector2i:
    # Remove grid_offset before calculating
    var adjusted_position = world_position - grid_offset
    var x = int(adjusted_position.x / CELL_SIZE.x)
    var y = int(adjusted_position.y / CELL_SIZE.y)
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
    if grid_position.x < 0 or grid_position.x >= GRID_SIZE.x or \
       grid_position.y < 0 or grid_position.y >= GRID_SIZE.y:
        return

    var cell = grid_cells[grid_position.y][grid_position.x]
    cell.occupied = false
    cell.type = "empty"
    cell.object = null

    calculate_valid_placement_cells()
    queue_redraw()
    
    emit_signal("cell_cleared", grid_position)

func _draw() -> void:
    # Draw grid cells
    for y in range(GRID_SIZE.y):
        for x in range(GRID_SIZE.x):
            var cell_pos = Vector2(x * CELL_SIZE.x, y * CELL_SIZE.y) + grid_offset
            var rect = Rect2(cell_pos, CELL_SIZE)
            
            # Draw cell background
            if Vector2i(x, y) in valid_placement_cells:
                draw_rect(rect, VALID_COLOR, true)
            else:
                draw_rect(rect, INVALID_COLOR, true)
            
            # Draw grid lines
            draw_rect(rect, GRID_COLOR, false)

# Signals
signal defender_placed(grid_position)
signal cell_cleared(grid_position)