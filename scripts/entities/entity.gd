extends Node2D

# Dictionary to store components (component_name -> Component instance)
var components: Dictionary = {}

# Add a component to the entity
func add_component(component_name: String, component: Node) -> void:
	components[component_name] = component
	add_child(component)
	component.initialize()

# Get a component by name
func get_component(component_name: String) -> Node:
	return components.get(component_name)

# Check if the entity has a component
func has_component(component_name: String) -> bool:
	return components.has(component_name)

# Remove a component from the entity
func remove_component(component_name: String) -> void:
	if components.has(component_name):
		var component = components[component_name]
		components.erase(component_name)
		remove_child(component)
		component.queue_free()

# Process all components
func _process(delta: float) -> void:
	for component in components.values():
		component.process_component(delta)
