extends StaticBody2D
class_name Goal


@onready var goal_area: Area2D = $GoalArea


func _on_goal_area_area_entered(area: Area2D) -> void:
	if area is not GoalDetection: return
	print("GOALLL")
