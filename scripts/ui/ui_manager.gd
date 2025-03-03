class_name UIManager
extends Node

# UI References
@onready var resource_label = $"../UI/TopPanel/ResourceLabel"
@onready var wave_label = $"../UI/TopPanel/WaveLabel"
@onready var game_over_panel = $"../UI/GameOverPanel"
@onready var victory_panel = $"../UI/VictoryPanel"
@onready var start_wave_button = $"../UI/ControlPanel/StartWaveButton"
@onready var pause_button = $"../UI/ControlPanel/PauseButton"
@onready var restart_button = $"../UI/ControlPanel/RestartButton"
@onready var reset_camera_button = $"../UI/BottomPanel/ResetCameraButton"
@onready var place_defender_button = $"../UI/BottomPanel/PlaceDefenderButton"

# Reference to the game node
@onready var game = get_parent()

func _ready() -> void:
	# Connect UI button signals
	if start_wave_button:
		if not start_wave_button.pressed.is_connected(game._on_start_wave_button_pressed):
			start_wave_button.connect("pressed", Callable(game, "_on_start_wave_button_pressed"))
	if pause_button:
		if not pause_button.pressed.is_connected(game._on_pause_button_pressed):
			pause_button.connect("pressed", Callable(game, "_on_pause_button_pressed"))
	if restart_button:
		if not restart_button.pressed.is_connected(game._on_restart_button_pressed):
			restart_button.connect("pressed", Callable(game, "_on_restart_button_pressed"))
	if reset_camera_button:
		if not reset_camera_button.pressed.is_connected(game._on_reset_camera_button_pressed):
			reset_camera_button.connect("pressed", Callable(game, "_on_reset_camera_button_pressed"))
	
	# Hide game over and victory panels
	if game_over_panel:
		game_over_panel.visible = false
	if victory_panel:
		victory_panel.visible = false

func update_ui(current_resources: int, current_wave: int, max_waves: int, is_wave_active: bool, game_over: bool) -> void:
	if resource_label:
		resource_label.text = "Resources: " + str(current_resources)
	if wave_label:
		wave_label.text = "Wave: " + str(current_wave) + "/" + str(max_waves)
	
	# Update button states
	if start_wave_button:
		start_wave_button.disabled = is_wave_active or game_over
	if pause_button:
		pause_button.disabled = game_over
	if restart_button:
		restart_button.disabled = false

func show_game_over_screen() -> void:
	if game_over_panel:
		game_over_panel.visible = true
	
	# Pause the game
	get_tree().paused = true
	if pause_button:
		pause_button.text = "Resume"

func show_victory_screen() -> void:
	if victory_panel:
		victory_panel.visible = true
	
	# Pause the game
	get_tree().paused = true
	if pause_button:
		pause_button.text = "Resume"

func hide_end_game_screens() -> void:
	if game_over_panel:
		game_over_panel.visible = false
	if victory_panel:
		victory_panel.visible = false
	
	# Make sure pause button is reset
	if pause_button:
		pause_button.text = "Pause"

func update_pause_button_text(paused: bool) -> void:
	if pause_button:
		if paused:
			pause_button.text = "Resume"
		else:
			pause_button.text = "Pause"
