extends "res://scripts/entities/entity.gd"

# Preload component scripts
const HealthComponentScript = preload("res://scripts/components/health_component.gd")
const AttackComponentScript = preload("res://scripts/components/attack_component.gd")
const VisualComponentScript = preload("res://scripts/components/visual_component.gd")
const CollisionComponentScript = preload("res://scripts/components/collision_component.gd")
const PlacementComponentScript = preload("res://scripts/components/placement_component.gd")
const HealthBarComponentScript = preload("res://scripts/components/health_bar_component.gd")

@export var defender_cost: int = 50
@export var show_attack_radius: bool = false
var is_placed: bool = false

# Component references for quick access
var health_component = null
var attack_component = null
var targeting_component = null
var visual_component = null
var collision_component = null
var placement_component = null
var health_bar_component = null

func _ready() -> void:
	# Add health component
	health_component = HealthComponentScript.new(self)
	health_component.max_health = 100.0
	add_component("health", health_component)
	
	# Add attack component
	attack_component = AttackComponentScript.new(self)
	attack_component.attack_damage = 25.0
	attack_component.attack_cooldown = 1.0
	attack_component.attack_range = 200.0
	add_component("attack", attack_component)
	
	# Add targeting component
	targeting_component = load("res://scripts/components/targeting_component.gd").new(self)
	targeting_component.target_group = "enemies"
	add_component("targeting", targeting_component)
	
	# Add visual component
	visual_component = VisualComponentScript.new(self)
	visual_component.color = Color(0, 0, 1, 1)  # Blue for defenders
	visual_component.size = Vector2(32, 32)
	add_component("visual", visual_component)
	
	# Add collision component
	collision_component = CollisionComponentScript.new(self)
	collision_component.collision_radius = 16.0
	collision_component.collision_layer = 2  # Defender layer
	collision_component.collision_mask = 4   # Enemy layer
	add_component("collision", collision_component)
	
	# Add placement component
	placement_component = PlacementComponentScript.new(self)
	placement_component.cost = defender_cost
	placement_component.show_placement_radius = true
	add_component("placement", placement_component)
	
	# Add health bar component
	health_bar_component = HealthBarComponentScript.new(self)
	add_component("health_bar", health_bar_component)
	
	# Connect signals
	health_component.connect("died", Callable(self, "_on_died"))
	targeting_component.connect("target_acquired", Callable(self, "_on_target_acquired"))
	attack_component.connect("attack_performed", Callable(self, "_on_attack_performed"))
	collision_component.connect("area_entered", Callable(self, "_on_area_entered"))
	collision_component.connect("area_exited", Callable(self, "_on_area_exited"))
	placement_component.connect("placed", Callable(self, "_on_placed"))
	
	# Setup based on placement status
	if not is_placed:
		show_attack_radius = true
	
	# Initialize visual elements
	queue_redraw()

func setup_as_placed_defender() -> void:
	is_placed = true
	add_to_group("defenders")
	
	# Update placement component
	if placement_component:
		placement_component.is_placed = true
	
	# Hide attack radius
	show_attack_radius = false
	queue_redraw()

# Set up the grid system for the placement component
func setup_grid_system(grid_sys) -> void:
	if placement_component:
		placement_component.setup_with_grid_system(grid_sys)

func _on_died() -> void:
	queue_free()

func _on_target_acquired(target: Node) -> void:
	if attack_component and is_placed:
		attack_component.attack(target)

func _on_attack_performed(target: Node) -> void:
	# Create projectile
	var projectile_scene = load("res://scenes/entities/projectile.tscn")
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	# Initialize projectile
	if projectile.has_method("initialize"):
		projectile.initialize(self, target, attack_component.attack_damage)

func _on_area_entered(area: Area2D) -> void:
	# Handle area entered if needed
	pass

func _on_area_exited(area: Area2D) -> void:
	# Handle area exited if needed
	pass

func _on_placed(grid_position: Vector2i) -> void:
	# Handle placement if needed
	pass

func _draw() -> void:
	if show_attack_radius and attack_component:
		var radius = attack_component.attack_range
		
		# Draw filled circle
		draw_circle(Vector2.ZERO, radius, Color(1, 0, 0, 0.2))
		
		# Draw circle outline
		draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(1, 0, 0, 0.5), 2.0)
