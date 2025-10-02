extends RigidBody2D
class_name Player

const MAX_SPEED: float = 120
const SKID_SPEED: float = 160
const ACCELERATION: float = 34000

@onready var camera: Camera2D = $Camera2D
@onready var player_sync: PlayerSynchronizer = $PlayerSynchronizer

@export var direction: Vector2


func _ready() -> void:
	if name == str(multiplayer.get_unique_id()):
		Glob.player = self
		camera.make_current()
		set_physics_process(multiplayer.is_server())
	else:
		set_process_input(false)
		set_process_unhandled_input(false)
		set_process_unhandled_key_input(false)


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_limit_move_speed()

	if name == str(multiplayer.get_unique_id()):
		Glob.debug_panel.add_property('Velocity', str(linear_velocity), 2)


func _handle_movement(delta: float) -> void:
	direction = player_sync.input_direction
	if not direction.is_zero_approx():
		apply_central_force(direction * ACCELERATION)
	else:
		linear_velocity = linear_velocity.move_toward(Vector2.ZERO, SKID_SPEED * delta)


func _limit_move_speed() -> void:
	if linear_velocity.length_squared() > MAX_SPEED*MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED
