extends "res://scripts/components/component.gd"

signal target_acquired(target)
signal target_lost()

@export var target_group: String = "enemies"  # Group to target
@export var targeting_interval: float = 0.5  # How often to update target

var current_target: Node = null
var targeting_timer: float = 0.0

func process_component(delta: float) -> void:
	targeting_timer += delta
	if targeting_timer >= targeting_interval:
		targeting_timer = 0.0
		update_target()

func update_target() -> void:
	# If we have a valid target, check if it's still valid
	if current_target and is_instance_valid(current_target):
		# Target is valid, no need to check distance
		pass
	else:
		# If we don't have a valid target, find a new one
		current_target = null
		find_new_target()

func find_new_target() -> void:
	var potential_targets = get_tree().get_nodes_in_group(target_group)
	var nearest_distance = INF
	var nearest_target = null
	
	for target in potential_targets:
		var distance = entity.global_position.distance_to(target.global_position)
		
		# Find the nearest target regardless of attack range
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_target = target
	
	if nearest_target:
		current_target = nearest_target
		emit_signal("target_acquired", current_target)
