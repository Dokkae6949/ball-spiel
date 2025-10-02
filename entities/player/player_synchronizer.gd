extends MultiplayerSynchronizer
class_name PlayerSynchronizer

@export var input_direction: Vector2


func _physics_process(_delta: float) -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
