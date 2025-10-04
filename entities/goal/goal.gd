extends StaticBody2D
class_name Goal


@onready var goal_area: Area2D = $GoalArea

@export var teamId: int


func _on_goal_area_area_entered(area: Area2D) -> void:
	if not multiplayer.is_server(): return
	if area is not GoalDetection: return
	Glob.game_manager.add_score(teamId, 1)
