extends Node2D

# This script manages the level scene which contains the tilemap grid
# In the future, this can be expanded to load custom tilemap data

# Reference to the tilemap grid system
@onready var grid_system = $NavigationRegion2D/TileMapLayer
@onready var navigation_region = $NavigationRegion2D

# Signal to indicate when navigation is ready
signal navigation_ready

func _ready() -> void:
	print("Level: _ready() called")
	
	# Verify grid system
	if not grid_system:
		push_error("Level: TileMapLayer not found")
	
	# Create NavigationRegion2D if it doesn't exist
	if not navigation_region:
		navigation_region = NavigationRegion2D.new()
		navigation_region.name = "NavigationRegion2D"
		add_child(navigation_region)
		print("Level: Created NavigationRegion2D")
	
	# We'll manually emit the navigation_ready signal after baking the navigation mesh
	# No need to connect to a signal from NavigationRegion2D

# Function to get the grid system
func get_grid_system():
	return grid_system

# Function to get the navigation region
func get_navigation_region():
	return navigation_region

# In the future, this function could be expanded to load custom level data
func load_level_data(level_data = null):
	print("Level: Loading level data")
	
	# Initialize the grid
	if grid_system:
		grid_system.initialize_grid()
	else:
		push_error("Level: Cannot load level data - TileMapLayer not found")
	
	# Emit signal that navigation is ready
	# We're no longer generating the navigation mesh at runtime
	# The navigation mesh should be pre-baked in the scene
	print("Level: Using pre-baked navigation mesh")
	emit_signal("navigation_ready")
