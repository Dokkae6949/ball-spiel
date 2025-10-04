extends PanelContainer
class_name LiveScore

@onready var score_team_0: RichTextLabel = $MarginContainer/HBoxContainer/ScoreTeam0
@onready var score_team_1: RichTextLabel = $MarginContainer/HBoxContainer/ScoreTeam1
@onready var play_time: RichTextLabel = $MarginContainer/HBoxContainer/PlayTime


func _ready() -> void:
	Glob.game_manager.teams_refreshed.connect(_on_teams_refreshed)


func _on_teams_refreshed(teams: Array[TeamDetails]) -> void:
	if teams.size() < 2: return
	var team0: TeamDetails = TeamDetails.find_team_by_id(teams, 0)
	var team1: TeamDetails = TeamDetails.find_team_by_id(teams, 1)
	score_team_0.text = str(team0.score)
	score_team_1.text = str(team1.score)
