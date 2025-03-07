class_name CollisionComponent
extends "res://scripts/components/component.gd"

signal area_entered(area)
signal area_exited(area)
signal body_entered(body)
signal body_exited(body)

@export var collision_radius: float = 16.0
@export var collision_layer: int = 1
@export var collision_mask: int = 1

var area_node: Area2D = null
var collision_shape: CollisionShape2D = null

func initialize() -> void:
	# Create Area2D for collision detection
	area_node = Area2D.new()
	area_node.collision_layer = collision_layer
	area_node.collision_mask = collision_mask
	
	# Create collision shape
	collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = collision_radius
	collision_shape.shape = circle_shape
	
	# Add to scene
	area_node.add_child(collision_shape)
	entity.add_child(area_node)
	
	# Connect signals
	area_node.connect("area_entered", Callable(self, "_on_area_entered"))
	area_node.connect("area_exited", Callable(self, "_on_area_exited"))
	area_node.connect("body_entered", Callable(self, "_on_body_entered"))
	area_node.connect("body_exited", Callable(self, "_on_body_exited"))

func set_collision_radius(radius: float) -> void:
	collision_radius = radius
	
	if collision_shape and collision_shape.shape is CircleShape2D:
		var circle_shape = collision_shape.shape as CircleShape2D
		circle_shape.radius = collision_radius

func set_collision_layer(layer: int) -> void:
	collision_layer = layer
	
	if area_node:
		area_node.collision_layer = collision_layer

func set_collision_mask(mask: int) -> void:
	collision_mask = mask
	
	if area_node:
		area_node.collision_mask = collision_mask

func _on_area_entered(area: Area2D) -> void:
	emit_signal("area_entered", area)

func _on_area_exited(area: Area2D) -> void:
	emit_signal("area_exited", area)

func _on_body_entered(body: Node) -> void:
	emit_signal("body_entered", body)

func _on_body_exited(body: Node) -> void:
	emit_signal("body_exited", body)
