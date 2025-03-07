class_name VisualComponent
extends "res://scripts/components/component.gd"

@export var texture: Texture2D = null
@export var color: Color = Color(1, 1, 1, 1)
@export var size: Vector2 = Vector2(32, 32)

var visual_node: Node = null

func initialize() -> void:
	# Create visual representation based on the type of entity
	if texture:
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.modulate = color
		visual_node = sprite
	else:
		var rect = ColorRect.new()
		rect.color = color
		rect.size = size
		rect.position = -size / 2  # Center the rectangle
		visual_node = rect
	
	entity.add_child(visual_node)

func set_color(new_color: Color) -> void:
	color = new_color
	
	if visual_node is Sprite2D:
		visual_node.modulate = color
	elif visual_node is ColorRect:
		visual_node.color = color

func set_texture(new_texture: Texture2D) -> void:
	texture = new_texture
	
	if visual_node is Sprite2D:
		visual_node.texture = texture
	elif texture and visual_node is ColorRect:
		# Replace ColorRect with Sprite2D
		visual_node.queue_free()
		
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.modulate = color
		visual_node = sprite
		
		entity.add_child(visual_node)
