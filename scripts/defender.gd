extends Node2D

# Defender properties
@export var attack_range: float = 200.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var defender_cost: int = 50

# State management
var current_target: Node2D = null
var can_attack: bool = true
var is_placed: bool = false

# Node references
@onready var range_area: Area2D = $RangeArea

func _ready() -> void:
	# Add to defenders group
	add_to_group("defenders")
	print("Defender: Added to defenders group")
	
	# Set up the range area
	var collision_shape = range_area.get_node("CollisionShape2D")
	var circle_shape = collision_shape.shape as CircleShape2D
	circle_shape.radius = attack_range

func _process(_delta: float) -> void:
	if not is_placed:
		return
	
	if current_target == null:
		find_new_target()
	elif can_attack:
		attack_target()

func find_new_target() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_distance = INF
	var nearest_enemy = null
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= attack_range and distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	
	current_target = nearest_enemy

func attack_target() -> void:
	if current_target == null:
		return
	
	can_attack = false
	# Apply damage to target
	if current_target.has_method("take_damage"):
		current_target.take_damage(attack_damage)
	
	# Start cooldown timer
	get_tree().create_timer(attack_cooldown).timeout.connect(
		func(): can_attack = true
	)

func _on_range_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") and current_target == null:
		current_target = area.get_parent()

func _on_range_area_area_exited(area: Area2D) -> void:
	if area.get_parent() == current_target:
		current_target = null
