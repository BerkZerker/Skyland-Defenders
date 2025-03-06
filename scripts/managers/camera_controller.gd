class_name CameraController
extends Node

# Camera references
@onready var camera = $"../Camera2D"

# Camera settings
@export var camera_pan_speed: float = 1.0  # Camera pan speed multiplier
@export var camera_bounds_min: Vector2 = Vector2(-500, -500)  # Minimum camera position
@export var camera_bounds_max: Vector2 = Vector2(1500, 1500)  # Maximum camera position

func _ready() -> void:
	# Initialize camera position
	reset_camera_position()
	
# Convert screen coordinates to world coordinates
func screen_to_world_position(screen_position: Vector2) -> Vector2:
	# Get the viewport transform and camera transform
	var viewport_transform = get_viewport().get_canvas_transform()
	var camera_transform = camera.get_global_transform()
	
	# Convert screen position to world position
	var world_position = (screen_position - viewport_transform.origin) / viewport_transform.get_scale()
	world_position += camera.position
	
	return world_position

# Convert world coordinates to screen coordinates
func world_to_screen_position(world_position: Vector2) -> Vector2:
	# Get the viewport transform and camera transform
	var viewport_transform = get_viewport().get_canvas_transform()
	var camera_transform = camera.get_global_transform()
	
	# Convert world position to screen position
	var screen_position = world_position - camera.position
	screen_position = screen_position * viewport_transform.get_scale() + viewport_transform.origin
	
	return screen_position

func handle_camera_pan(event: InputEventScreenDrag) -> void:
	# Move camera in the opposite direction of the drag
	var drag_delta = event.relative * -1 * camera_pan_speed
	
	# Apply the movement to the camera
	var new_position = camera.position + drag_delta
	
	# Clamp the camera position within bounds
	new_position.x = clamp(new_position.x, camera_bounds_min.x, camera_bounds_max.x)
	new_position.y = clamp(new_position.y, camera_bounds_min.y, camera_bounds_max.y)
	
	# Update camera position
	camera.position = new_position

func reset_camera_position() -> void:
	# Reset camera to the default position (0, 0)
	if camera:
		camera.position = Vector2.ZERO
