extends Node
class_name GameManager


signal teams_refreshed(teams: Array[TeamDetails])

const SCORE_TO_WIN: int = 1

@onready var post_match_timer: Timer = $PostMatchTimer
@onready var post_match_interface: CanvasLayer = $PostMatchInterface
@onready var post_match_title: RichTextLabel = $PostMatchInterface/PanelContainer/CenterContainer/VBoxContainer/Title
@onready var post_match_score: RichTextLabel = $PostMatchInterface/PanelContainer/CenterContainer/VBoxContainer/Score

@export var teams: Array[TeamDetails] = []


func _ready() -> void:
	post_match_interface.visible = false


func start_game() -> void:
	get_parent().spawn_players()
	if teams.is_empty():
		_create_teams()
		
	_add_players_to_random_teams()
	teams_refreshed.emit(teams)
	for team: TeamDetails in teams:
		sync_team.rpc(team.teamId, team.score, team.playerIds)


@rpc("call_local", "reliable")
func end_game() -> void:
	var player_team: TeamDetails = null
	var winner_team: TeamDetails = null
	for team: TeamDetails in teams:
		if not player_team and team.playerIds.has(int(Glob.player.name)):
			player_team = team
		if not winner_team or winner_team.score < team.score:
			winner_team = team

	post_match_title.text = "[b]WINNER" if player_team.teamId == winner_team.teamId else "[b]LOSER"
	post_match_score.text = "[i]%d  -  %d" % [TeamDetails.find_team_by_id(teams, 0).score, TeamDetails.find_team_by_id(teams, 1).score]
	post_match_timer.start()
	post_match_interface.visible = true


func add_score(teamId: int, value: int) -> void:
	var team: TeamDetails = TeamDetails.find_team_by_id(teams, teamId)
	team.score += value
	teams_refreshed.emit(teams)
	sync_team.rpc(team.teamId, team.score, team.playerIds)
	if team.score >= SCORE_TO_WIN:
		end_game.rpc()


## [param amount] of teams to create
func _create_teams(amount: int = 2) -> void:
	for i: int in range(amount):
		teams.append(TeamDetails.new(i))


func _reset_teams() -> void:
	for team: TeamDetails in teams:
		team.score = 0
		sync_team(team.teamId, 0, team.playerIds)


## Adds all players in [method LobbyManager.get_spawned_players] to random teams
func _add_players_to_random_teams() -> void:
	var players_to_assign: Array[Player] = Glob.lobby_manager.get_spawned_players()
	while not players_to_assign.is_empty():
		for i: int in range(teams.size()):
			if players_to_assign.is_empty(): return
			var player: Player = players_to_assign.pick_random()
			players_to_assign = players_to_assign.filter(func(p: Player) -> bool: return p.name != player.name)
			teams[i].playerIds.append(int(player.name))


@rpc("reliable")
func sync_team(teamId: int, score: int, playerIds: Array[int]) -> void:
	var new_team: TeamDetails = TeamDetails.new(teamId, score, playerIds)
	teams = teams.filter(func(t: TeamDetails) -> bool: return t.teamId != teamId)
	teams.append(new_team)
	teams_refreshed.emit(teams)


@rpc
func _back_to_lobby() -> void:
	if multiplayer.is_server():
		_back_to_lobby.rpc()
	post_match_interface.visible = false
	Glob.lobby_manager.change_scene(LobbyManager.SceneType.LOBBY)
