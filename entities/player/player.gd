extends RigidBody2D
class_name Player

const MAX_SPEED: float = 120
const SKID_SPEED: float = 160
const ACCELERATION: float = 34000

@onready var camera: Camera2D = $Camera2D
@onready var input_sync: InputSynchronizer = $InputSynchronizer
@onready var mp_sync: MultiplayerSynchronizer = $MultiplayerSynchronizer

@export var direction: Vector2
## Represents the velocity of the player. BUT this not used by the physics engine. This is only the synced value from the server.
@export var cur_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	if name == str(multiplayer.get_unique_id()):
		Glob.player = self
		camera.make_current()
		set_physics_process(multiplayer.is_server())
	else:
		set_process_input(false)
		set_process_unhandled_input(false)
		set_process_unhandled_key_input(false)
		set_process(false)
		$UserInterface.queue_free()


func _process(_delta: float) -> void:
	Glob.debug_panel.add_property('Velocity', '(%s,%s)' % [roundi(cur_velocity.x), roundi(cur_velocity.y)], 2)


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_limit_move_speed()
	cur_velocity = linear_velocity


func _handle_movement(delta: float) -> void:
	direction = input_sync.input_direction
	if not direction.is_zero_approx():
		apply_central_force(direction * ACCELERATION)
	else:
		linear_velocity = linear_velocity.move_toward(Vector2.ZERO, SKID_SPEED * delta)


func _limit_move_speed() -> void:
	if linear_velocity.length_squared() > MAX_SPEED*MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED
