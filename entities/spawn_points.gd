extends Node2D
class_name SpawnPoints

var cur_index: int = 0

func get_next_spawn_point() -> Vector2:
	var point: Node2D = get_child(cur_index % get_child_count())
	cur_index += 1
	return point.global_position if point else Vector2.ZERO
