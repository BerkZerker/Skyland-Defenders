extends Node2D

# Game state management
var current_resources: int = 100
var current_wave: int = 0
var is_wave_active: bool = false
var placing_defender: bool = false
var defender_template: Node2D = null

# Preload defender scene
@onready var defender_scene = preload("res://scenes/defender.tscn")
@onready var grid_system = $GridSystem
@onready var resource_label = $UI/TopPanel/ResourceLabel
@onready var wave_label = $UI/TopPanel/WaveLabel

func _ready() -> void:
	# Clean up any existing defender template
	if defender_template:
		defender_template.queue_free()
		defender_template = null
		placing_defender = false

	initialize_game()
	update_ui()

func initialize_game() -> void:
	current_resources = 100
	current_wave = 0
	is_wave_active = false
	update_ui()

func _input(event: InputEvent) -> void:
	# Handle both touch and mouse input
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Simulate touch event with mouse
			var touch_event = InputEventScreenTouch.new()
			touch_event.position = event.position
			touch_event.pressed = event.pressed
			handle_touch(touch_event)

	# Update defender template position for mouse movement
	elif event is InputEventMouseMotion and placing_defender and defender_template:
		var grid_pos = grid_system.get_grid_position(event.position)
		var world_pos = grid_system.get_cell_position(grid_pos)
		defender_template.position = world_pos

		# Update template color based on valid placement
		if grid_system.is_cell_valid_for_placement(grid_pos):
			defender_template.modulate = Color(0, 1, 0, 0.5)  # Semi-transparent green
		else:
			defender_template.modulate = Color(1, 0, 0, 0.5)  # Semi-transparent red

func handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# If we're not placing a defender, start placement
		if not placing_defender:
			start_defender_placement()
		# If we are placing, try to place at touch location
		else:
			try_place_defender(event.position)

func start_defender_placement() -> void:
	if current_resources < 50:  # Defender cost
		return

	# Clean up any existing template first
	if defender_template:
		defender_template.queue_free()
		defender_template = null

	placing_defender = true
	defender_template = defender_scene.instantiate()
	defender_template.modulate = Color(0, 1, 0, 0.5)  # Start with green
	add_child(defender_template)

func try_place_defender(touch_position: Vector2) -> void:
	if not defender_template:
		return

	var grid_position = grid_system.get_grid_position(touch_position)

	if grid_system.is_cell_valid_for_placement(grid_position) and current_resources >= 50:
		# Create actual defender
		var defender = defender_scene.instantiate()
		add_child(defender)

		if grid_system.place_defender(grid_position, defender):
			current_resources -= 50
			defender.is_placed = true
			update_ui()

	# Clean up template whether placement was successful or not
	defender_template.queue_free()
	defender_template = null
	placing_defender = false

func start_wave() -> void:
	if is_wave_active:
		return

	current_wave += 1
	is_wave_active = true
	wave_label.text = "Wave: " + str(current_wave)
	emit_signal("wave_started", current_wave)

func end_wave() -> void:
	is_wave_active = false
	emit_signal("wave_ended", current_wave)

func _on_resource_collected(amount: int) -> void:
	current_resources += amount
	update_ui()

func _on_defender_placed(cost: int) -> void:
	current_resources -= cost
	update_ui()

func update_ui() -> void:
	resource_label.text = "Resources: " + str(current_resources)
	wave_label.text = "Wave: " + str(current_wave)

# Signals
signal wave_started(wave_number)
signal wave_ended(wave_number)
