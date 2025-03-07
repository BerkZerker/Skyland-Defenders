class_name HealthBarComponent
extends "res://scripts/components/component.gd"

@export var bar_width: float = 32.0
@export var bar_height: float = 4.0
@export var bar_offset: Vector2 = Vector2(0, -20)  # Offset from entity center
@export var background_color: Color = Color(0.2, 0.2, 0.2, 0.8)
@export var fill_color: Color = Color(0, 1, 0, 0.8)  # Green

var health_component = null
var background_rect = null
var fill_rect = null

func initialize() -> void:
	# Find the health component
	if entity.has_method("has_component") and entity.has_component("health"):
		health_component = entity.get_component("health")
		
		# Connect to health changed signal
		if not health_component.health_changed.is_connected(update_health_bar):
			health_component.connect("health_changed", Callable(self, "update_health_bar"))
		
		# Create health bar visuals
		create_health_bar()
		
		# Initial update
		update_health_bar(health_component.current_health, health_component.max_health)
	else:
		push_error("HealthBarComponent: No health component found on entity")

func create_health_bar() -> void:
	# Create a container node for the health bar
	var container = Node2D.new()
	container.position = bar_offset
	container.z_index = 10  # Make sure it's above other visuals
	entity.add_child(container)
	
	# Create background rectangle
	background_rect = ColorRect.new()
	background_rect.color = background_color
	background_rect.size = Vector2(bar_width, bar_height)
	background_rect.position = Vector2(-bar_width / 2, -bar_height / 2)
	container.add_child(background_rect)
	
	# Create fill rectangle
	fill_rect = ColorRect.new()
	fill_rect.color = fill_color
	fill_rect.size = Vector2(bar_width, bar_height)
	fill_rect.position = Vector2(-bar_width / 2, -bar_height / 2)
	container.add_child(fill_rect)

func update_health_bar(current_health: float, max_health: float) -> void:
	if fill_rect:
		var health_percent = current_health / max_health
		fill_rect.size.x = bar_width * health_percent
