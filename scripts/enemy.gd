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

# Node references
@onready var attack_area: Area2D = $AttackArea
@onready var visual: ColorRect = $ColorRect

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	find_closest_defender()

func _physics_process(delta: float) -> void:
	if current_target:
		if position.distance_to(current_target.position) > attack_range:
			# Move towards target
			var direction = (current_target.position - position).normalized()
			velocity = direction * movement_speed
			move_and_slide()
		elif can_attack:
			attack_target()
	else:
		find_closest_defender()

func find_closest_defender() -> void:
	var defenders = get_tree().get_nodes_in_group("defenders")
	if defenders.size() > 0:
		var closest_defender = null
		var closest_distance = INF
		
		for defender in defenders:
			var distance = position.distance_to(defender.position)
			if distance < closest_distance:
				closest_distance = distance
				closest_defender = defender
		
		current_target = closest_defender

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0:
		die()

func die() -> void:
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

func _on_attack_area_area_exited(area: Area2D) -> void:
	if area.get_parent() == current_target:
		current_target = null
		find_closest_defender()

# Signals
signal enemy_died
