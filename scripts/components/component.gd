class_name Component
extends Node

# Reference to the parent entity
var entity: Node

func _init(parent_entity: Node) -> void:
	entity = parent_entity

# Called when the component is initialized
# Override in child classes
func initialize() -> void:
	pass

# Called every frame to process component logic
# Override in child classes
func process_component(delta: float) -> void:
	pass
