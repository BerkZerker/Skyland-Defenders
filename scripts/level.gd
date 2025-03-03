extends Node2D

# This script manages the level scene which contains the tilemap grid
# In the future, this can be expanded to load custom tilemap data

# Reference to the tilemap grid system
@onready var grid_system = $TileMapLayer

func _ready() -> void:
	print("Level: _ready() called")
	
	# Verify grid system
	if not grid_system:
		push_error("Level: TileMapLayer not found")

# Function to get the grid system
func get_grid_system():
	return grid_system

# In the future, this function could be expanded to load custom level data
func load_level_data(level_data = null):
	print("Level: Loading level data")
	
	# For now, just initialize the grid
	if grid_system:
		grid_system.initialize_grid()
	else:
		push_error("Level: Cannot load level data - TileMapLayer not found")
