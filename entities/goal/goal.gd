extends StaticBody2D
class_name Goal


@onready var goal_area: Area2D = $GoalArea
@onready var floor_mesh: MeshInstance2D = $FloorMesh

@export var teamId: int


func _ready() -> void:
	_refresh_team_attributes()


func _refresh_team_attributes() -> void:
	floor_mesh.modulate = TeamDetails.find_team_by_id(Glob.game_manager.get_all_teams(), teamId).color.darkened(0.5)


func _on_goal_area_area_entered(area: Area2D) -> void:
	if not multiplayer.is_server(): return
	if area is not GoalDetection: return
	Glob.game_manager.add_score(teamId, 1)
