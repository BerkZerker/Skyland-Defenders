extends CharacterBody2D

# Enemy properties
@export var movement_speed: float = 100.0
@export var max_health: float = 100.0
@export var attack_damage: float = 10.0
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.0

# State management
var current_health: float = max_health
var can_attack: bool = true
var current_target: Node2D = null
var current_path: Array = []
var path_index: int = 0

# Node references
@onready var attack_area: Area2D = $AttackArea
@onready var visual: ColorRect = $ColorRect

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")

func _physics_process(_delta: float) -> void:
	if current_path.size() > 0 and path_index < current_path.size():
		var target_position = current_path[path_index]
		var direction = (target_position - position).normalized()
		
		velocity = direction * movement_speed
		move_and_slide()
		
		if position.distance_to(target_position) < 5:
			path_index += 1
	elif current_target and can_attack:
		attack_target()

func set_path(new_path: Array) -> void:
	current_path = new_path
	path_index = 0

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0:
		die()

func die() -> void:
	# Emit signal for resource generation
	emit_signal("enemy_died")
	queue_free()

func attack_target() -> void:
	if not current_target:
		return

	can_attack = false
	# Apply damage to target
	if current_target.has_method("take_damage"):
		current_target.take_damage(attack_damage)

	# Start cooldown timer
	get_tree().create_timer(attack_cooldown).timeout.connect(
		func(): can_attack = true
	)

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("defenders"):
		current_target = area.get_parent()
		current_path.clear()

func _on_attack_area_area_exited(area: Area2D) -> void:
	if area.get_parent() == current_target:
		current_target = null

# Signals
signal enemy_died
