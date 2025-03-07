class_name PlacementComponent
extends "res://scripts/components/component.gd"

signal placed(grid_position)
signal removed(grid_position)

@export var cost: int = 50
@export var is_placed: bool = false
@export var show_placement_radius: bool = false

var grid_position: Vector2i = Vector2i.ZERO
var grid_system = null

func initialize() -> void:
	# Default to not placed
	is_placed = false

func setup_with_grid_system(grid_sys) -> void:
	grid_system = grid_sys

func place_at_grid_position(pos: Vector2i) -> bool:
	if not grid_system:
		push_error("PlacementComponent: No grid system set")
		return false
	
	if grid_system.is_cell_valid_for_placement(pos):
		grid_position = pos
		is_placed = true
		
		# Update entity position
		entity.position = grid_system.get_cell_position(grid_position)
		
		# Update grid state
		if grid_system.has_method("place_defender"):
			grid_system.place_defender(grid_position, entity)
		
		emit_signal("placed", grid_position)
		return true
	
	return false

func remove_from_grid() -> void:
	if not is_placed or not grid_system:
		return
	
	# Update grid state
	if grid_system.has_method("clear_cell"):
		grid_system.clear_cell(grid_position)
	
	is_placed = false
	emit_signal("removed", grid_position)

func is_valid_placement_position(pos: Vector2i) -> bool:
	if not grid_system:
		return false
	
	return grid_system.is_cell_valid_for_placement(pos)

func get_placement_cost() -> int:
	return cost
