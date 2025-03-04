class_name Projectile
extends Node2D

# Projectile properties
var speed: float = 300.0
var damage: float = 0.0
var target: Node2D = null
var source: Node2D = null

# The visual is now defined in the scene tree

func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		# Target no longer exists, destroy projectile
		queue_free()
		return
	
	# Move towards target
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# Check if we've reached the target
	if global_position.distance_to(target.global_position) < 10:
		hit_target()

func hit_target() -> void:
	if target and target.has_method("take_damage"):
		target.take_damage(damage)
	queue_free()

func initialize(source_node: Node2D, target_node: Node2D, damage_amount: float) -> void:
	source = source_node
	target = target_node
	damage = damage_amount
	global_position = source.global_position
