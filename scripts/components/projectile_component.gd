class_name ProjectileComponent
extends "res://scripts/components/component.gd"

signal hit_target(target)

@export var speed: float = 300.0
@export var damage: float = 10.0
@export var lifetime: float = 5.0  # Maximum lifetime in seconds

var target: Node = null
var source: Node = null
var current_lifetime: float = 0.0

func initialize() -> void:
	current_lifetime = 0.0

func setup(source_node: Node, target_node: Node, damage_amount: float) -> void:
	source = source_node
	target = target_node
	damage = damage_amount
	
	# Set initial position
	if source:
		entity.global_position = source.global_position

func process_component(delta: float) -> void:
	# Check if target is still valid
	if not target or not is_instance_valid(target):
		entity.queue_free()
		return
	
	# Move towards target
	var direction = (target.global_position - entity.global_position).normalized()
	entity.global_position += direction * speed * delta
	
	# Check if we've reached the target
	if entity.global_position.distance_to(target.global_position) < 10:
		handle_hit_target()
	
	# Check lifetime
	current_lifetime += delta
	if current_lifetime >= lifetime:
		entity.queue_free()

func handle_hit_target() -> void:
	emit_signal("hit_target", target)
	
	# Apply damage if target has a health component
	if target.has_method("has_component") and target.has_component("health"):
		var health_comp = target.get_component("health")
		if health_comp.has_method("take_damage"):
			health_comp.take_damage(damage)
	
	# Destroy projectile
	entity.queue_free()
