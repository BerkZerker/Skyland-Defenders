class_name DefenderPlacementManager
extends Node

# Defender placement state
var placing_defender: bool = false
var defender_template: Node2D = null

# Preload defender scene
@onready var defender_scene = preload("res://scenes/defender.tscn")
@onready var grid_system = $"../Level/TileMapLayer"
@onready var game = get_parent()

func _ready() -> void:
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
	
	# Create new defender template
	placing_defender = true
	
	# Instantiate the defender scene
	print("DefenderPlacementManager: Instantiating defender scene")
	defender_template = defender_scene.instantiate()
	
	if defender_template:
		defender_template.modulate = Color(0, 1, 0, 0.5)  # Start with green
		
		# Position the template at the center of the grid initially
		var center_pos = Vector2(300, 300)  # Center of the grid
		defender_template.position = center_pos
		
		# Make sure attack radius is visible during placement
		defender_template.show_attack_radius = true
		defender_template.queue_redraw()
		
		game.add_child(defender_template)
		print("DefenderPlacementManager: Defender template created and added to scene")
	else:
		print("DefenderPlacementManager: Failed to instantiate defender scene")
		placing_defender = false

func update_template_position(mouse_pos: Vector2) -> void:
	if placing_defender and defender_template:
		var grid_pos = grid_system.get_grid_position(mouse_pos)
		
		# Get the world position for this grid cell
		var world_pos = grid_system.get_cell_position(grid_pos)
		defender_template.position = world_pos
		
		# Update template color based on valid placement
		if grid_system.is_cell_valid_for_placement(grid_pos):
			defender_template.modulate = Color(0, 1, 0, 0.5)  # Semi-transparent green
		else:
			defender_template.modulate = Color(1, 0, 0, 0.5)  # Semi-transparent red

func try_place_defender(touch_position: Vector2, current_resources: int) -> int:
	if not defender_template:
		print("DefenderPlacementManager: try_place_defender called but no defender template exists")
		return 0
	
	print("DefenderPlacementManager: Attempting to place defender at " + str(touch_position))
	var grid_position = grid_system.get_grid_position(touch_position)
	var cost = 0
	
	if grid_system.is_cell_valid_for_placement(grid_position) and current_resources >= 50:
		# Create actual defender
		var defender = defender_scene.instantiate()
		game.add_child(defender)
		
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
