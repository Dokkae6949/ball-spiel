extends CharacterBody2D
class_name Player

const MAX_SPEED: float = 400
const SKID_SPEED: float = 800
const ACCELERATION: float = 500
const START_SPEED: float = 1200

var direction: Vector2

@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	if is_multiplayer_authority():
		Glob.player = self
		camera.make_current()

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_collisions()
	Glob.debug_panel.add_property('Velocity', str(velocity), 2)
	move_and_slide()


func _handle_movement(delta: float) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if not direction.is_zero_approx():
		# Init first move
		if velocity.length() < START_SPEED * delta:
			velocity = direction * START_SPEED * delta
		# Handle move acceleration
		else:
			for axis: StringName in ["x", "y"]:
				velocity[axis] += direction[axis] * ACCELERATION * delta
	else:
		for axis: StringName in ["x", "y"]:
			velocity[axis] = move_toward(velocity[axis], 0, SKID_SPEED * delta)

	# Prevent too fast movement
	velocity = velocity.limit_length(MAX_SPEED)


func _handle_collisions() -> void:
	# Reset velocity when hitting wall straight on.
	if direction.is_zero_approx(): return
	for i: int in get_slide_collision_count():
		var col: KinematicCollision2D = get_slide_collision(i)
		var col_normal: Vector2 = col.get_normal()
		var angle_to_col: float = rad_to_deg(col_normal.angle_to(direction))
		if (angle_to_col > 179 and angle_to_col < 181) or (angle_to_col < -179 and angle_to_col > -181):
			for axis: StringName in ["x", "y"]:
				if col_normal[axis] > 0.0001 or col_normal[axis] < 0.0001:
					velocity[axis] = 0.0
