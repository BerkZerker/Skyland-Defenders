extends Node2D

# Signals
signal wave_completed(wave_number)
signal resource_collected(amount)

# Wave properties
@export var enemies_per_wave: int = 5
@export var spawn_interval: float = 2.0
@export var enemy_scene: PackedScene = preload("res://scenes/entities/enemy.tscn")

# Wave state
var current_wave: int = 0
var enemies_spawned: int = 0
var enemies_remaining: int = 0
var is_wave_active: bool = false
var spawn_points: Array[Node] = []

# Node references
@onready var game = get_parent()
@onready var spawn_points_node = $SpawnPoints

func _ready() -> void:
	# Connect to game signals
	if game:
		if not game.wave_started.is_connected(_on_wave_started):
			game.connect("wave_started", _on_wave_started)
	
	# Get spawn points
	for child in spawn_points_node.get_children():
		if child is Marker2D:
			spawn_points.append(child)

func start_wave() -> void:
	if is_wave_active:
		return
	
	if not enemy_scene:
		push_error("Wave System: Enemy scene not loaded")
		return
	
	current_wave += 1
	enemies_spawned = 0
	enemies_remaining = enemies_per_wave + (current_wave - 1) * 2
	is_wave_active = true
	
	# Check if navigation is ready before spawning enemies
	var level = _find_level_node()
	if level and level.has_signal("navigation_ready"):
		if not level.navigation_ready.is_connected(_on_navigation_ready_for_wave):
			level.connect("navigation_ready", Callable(self, "_on_navigation_ready_for_wave"))
		
		# Check if navigation is already ready
		if level.get_navigation_region() and level.get_navigation_region().navigation_polygon:
			print("WaveSystem: Navigation already ready, starting wave")
			spawn_next_enemy()
		else:
			print("WaveSystem: Waiting for navigation to be ready before spawning enemies")
	else:
		# If we can't find the level or it doesn't have the signal, just start spawning
		print("WaveSystem: Could not find Level node with navigation_ready signal, starting wave anyway")
		spawn_next_enemy()

func _find_level_node() -> Node:
	# Find the level node in the scene tree
	var current_node = self
	while current_node:
		if current_node.get_parent() and current_node.get_parent().has_method("get_navigation_region"):
			return current_node.get_parent()
		current_node = current_node.get_parent()
	
	# If we couldn't find it by traversing up, try to find it by name
	var root = get_tree().root
	if root.has_node("Game/Level"):
		return root.get_node("Game/Level")
	
	print("WaveSystem: Could not find Level node")
	return null

func _on_navigation_ready_for_wave() -> void:
	print("WaveSystem: Navigation is ready, starting to spawn enemies")
	spawn_next_enemy()

func spawn_next_enemy() -> void:
	if not is_wave_active or enemies_spawned >= enemies_remaining:
		check_wave_completion()
		return

	if spawn_points.is_empty():
		push_error("Wave System: No spawn points set for wave system")
		return
	
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.position = spawn_point.position
	enemy.connect("enemy_died", _on_enemy_died)
	
	enemies_spawned += 1
	
	if enemies_spawned < enemies_remaining:
		get_tree().create_timer(spawn_interval).timeout.connect(
			func(): spawn_next_enemy()
		)

func check_wave_completion() -> void:
	if enemies_spawned >= enemies_remaining and enemies_remaining <= 0:
		end_wave()

func _on_wave_started(wave_number: int) -> void:
	current_wave = wave_number
	start_wave()

func _on_enemy_died(resource_value: int) -> void:
	enemies_remaining -= 1
	# Emit signal for resource collection
	emit_signal("resource_collected", resource_value)
	check_wave_completion()

func end_wave() -> void:
	is_wave_active = false
	game.end_wave()
	emit_signal("wave_completed", current_wave)

func reset() -> void:
	print("Wave System: Resetting state")
	current_wave = 0
	enemies_spawned = 0
	enemies_remaining = 0
	is_wave_active = false
	
	# Clear any remaining enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
