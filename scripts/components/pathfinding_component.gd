extends "res://scripts/components/component.gd"

signal path_changed(new_path)

var current_path: Array[Vector2] = []
var target_position: Vector2
var path_index: int = 0
var navigation_agent: NavigationAgent2D
var recalculate_path_threshold: float = 100.0  # Distance threshold to recalculate path
var navigation_ready: bool = false

func _init(entity_parent):
	super._init(entity_parent)
	navigation_agent = NavigationAgent2D.new()
	add_child(navigation_agent)
	
	# Configure NavigationAgent2D
	navigation_agent.path_desired_distance = 20.0
	navigation_agent.target_desired_distance = 20.0
	navigation_agent.path_max_distance = 100.0

func initialize() -> void:
	# Connect to navigation agent signals
	navigation_agent.connect("path_changed", Callable(self, "_on_path_changed"))
	navigation_agent.connect("navigation_finished", Callable(self, "_on_navigation_finished"))
	
	# Find the level node to connect to its navigation_ready signal
	var level = _find_level_node()
	if level:
		if not level.navigation_ready.is_connected(_on_navigation_ready):
			level.connect("navigation_ready", Callable(self, "_on_navigation_ready"))
		
		# Check if navigation is already ready
		if level.get_navigation_region() and level.get_navigation_region().navigation_polygon:
			navigation_ready = true
			print("PathfindingComponent: Navigation already ready")

func _find_level_node() -> Node:
	# Find the level node in the scene tree
	var current_node = entity
	while current_node:
		if current_node.get_parent() and current_node.get_parent().has_method("get_navigation_region"):
			return current_node.get_parent()
		current_node = current_node.get_parent()
	
	# If we couldn't find it by traversing up, try to find it by name
	var root = entity.get_tree().root
	if root.has_node("Game/Level"):
		return root.get_node("Game/Level")
	
	print("PathfindingComponent: Could not find Level node")
	return null

func process_component(delta: float) -> void:
	if navigation_ready and not navigation_agent.is_navigation_finished() and current_path.size() > 0:
		# Update path index based on current position
		update_path_index()

func set_target_position(position: Vector2) -> void:
	target_position = position
	
	# Only set the target position if navigation is ready
	if navigation_ready:
		navigation_agent.target_position = position
	
func get_next_path_position() -> Vector2:
	if navigation_ready and current_path.size() > 0 and path_index < current_path.size():
		return current_path[path_index]
	return entity.global_position

func update_path_index() -> void:
	if current_path.size() == 0:
		return
		
	# Find the closest point on the path
	var min_distance = INF
	var closest_index = path_index
	
	# Only look ahead from current index to avoid going backward
	for i in range(path_index, current_path.size()):
		var distance = entity.global_position.distance_to(current_path[i])
		if distance < min_distance:
			min_distance = distance
			closest_index = i
	
	# Update path index if we found a closer point
	if closest_index > path_index:
		path_index = closest_index

func _on_path_changed() -> void:
	current_path = navigation_agent.get_current_navigation_path()
	path_index = 0
	emit_signal("path_changed", current_path)

func _on_navigation_finished() -> void:
	# Path completed
	pass

func _on_navigation_ready() -> void:
	print("PathfindingComponent: Navigation is now ready")
	navigation_ready = true
	
	# If we have a target position set, update it now that navigation is ready
	if target_position:
		navigation_agent.target_position = target_position
