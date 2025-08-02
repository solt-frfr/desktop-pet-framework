extends Area2D

@export var sprite : AnimatedSprite2D
var active_shape : CollisionShape2D = null

func _ready() -> void:
	use_shape("startup", 0)

func use_shape(name: String, frame: int):
	var parent = find_child(name)
	if (parent == null):
		use_shape("idle0", 0)
		return
	var child = parent.find_child(str(frame))
	if (child == null):
		if frame <= 0:
			use_shape(name, frame)
		else:
			use_shape(name, frame - 1)
		return
	var shape = child.duplicate()
	if active_shape != null:
		remove_child(active_shape)
		active_shape.queue_free()
	add_child(shape)
	active_shape = shape

func _on_sprite_frame_changed() -> void:
	use_shape(sprite.animation, sprite.frame)


func _on_sprite_animation_changed() -> void:
	use_shape(sprite.animation, sprite.frame)
