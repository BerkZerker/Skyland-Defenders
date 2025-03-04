class_name Defender
extends Node2D

# Defender properties
@export var attack_range: float = 200.0
@export var show_attack_radius: bool = false
@export var selectable: bool = true  # Whether this defender can be selected
@export var attack_damage: float = 25.0  # Buffed from 10.0 to 25.0
@export var attack_cooldown: float = 1.0
@export var defender_cost: int = 50
@export var max_health: float = 100.0

# Attack radius visual properties
@export var radius_color: Color = Color(1, 0, 0, 0.2)  # Semi-transparent red
@export var radius_border_color: Color = Color(1, 0, 0, 0.5)  # More opaque red for border
@export var radius_border_width: float = 2.0

# Projectile reference
@onready var projectile_scene = preload("res://scenes/projectile.tscn")

# State management
var current_target: Node2D = null
var can_attack: bool = true
var is_placed: bool = false
var current_health: float = max_health

# Node references
@onready var range_area: Area2D = $RangeArea
@onready var health_bar = $HealthBar

func _ready() -> void:
	# Set up the range area
	var collision_shape = range_area.get_node("CollisionShape2D")
	var circle_shape = collision_shape.shape as CircleShape2D
	circle_shape.radius = attack_range
	
	# Initialize health
	current_health = max_health
	
	# Default setup as a template (not placed)
	if health_bar:
		health_bar.visible = false
	
	if range_area:
		range_area.monitoring = false
		range_area.monitorable = false
	
	# Show attack radius for template, hide for placed defenders by default
	show_attack_radius = !is_placed
	queue_redraw()

# Call this method when a defender is actually placed on the grid
func setup_as_placed_defender() -> void:
	is_placed = true
	
	# Add to defenders group
	add_to_group("defenders")
	print("Defender: Added to defenders group")
	
	# Show health bar and update it
	if health_bar:
		health_bar.visible = true
		update_health_bar()
	
	# Enable range area collision
	if range_area:
		range_area.monitoring = true
		range_area.monitorable = true
	
	# Hide attack radius by default when placed
	show_attack_radius = false
	queue_redraw()

func _process(_delta: float) -> void:
	# Skip processing for template defenders
	if not is_placed:
		return
	
	# Only actual placed defenders should look for targets and attack
	if current_target == null:
		find_new_target()
	elif can_attack:
		attack_target()

# Connect to input events on the RangeArea for click detection
func _on_range_area_input_event(_viewport, event, _shape_idx) -> void:
	# Handle click events on the defender
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_placed and selectable:
			toggle_attack_radius()

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
	
	# Create projectile
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.initialize(self, current_target, attack_damage)
	
	# Start cooldown timer
	get_tree().create_timer(attack_cooldown).timeout.connect(
		func(): can_attack = true
	)

func _on_range_area_area_entered(area: Area2D) -> void:
	# Only actual placed defenders should detect enemies
	if not is_placed:
		return
		
	if area.is_in_group("enemies") and current_target == null:
		current_target = area.get_parent()

func take_damage(amount: float) -> void:
	# Only actual placed defenders should take damage
	if not is_placed:
		return
		
	current_health -= amount
	update_health_bar()
	
	if current_health <= 0:
		die()

func die() -> void:
	# In the TileMap version, we don't need to clear cells
	# Just remove from scene
	queue_free()

func update_health_bar() -> void:
	if health_bar:
		var health_percent = current_health / max_health
		health_bar.value = health_percent * 100

# Draw the attack radius
func _draw() -> void:
	if show_attack_radius:
		# Draw filled circle for attack range
		draw_circle(Vector2.ZERO, attack_range, radius_color)
		
		# Draw circle outline for better visibility
		draw_arc(Vector2.ZERO, attack_range, 0, TAU, 64, radius_border_color, radius_border_width)

# Toggle attack radius visibility
func toggle_attack_radius() -> void:
	show_attack_radius = !show_attack_radius
	queue_redraw()

# Setter for attack_range that updates the visualization
func set_attack_range(value: float) -> void:
	attack_range = value
	
	# Update collision shape
	if range_area:
		var collision_shape = range_area.get_node("CollisionShape2D")
		var circle_shape = collision_shape.shape as CircleShape2D
		circle_shape.radius = attack_range
	
	# Update visual radius
	queue_redraw()

func _on_range_area_area_exited(area: Area2D) -> void:
	# Only actual placed defenders should track enemies
	if not is_placed:
		return
		
	if area.get_parent() == current_target:
		current_target = null
