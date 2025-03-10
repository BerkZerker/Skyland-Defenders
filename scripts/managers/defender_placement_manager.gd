extends Node

# Defender placement state
var placing_defender: bool = false
var defender_template: Node2D = null

# Preload defender scene
@onready var defender_scene = preload("res://scenes/entities/defender.tscn")
# Grid system reference - will be set in _ready()
var grid_system = null

func get_grid_system() -> Node:
	var level = get_node_or_null("../Level")
	
	if level and level.has_method("get_grid_system"):
		print("DefenderPlacementManager: Using Level.get_grid_system()")
		return level.get_grid_system()
	else:
		# Fallback to direct node paths for backward compatibility
		var world_tilemap = get_node_or_null("../Level/NavigationRegion2D/GroundTileMap")
		
		if world_tilemap:
			print("DefenderPlacementManager: Found GroundTileMap as child of NavigationRegion2D")
			return world_tilemap
		else:
			push_error("DefenderPlacementManager: Could not find GroundTileMap node")
			return null
@onready var game = get_parent()
@onready var camera_controller = $"../CameraController"

func _ready() -> void:
	# Initialize grid system
	grid_system = get_grid_system()
	
	if not grid_system:
		push_error("DefenderPlacementManager: Failed to get grid system in _ready()")
	
	# Clean up any existing defender template
	if defender_template:
		defender_template.queue_free()
		defender_template = null
		placing_defender = false

func start_defender_placement(current_resources: int) -> void:
	print("DefenderPlacementManager: Place defender button pressed - start_defender_placement called")
	# Prevent starting placement if already placing or not enough resources
	if placing_defender or current_resources < 50:  # Defender cost
		print("DefenderPlacementManager: Cannot start placement - already placing or insufficient resources")
		return
	
	# Clean up any existing template first
	if defender_template:
		defender_template.queue_free()
		defender_template = null
	
	# Make sure we're not paused
	if get_tree().paused:
		get_tree().paused = false
		print("DefenderPlacementManager: Unpaused game for defender placement")
	
	# Create new defender template but don't add to scene yet
	placing_defender = true
	
	# Instantiate the defender scene
	print("DefenderPlacementManager: Instantiating defender scene")
	defender_template = defender_scene.instantiate()
	
	if defender_template:
		# Make sure attack radius is visible during placement
		defender_template.show_attack_radius = true
		defender_template.queue_redraw()
		
		print("DefenderPlacementManager: Defender template created but not added to scene yet")
	else:
		print("DefenderPlacementManager: Failed to instantiate defender scene")
		placing_defender = false

func show_defender_template(touch_pos: Vector2) -> void:
	if placing_defender and defender_template:
		# Add to scene if not already added
		if not defender_template.is_inside_tree():
			game.add_child(defender_template)
			print("DefenderPlacementManager: Defender template added to scene")
		
		# Make sure it's visible
		defender_template.visible = true
		
		# Update position and appearance
		update_template_position(touch_pos)

func update_template_position(touch_pos: Vector2) -> void:
	if placing_defender and defender_template and grid_system:
		# Convert screen position to world position
		var world_pos = camera_controller.screen_to_world_position(touch_pos)
		
		# Get the grid position from the world position
		var grid_pos = grid_system.get_grid_position(world_pos)
		
		# Get the world position for this grid cell (centered)
		var cell_pos = grid_system.get_cell_position(grid_pos)
		defender_template.position = cell_pos
		
		# Update template color based on valid placement
		if grid_system.is_cell_valid_for_placement(grid_pos):
			defender_template.modulate = Color(1, 1, 1, 0.5)  # Semi-transparent original texture
		else:
			defender_template.modulate = Color(1, 0.3, 0.3, 0.5)  # Red-tinted semi-transparent texture
	elif placing_defender and defender_template:
		# If grid_system is null, make the template red to indicate invalid placement
		defender_template.modulate = Color(1, 0.3, 0.3, 0.5)  # Red-tinted semi-transparent texture

func try_place_defender(touch_position: Vector2, current_resources: int) -> int:
	if not defender_template:
		print("DefenderPlacementManager: try_place_defender called but no defender template exists")
		return 0
	
	if not grid_system:
		print("DefenderPlacementManager: try_place_defender called but grid_system is null")
		return 0
	
	# Convert screen position to world position
	var world_position = camera_controller.screen_to_world_position(touch_position)
	
	print("DefenderPlacementManager: Attempting to place defender at " + str(touch_position) + " (world: " + str(world_position) + ")")
	var grid_position = grid_system.get_grid_position(world_position)
	var cost = 0
	
	if grid_system.is_cell_valid_for_placement(grid_position) and current_resources >= 50:
		# Create actual defender
		var defender = defender_scene.instantiate()
		game.add_child(defender)
		
		# Set up the grid system for the component defender
		if defender.has_method("setup_grid_system"):
			defender.setup_grid_system(grid_system)
		
		if grid_system.place_defender(grid_position, defender):
			cost = 50
			print("DefenderPlacementManager: Defender placed successfully, cost: " + str(cost))
			
			# Properly set up the defender as a placed defender
			defender.setup_as_placed_defender()
			
			# Hide attack radius after placement is handled in setup_as_placed_defender()
	else:
		print("DefenderPlacementManager: Invalid placement position or insufficient resources")
	
	# Clean up template whether placement was successful or not
	defender_template.queue_free()
	defender_template = null
	placing_defender = false
	print("DefenderPlacementManager: Defender template cleaned up")
	
	return cost

func is_placing() -> bool:
	return placing_defender

func cleanup_template() -> void:
	if defender_template:
		defender_template.queue_free()
		defender_template = null
		placing_defender = false
