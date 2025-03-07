extends "res://scripts/entities/entity.gd"

# Preload component scripts
const VisualComponentScript = preload("res://scripts/components/visual_component.gd")
const ProjectileComponentScript = preload("res://scripts/components/projectile_component.gd")

# Component references for quick access
var visual_component = null
var projectile_component = null

func _ready() -> void:
	# Add visual component
	visual_component = VisualComponentScript.new(self)
	visual_component.color = Color(0.7, 0, 1, 1)  # Purple for projectiles
	visual_component.size = Vector2(8, 8)
	add_component("visual", visual_component)
	
	# Add projectile component
	projectile_component = ProjectileComponentScript.new(self)
	projectile_component.speed = 300.0
	add_component("projectile", projectile_component)
	
	# Connect signals
	projectile_component.connect("hit_target", Callable(self, "_on_hit_target"))

func initialize(source_node: Node, target_node: Node, damage_amount: float) -> void:
	if projectile_component:
		projectile_component.setup(source_node, target_node, damage_amount)

func _on_hit_target(target: Node) -> void:
	# Handle hit target event if needed
	pass
