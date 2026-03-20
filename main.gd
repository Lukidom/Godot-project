extends Node2D

@export var wall_scene: PackedScene
@export var mirror_scene: PackedScene

var points: Array = []
var max_bounces: int = 10
var laser_length: float = 2000.0

func _ready():
	randomize()
	generate_level()
	shoot_laser()

func shoot_laser():
	points.clear()

	var origin: Vector2 = $LaserStart.global_position
	var direction: Vector2 = Vector2.RIGHT.rotated($LaserStart.global_rotation)

	points.append(origin)

	cast_ray(origin, direction, max_bounces)

	queue_redraw()

func cast_ray(origin: Vector2, direction: Vector2, bounces_left: int):
	if bounces_left <= 0:
		points.append(origin + direction * laser_length)
		return

	var space = get_world_2d().direct_space_state

	# ✅ Godot 4 raycast fix
	var query = PhysicsRayQueryParameters2D.create(
		origin,
		origin + direction * laser_length
	)

	var result = space.intersect_ray(query)

	if result:
		var hit_pos: Vector2 = result.position
		var collider = result.collider

		points.append(hit_pos)

		# Safety check: make sure collider is valid
		if collider == null:
			return

		if collider.is_in_group("goal"):
			print("YOU WIN")
			return

		elif collider.is_in_group("mirror"):
			# Make sure this function exists on your mirror script
			if collider.has_method("get_reflect_direction"):
				var new_dir: Vector2 = collider.get_reflect_direction(direction, hit_pos)

				if new_dir == Vector2.ZERO:
					return

				cast_ray(hit_pos, new_dir, bounces_left - 1)
			else:
				print("Mirror missing get_reflect_direction()")
				return
		else:
			return
	else:
		points.append(origin + direction * laser_length)

func _draw():
	if points.size() < 2:
		return

	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color.RED, 3)

func generate_level():
	# Walls
	for i in range(10):
		var wall = wall_scene.instantiate()
		wall.position = Vector2(randf_range(100, 800), randf_range(100, 600))
		$Walls.add_child(wall)

	# Mirrors
	for i in range(5):
		var mirror = mirror_scene.instantiate()
		mirror.position = Vector2(randf_range(100, 800), randf_range(100, 600))
		mirror.rotation = randf_range(0, PI * 2)
		$Mirrors.add_child(mirror)
