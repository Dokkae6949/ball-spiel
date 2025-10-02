extends RigidBody2D
class_name Player

const MAX_SPEED: float = 120
const SKID_SPEED: float = 160
const ACCELERATION: float = 34000

var direction: Vector2

@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	set_multiplayer_authority(int(name))

	if name == str(multiplayer.get_unique_id()):
		Glob.player = self
		camera.make_current()
	else:
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_limit_move_speed()
	Glob.debug_panel.add_property('Velocity', str(linear_velocity), 2)


func _handle_movement(delta: float) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if not direction.is_zero_approx():
		apply_central_force(direction * ACCELERATION)
	else:
		linear_velocity = linear_velocity.move_toward(Vector2.ZERO, SKID_SPEED * delta)


func _limit_move_speed() -> void:
	if linear_velocity.length_squared() > MAX_SPEED*MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED
