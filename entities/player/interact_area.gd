extends Area2D
class_name InteractArea


const KICK_FORCE: float = 30000
@export var player: Player


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_interact"):
		_on_interact.rpc_id(1)


@rpc("any_peer", "call_local")
func _on_interact() -> void:
	var ball: Ball
	for body: Node2D in get_overlapping_bodies():
		if body is Ball:
			ball = body
			break

	if not ball: return
	ball.apply_central_impulse(player.global_position.direction_to(ball.global_position) * KICK_FORCE)
