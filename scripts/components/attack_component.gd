extends "res://scripts/components/component.gd"

const EntityScript = preload("res://scripts/entities/entity.gd")
const HealthComponentScript = preload("res://scripts/components/health_component.gd")

signal attack_performed(target)

@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var attack_range: float = 200.0

var can_attack: bool = true
var cooldown_timer: float = 0.0

func process_component(delta: float) -> void:
	if not can_attack:
		cooldown_timer += delta
		if cooldown_timer >= attack_cooldown:
			can_attack = true
			cooldown_timer = 0.0

func attack(target: Node) -> void:
	if can_attack:
		emit_signal("attack_performed", target)
		can_attack = false
		
		# Apply damage if target has a health component
		if target.has_method("has_component") and target.has_component("health"):
			var health_comp = target.get_component("health")
			if health_comp.has_method("take_damage"):
				health_comp.take_damage(attack_damage)
