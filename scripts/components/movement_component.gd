class_name MovementComponent
extends "res://scripts/components/component.gd"

@export var movement_speed: float = 100.0
var pathfinding_component = null

func initialize() -> void:
	# Try to get the pathfinding component if it exists
	pathfinding_component = entity.get_component("pathfinding")

func process_component(delta: float) -> void:
	# Override in child classes for specific movement behavior
	pass

func move_towards(target_position: Vector2, delta: float) -> void:
	if pathfinding_component:
		# Use pathfinding
		pathfinding_component.set_target_position(target_position)
		var next_position = pathfinding_component.get_next_path_position()
		var direction = (next_position - entity.global_position).normalized()
		entity.global_position += direction * movement_speed * delta
	else:
		# Direct movement if no pathfinding component (should not happen as per user's feedback)
		var direction = (target_position - entity.global_position).normalized()
		entity.global_position += direction * movement_speed * delta
