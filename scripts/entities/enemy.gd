@tool
extends "res://scripts/entities/entity.gd"

# Preload component scripts
const HealthComponentScript = preload("res://scripts/components/health_component.gd")
const AttackComponentScript = preload("res://scripts/components/attack_component.gd")
const MovementComponentScript = preload("res://scripts/components/movement_component.gd")
const VisualComponentScript = preload("res://scripts/components/visual_component.gd")
const CollisionComponentScript = preload("res://scripts/components/collision_component.gd")
const HealthBarComponentScript = preload("res://scripts/components/health_bar_component.gd")
const PathfindingComponentScript = preload("res://scripts/components/pathfinding_component.gd")

signal enemy_died(resource_value)

@export var resource_value: int = 25  # Resources gained when enemy is defeated

# Component references for quick access
var health_component = null
var attack_component = null
var targeting_component = null
var movement_component = null
var visual_component = null
var collision_component = null
var health_bar_component = null
var pathfinding_component = null

func _ready() -> void:
	# Add health component
	health_component = HealthComponentScript.new(self)
	health_component.max_health = 100.0
	add_component("health", health_component)
	
	# Add attack component
	attack_component = AttackComponentScript.new(self)
	attack_component.attack_damage = 10.0
	attack_component.attack_cooldown = 1.0
	attack_component.attack_range = 40.0
	add_component("attack", attack_component)
	
	# Add targeting component
	targeting_component = load("res://scripts/components/targeting_component.gd").new(self)
	targeting_component.target_group = "defenders"
	add_component("targeting", targeting_component)
	
	# Add movement component
	movement_component = MovementComponentScript.new(self)
	movement_component.movement_speed = 100.0
	add_component("movement", movement_component)
	
	# Add visual component
	visual_component = VisualComponentScript.new(self)
	visual_component.color = Color(1, 0, 0, 1)  # Red for enemies
	visual_component.size = Vector2(32, 32)
	add_component("visual", visual_component)
	
	# Add collision component
	collision_component = CollisionComponentScript.new(self)
	collision_component.collision_radius = 16.0
	collision_component.collision_layer = 4  # Enemy layer
	collision_component.collision_mask = 2   # Defender layer
	add_component("collision", collision_component)
	
	# Add health bar component
	health_bar_component = HealthBarComponentScript.new(self)
	add_component("health_bar", health_bar_component)
	
	# Add pathfinding component
	pathfinding_component = PathfindingComponentScript.new(self)
	add_component("pathfinding", pathfinding_component)
	
	# Connect signals
	health_component.connect("died", Callable(self, "_on_died"))
	targeting_component.connect("target_acquired", Callable(self, "_on_target_acquired"))
	targeting_component.connect("target_lost", Callable(self, "_on_target_lost"))
	collision_component.connect("area_entered", Callable(self, "_on_area_entered"))
	collision_component.connect("area_exited", Callable(self, "_on_area_exited"))
	
	# Add to enemies group
	add_to_group("enemies")

func _process(delta: float) -> void:
	# Handle movement if we have a target
	if targeting_component.current_target and is_instance_valid(targeting_component.current_target):
		var distance = global_position.distance_to(targeting_component.current_target.global_position)
		
		if distance > attack_component.attack_range:
			# Move towards target
			movement_component.move_towards(targeting_component.current_target.global_position, delta)
		elif attack_component.can_attack:
			# Attack target
			attack_component.attack(targeting_component.current_target)

func _on_died() -> void:
	emit_signal("enemy_died", resource_value)
	queue_free()

func _on_target_acquired(target: Node) -> void:
	# Target acquired, handled in _process
	pass

func _on_target_lost() -> void:
	# Target lost, find a new one
	targeting_component.find_new_target()

func _on_area_entered(area: Area2D) -> void:
	# Check if this is a defender area
	if area.get_parent() and area.get_parent().is_in_group("defenders"):
		targeting_component.current_target = area.get_parent()

func _on_area_exited(area: Area2D) -> void:
	# Check if this was our current target
	if area.get_parent() and area.get_parent() == targeting_component.current_target:
		targeting_component.current_target = null
		targeting_component.find_new_target()

func take_damage(amount: float) -> void:
	if health_component:
		health_component.take_damage(amount)
