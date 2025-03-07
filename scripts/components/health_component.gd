class_name HealthComponent
extends "res://scripts/components/component.gd"

signal health_changed(current_health, max_health)
signal died()

@export var max_health: float = 100.0
var current_health: float

func initialize() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	current_health -= amount
	emit_signal("health_changed", current_health, max_health)
	
	if current_health <= 0:
		emit_signal("died")

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", current_health, max_health)

func get_health_percent() -> float:
	return current_health / max_health
