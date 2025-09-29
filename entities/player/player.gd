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
	move_and_slide()
	Glob.debug_panel.add_property('Velocity', str(velocity), 2)


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
