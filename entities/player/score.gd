extends PanelContainer
class_name LiveScore

@onready var score_team_0: RichTextLabel = $MarginContainer/HBoxContainer/ScoreTeam0
@onready var score_team_1: RichTextLabel = $MarginContainer/HBoxContainer/ScoreTeam1
@onready var play_time: RichTextLabel = $MarginContainer/HBoxContainer/PlayTime


func _ready() -> void:
	Glob.game_manager.teams_refreshed.connect(_on_teams_refreshed)


func _on_teams_refreshed(teams: Array[TeamDetails]) -> void:
	if teams.size() < 2: return
	score_team_0.text = str(teams[0].score)
	score_team_1.text = str(teams[1].score)
