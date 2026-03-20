extends Node2D

@onready var normal: Vector2 = Vector2.UP.rotated(rotation)

func get_reflect_direction(incoming_dir: Vector2, hit_pos: Vector2) -> Vector2:
	# Recalculate normal in case mirror rotates
	normal = Vector2.UP.rotated(global_rotation)

	# Reflect the incoming ray
	var reflected = incoming_dir.bounce(normal)

	return reflected.normalized()
