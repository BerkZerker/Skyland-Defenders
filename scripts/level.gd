extends Node2D

# This script manages the level scene which contains the tilemap grid
# In the future, this can be expanded to load custom tilemap data

# References to the tilemaps
@onready var world_tilemap = $NavigationRegion2D/GroundTileMap
@onready var entity_tilemap = $EntityTileMap
@onready var navigation_region = $NavigationRegion2D

# Signal to indicate when navigation is ready
signal navigation_ready

func _ready() -> void:
	print("Level: _ready() called")
	
	# Verify tilemaps
	if not world_tilemap:
		push_error("Level: GroundTileMap not found")
	if not entity_tilemap:
		push_error("Level: EntityTileMap not found")
	
	# Create NavigationRegion2D if it doesn't exist
	if not navigation_region:
		navigation_region = NavigationRegion2D.new()
		navigation_region.name = "NavigationRegion2D"
		add_child(navigation_region)
		print("Level: Created NavigationRegion2D")
	
	# We'll manually emit the navigation_ready signal after baking the navigation mesh
	# No need to connect to a signal from NavigationRegion2D

# Function to get the world tilemap (combines ground and wall functionality)
func get_world_tilemap():
	return world_tilemap

# Function to get the ground tilemap (for backward compatibility)
func get_ground_tilemap():
	return world_tilemap

# Function to get the wall tilemap (for backward compatibility)
func get_wall_tilemap():
	return world_tilemap

# Function to get the entity tilemap (for entity tracking)
func get_entity_tilemap():
	return entity_tilemap

# Function to get the grid system (for backward compatibility)
func get_grid_system():
	return world_tilemap

# Function to get the navigation region
func get_navigation_region():
	return navigation_region

# In the future, this function could be expanded to load custom level data
func load_level_data(level_data = null):
	print("Level: Loading level data")
	
	# Initialize the grid
	if world_tilemap and world_tilemap.has_method("initialize_grid"):
		world_tilemap.initialize_grid()
	else:
		push_error("Level: Cannot load level data - GroundTileMap not found or missing initialize_grid method")
	
	# Emit signal that navigation is ready
	# We're no longer generating the navigation mesh at runtime
	# The navigation mesh should be pre-baked in the scene
	print("Level: Using pre-baked navigation mesh")
	emit_signal("navigation_ready")
