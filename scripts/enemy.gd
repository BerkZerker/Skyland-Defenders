extends CharacterBody2D

# Enemy properties
@export var movement_speed: float = 100.0
@export var max_health: float = 100.0
@export var attack_damage: float = 10.0
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.0
@export var target_update_interval: float = 1.0  # How often to update target

# State management
var current_health: float = max_health
var can_attack: bool = true
var current_target: Node2D = null
var target_update_timer: float = 0.0

# Movement and pathing
var path_to_target: Vector2 = Vector2.ZERO
var last_target_pos: Vector2 = Vector2.ZERO

# Node references
@onready var attack_area: Area2D = $AttackArea
@onready var visual: ColorRect = $ColorRect
@onready var path_line: Line2D = $PathLine if has_node("PathLine") else null

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	print("Enemy: Added to enemies group")
	
	# Initialize path visualization if it doesn't exist
	if not path_line and Engine.is_editor_hint() == false:
		path_line = Line2D.new()
		path_line.name = "PathLine"
		path_line.width = 2.0
		path_line.default_color = Color(1, 0, 0, 0.4)  # Semi-transparent red
		path_line.z_index = -1  # Draw behind the enemy
		add_child(path_line)
	
	# Find defenders right away
	find_closest_defender()

func _physics_process(delta: float) -> void:
	# Update target periodically to always move toward closest defender
	target_update_timer += delta
	if target_update_timer >= target_update_interval:
		target_update_timer = 0
		find_closest_defender()
	
	if current_target:
		print("Enemy: Moving toward target at ", current_target.position)
		# Check if we're in attack range
		var distance_to_target = position.distance_to(current_target.position)
		
		if distance_to_target > attack_range:
			# Update path if target moved significantly
			if last_target_pos.distance_to(current_target.position) > 20:
				update_path_to_target()
			
			# Move towards target using linear movement
			var direction = (current_target.position - position).normalized()
			velocity = direction * movement_speed
			print("Enemy: Moving with velocity ", velocity)
			move_and_slide()
			print("Enemy: New position ", position)
			
			# Update path visualization
			update_path_visualization()
		elif can_attack:
			attack_target()
	else:
		print("Enemy: No target found, searching...")
		find_closest_defender()

func find_closest_defender() -> void:
	var defenders = get_tree().get_nodes_in_group("defenders")
	print("Enemy: Searching for defenders, found: ", defenders.size())
	
	if defenders.size() > 0:
		var closest_defender = null
		var closest_distance = INF
		
		for defender in defenders:
			var distance = position.distance_to(defender.position)
			if distance < closest_distance:
				closest_distance = distance
				closest_defender = defender
		
		current_target = closest_defender
		print("Enemy: Found target at position ", current_target.position if current_target else "none")
		
		if current_target:
			last_target_pos = current_target.position
			update_path_to_target()

func update_path_to_target() -> void:
	if current_target:
		# For basic linear movement, the path is just a straight line
		path_to_target = current_target.position
		last_target_pos = current_target.position

func update_path_visualization() -> void:
	if path_line and current_target:
		path_line.clear_points()
		path_line.add_point(Vector2.ZERO)  # Local origin point
		path_line.add_point(current_target.position - position)  # Direction to target

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
		update_path_to_target()

func _on_attack_area_area_exited(area: Area2D) -> void:
	if area.get_parent() == current_target:
		current_target = null
		find_closest_defender()

# Signals
signal enemy_died
