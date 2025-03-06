class_name Game
extends Node2D

# Signals
signal wave_started(wave_number)
signal wave_ended(wave_number)

# Game state management
var current_resources: int = 100
var current_wave: int = 0
var is_wave_active: bool = false
var game_over: bool = false
var victory: bool = false

# Game settings
@export var max_waves: int = 5  # Number of waves to survive for victory

# Node references
@onready var level = $Level
@onready var grid_system = null  # Will be set in _ready()
@onready var wave_system = $WaveSystem
@onready var ui_manager = $UIManager
@onready var camera_controller = $CameraController
@onready var defender_placement_manager = $DefenderPlacementManager

func _ready() -> void:
	print("Game: _ready() called")
	
	# Get grid system from level
	if level:
		grid_system = level.get_grid_system()
	else:
		push_error("Game: Level node not found")
	
	# Verify wave system
	if not wave_system:
		push_error("Game: Wave system not found")
	else:
		# Connect to wave system signals
		if not wave_system.resource_collected.is_connected(_on_resource_collected):
			wave_system.connect("resource_collected", _on_resource_collected)
		if not wave_system.wave_completed.is_connected(_on_wave_completed):
			wave_system.connect("wave_completed", _on_wave_completed)
	
	# Connect to window resize signal
	get_viewport().connect("size_changed", Callable(self, "_on_window_resize"))
	
	initialize_game()
	ui_manager.update_ui(current_resources, current_wave, max_waves, is_wave_active, game_over)

func _on_window_resize() -> void:
	# No need to center camera anymore since we're using global coordinates
	pass

func initialize_game() -> void:
	print("Game: Initializing game state")
	current_resources = 100
	current_wave = 0
	is_wave_active = false
	game_over = false
	victory = false
	
	# Reset camera position
	camera_controller.reset_camera_position()
	
	ui_manager.update_ui(current_resources, current_wave, max_waves, is_wave_active, game_over)

func _input(event: InputEvent) -> void:
	# Handle only touch input
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_camera_pan(event)

func handle_touch(event: InputEventScreenTouch) -> void:
	# For touch down (pressed), show the defender template
	if event.pressed:
		if defender_placement_manager.is_placing():
			defender_placement_manager.show_defender_template(event.position)
	# For touch up (released), try to place the defender
	else:
		# Only handle touch for placing a defender if we're already in placement mode
		if defender_placement_manager.is_placing():
			var cost = defender_placement_manager.try_place_defender(event.position, current_resources)
			if cost > 0:
				current_resources -= cost
				ui_manager.update_ui(current_resources, current_wave, max_waves, is_wave_active, game_over)

func handle_camera_pan(event: InputEventScreenDrag) -> void:
	# Only allow camera panning when not placing a defender
	if not defender_placement_manager.is_placing():
		camera_controller.handle_camera_pan(event)
	else:
		# Update defender template position during drag
		defender_placement_manager.update_template_position(event.position)

# This function is called directly from the PlaceDefenderButton in the scene
func start_defender_placement() -> void:
	defender_placement_manager.start_defender_placement(current_resources)

func start_wave() -> void:
	print("Game: Attempting to start wave")
	if is_wave_active:
		print("Game: Wave already active, ignoring start request")
		return
	
	current_wave += 1
	is_wave_active = true
	print("Game: Starting wave " + str(current_wave))
	emit_signal("wave_started", current_wave)
	ui_manager.update_ui(current_resources, current_wave, max_waves, is_wave_active, game_over)

func end_wave() -> void:
	print("Game: Ending wave " + str(current_wave))
	is_wave_active = false
	emit_signal("wave_ended", current_wave)
	
	# Check for victory condition
	if current_wave >= max_waves:
		victory = true
		game_over = true
		print("Game: Victory achieved! All waves survived.")
		ui_manager.show_victory_screen()

func _on_resource_collected(amount: int) -> void:
	if game_over:
		return
		
	current_resources += amount
	print("Game: Resources collected: " + str(amount) + ", total: " + str(current_resources))
	ui_manager.update_ui(current_resources, current_wave, max_waves, is_wave_active, game_over)

func _on_wave_completed(wave_number: int) -> void:
	print("Game: Wave " + str(wave_number) + " completed")
	
	# Check for defenders
	check_defenders()

func check_defenders() -> void:
	var defenders = get_tree().get_nodes_in_group("defenders")
	
	if defenders.size() == 0 and current_wave > 0:
		game_over = true
		victory = false
		print("Game: Game over! All defenders destroyed.")
		ui_manager.show_game_over_screen()

func _on_start_wave_button_pressed() -> void:
	print("Game: Start wave button pressed")
	if not is_wave_active and not game_over:
		start_wave()

func _on_pause_button_pressed() -> void:
	print("Game: Pause button pressed")
	var paused = get_tree().paused
	get_tree().paused = !paused
	print("Game: Toggling pause state from " + str(paused) + " to " + str(!paused))
	
	# Update the button text based on the current pause state
	ui_manager.update_pause_button_text(get_tree().paused)

func _on_restart_button_pressed() -> void:
	print("Game: Restart button pressed")
	
	# Force unpause the game first
	var was_paused = get_tree().paused
	get_tree().paused = false
	print("Game: Forced unpause during restart (was paused: " + str(was_paused) + ")")
	
	# Reset game state
	initialize_game()
	
	# Clear all enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	print("Game: Clearing " + str(enemies.size()) + " enemies")
	for enemy in enemies:
		enemy.queue_free()
	
	# Clear all defenders
	var defenders = get_tree().get_nodes_in_group("defenders")
	print("Game: Clearing " + str(defenders.size()) + " defenders")
	for defender in defenders:
		defender.queue_free()
	
	# Reset level
	if level:
		level.load_level_data()
		print("Game: Level reset")
	else:
		print("Game: Level not found")
	
	# Hide game over and victory panels
	ui_manager.hide_end_game_screens()
	
	# Make sure pause button is reset
	ui_manager.update_pause_button_text(false)
	
	# Reset wave system if it exists
	if wave_system:
		wave_system.reset()
		print("Game: Wave system reset")
	else:
		print("Game: Wave system not found")
	
	# Clean up any defender template
	defender_placement_manager.cleanup_template()
	
	ui_manager.update_ui(current_resources, current_wave, max_waves, is_wave_active, game_over)
	print("Game: Restart completed")

func _on_reset_camera_button_pressed() -> void:
	camera_controller.reset_camera_position()
