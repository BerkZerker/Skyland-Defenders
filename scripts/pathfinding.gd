extends Node
class_name Pathfinding

# Grid reference and size
var grid_system: Node
var grid_size: Vector2i

# Initialize with grid reference
func setup(grid_ref: Node) -> void:
    grid_system = grid_ref
    grid_size = grid_ref.GRID_SIZE

# Create a path node dictionary
func create_path_node(pos: Vector2i, g_cost: float = 0, h_cost: float = 0, parent = null) -> Dictionary:
    return {
        "position": pos,
        "g_cost": g_cost,
        "h_cost": h_cost,
        "parent": parent,
        "f_cost": g_cost + h_cost
    }

# Calculate shortest path between two points
func find_path(start_pos: Vector2i, end_pos: Vector2i) -> Array:
    # Validate positions
    if not is_valid_position(start_pos) or not is_valid_position(end_pos):
        return []

    var open_set: Array = []
    var closed_set: Array = []

    var start_node = create_path_node(start_pos)
    var end_node = create_path_node(end_pos)

    open_set.append(start_node)

    while not open_set.is_empty():
        var current_node = get_lowest_f_cost_node(open_set)
        open_set.erase(current_node)
        closed_set.append(current_node)

        # Found the end
        if current_node.position == end_node.position:
            return retrace_path(start_node, current_node)

        # Check neighbors
        for neighbor_pos in get_neighbors(current_node.position):
            if is_in_closed_set(neighbor_pos, closed_set):
                continue

            var new_g_cost = current_node.g_cost + get_distance(current_node.position, neighbor_pos)
            var neighbor_node = get_node_from_open_set(neighbor_pos, open_set)

            if neighbor_node == null:
                neighbor_node = create_path_node(neighbor_pos, new_g_cost, get_distance(neighbor_pos, end_pos), current_node)
                open_set.append(neighbor_node)
            elif new_g_cost < neighbor_node.g_cost:
                neighbor_node.g_cost = new_g_cost
                neighbor_node.parent = current_node
                neighbor_node.f_cost = neighbor_node.g_cost + neighbor_node.h_cost

    # No path found
    return []

# Get valid neighboring positions
func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
    var neighbors: Array[Vector2i] = []
    var directions = [
        Vector2i(0, 1),   # Down
        Vector2i(0, -1),  # Up
        Vector2i(1, 0),   # Right
        Vector2i(-1, 0),  # Left
        Vector2i(1, 1),   # Down-Right
        Vector2i(-1, 1),  # Down-Left
        Vector2i(1, -1),  # Up-Right
        Vector2i(-1, -1)  # Up-Left
    ]

    for dir in directions:
        var neighbor_pos = pos + dir
        if is_valid_position(neighbor_pos) and grid_system.is_cell_valid_for_placement(neighbor_pos):
            neighbors.append(neighbor_pos)

    return neighbors

# Check if position is within grid bounds
func is_valid_position(pos: Vector2i) -> bool:
    return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

# Get Manhattan distance between two positions
func get_distance(pos_a: Vector2i, pos_b: Vector2i) -> float:
    var dx = abs(pos_a.x - pos_b.x)
    var dy = abs(pos_a.y - pos_b.y)
    return dx + dy

# Get node with lowest f_cost from open set
func get_lowest_f_cost_node(nodes: Array) -> Dictionary:
    if nodes.is_empty():
        return create_path_node(Vector2i(0, 0))  # Return a default node instead of null
    var lowest_node = nodes[0]
    for node in nodes:
        if node.f_cost < lowest_node.f_cost:
            lowest_node = node
    return lowest_node

# Check if position exists in closed set
func is_in_closed_set(pos: Vector2i, closed_set: Array) -> bool:
    for node in closed_set:
        if node.position == pos:
            return true
    return false

# Get node from open set by position
func get_node_from_open_set(pos: Vector2i, open_set: Array) -> Variant:
    for node in open_set:
        if node.position == pos:
            return node
    return null

# Convert path nodes to array of positions
func retrace_path(start_node: Dictionary, end_node: Dictionary) -> Array:
    var path: Array = []
    var current_node = end_node

    while current_node != start_node:
        path.append(grid_system.get_cell_position(current_node.position))
        current_node = current_node.parent

    path.reverse()
    return path