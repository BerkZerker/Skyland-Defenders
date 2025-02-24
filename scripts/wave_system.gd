extends Node2D

# Wave properties
@export var enemies_per_wave: int = 5
@export var spawn_interval: float = 2.0
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")

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
    game.connect("wave_started", _on_wave_started)
    
    # Get spawn points
    for child in spawn_points_node.get_children():
        if child is Marker2D:
            spawn_points.append(child)
    
    if spawn_points.is_empty():
        push_error("No spawn points found in SpawnPoints node")

func start_wave() -> void:
    if is_wave_active:
        return
        
    current_wave += 1
    enemies_spawned = 0
    enemies_remaining = enemies_per_wave + (current_wave - 1) * 2
    is_wave_active = true
    
    # Start spawning enemies
    spawn_next_enemy()

func spawn_next_enemy() -> void:
    if not is_wave_active or enemies_spawned >= enemies_remaining:
        check_wave_completion()
        return

    if spawn_points.is_empty():
        push_error("No spawn points set for wave system")
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

func _on_enemy_died() -> void:
    enemies_remaining -= 1
    check_wave_completion()

func end_wave() -> void:
    is_wave_active = false
    game.end_wave()
    emit_signal("wave_completed", current_wave)

# Signals
signal wave_completed(wave_number)