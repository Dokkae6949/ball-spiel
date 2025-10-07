extends Node
class_name GameManager


signal teams_refreshed(teams: Array[TeamDetails])
signal game_end

const SCORE_TO_WIN: int = 1

@onready var post_match_timer: Timer = $PostMatchTimer
@onready var post_match_interface: CanvasLayer = $PostMatchInterface
@onready var post_match_title: RichTextLabel = $PostMatchInterface/PanelContainer/CenterContainer/VBoxContainer/Title
@onready var post_match_score: RichTextLabel = $PostMatchInterface/PanelContainer/CenterContainer/VBoxContainer/Score

@export var spawn_points: Array[SpawnPoints] = []

var first_team: TeamDetails = TeamDetails.new(1, Color.ROYAL_BLUE)
var second_team: TeamDetails = TeamDetails.new(2, Color.INDIAN_RED)


func _ready() -> void:
	post_match_interface.visible = false
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peers_changed)
		multiplayer.peer_disconnected.connect(_on_peers_changed)
		sync_all_teams()


func start_game() -> void:
	get_parent().spawn_players()
	if spawn_points.is_empty():
		_set_spawn_points()

	teams_refreshed.emit(get_all_teams())
	sync_all_teams()
	_move_players_to_spawn_points()


@rpc
func end_game() -> void:
	if multiplayer.is_server():
		end_game.rpc()

	var player_team: TeamDetails = first_team if first_team.playerIds.has(int(Glob.player.name)) else second_team
	var winner_team: TeamDetails = first_team if first_team.score > second_team.score else second_team

	post_match_title.text = "[b]WINNER" if player_team.teamId == winner_team.teamId else "[b]LOSER"
	post_match_score.text = "[i]%d  -  %d" % [first_team.score, second_team.score]
	post_match_timer.start()
	post_match_interface.visible = true
	spawn_points.clear()
	game_end.emit()


func add_score(teamId: int, value: int) -> void:
	var team: TeamDetails = first_team if first_team.teamId == teamId else second_team
	team.score += value
	teams_refreshed.emit(get_all_teams())
	_sync_team.rpc(team.teamId, team.color, team.score, team.playerIds)
	if team.score >= SCORE_TO_WIN:
		end_game()


func _reset_teams() -> void:
	for team: TeamDetails in get_all_teams():
		team.score = 0
	sync_all_teams()


func sync_all_teams() -> void:
	for team: TeamDetails in get_all_teams():
		_sync_team.rpc(team.teamId, team.color, team.score, team.playerIds)
	teams_refreshed.emit(get_all_teams())


@rpc("reliable")
func _sync_team(teamId: int, color: Color, score: int, playerIds: Array[int]) -> void:
	if first_team.teamId == teamId:
		first_team = TeamDetails.new(teamId, color, score, playerIds)
	elif second_team.teamId == teamId:
		second_team = TeamDetails.new(teamId, color, score, playerIds)
	else:
		push_warning("Team ID '%d' is not valid!" % teamId)
	teams_refreshed.emit(get_all_teams())


@rpc
func _back_to_lobby() -> void:
	if multiplayer.is_server():
		_back_to_lobby.rpc()
		_reset_teams()
	post_match_interface.visible = false
	post_match_timer.stop()
	Glob.lobby_manager.change_scene(LobbyManager.SceneType.LOBBY)


func _set_spawn_points() -> void:
	spawn_points.clear()
	for node: Node in get_tree().get_nodes_in_group("SpawnPoints"):
		if node is SpawnPoints:
			spawn_points.append(node)


func _move_players_to_spawn_points() -> void:
	var players: Array[Player] = Glob.lobby_manager.get_spawned_players()
	for player: Player in players:
		if first_team.playerIds.has(int(player.name)):
			player.position = spawn_points.get(0).get_next_spawn_point()
		else:
			player.position = spawn_points.get(1).get_next_spawn_point()


@rpc("any_peer")
func assign_player_to_team(playerId: int, teamId: int) -> void:
	if not multiplayer.is_server():
		assign_player_to_team.rpc_id(1, playerId, teamId)
		return

	for team: TeamDetails in get_all_teams():
		team.playerIds = team.playerIds.filter(func(id: int) -> bool: return id != playerId)
		if team.teamId == teamId:
			team.playerIds.append(playerId)
	sync_all_teams()


func get_all_teams() -> Array[TeamDetails]:
	return [first_team, second_team]


func get_playerIds_of_team(teamId: int) -> Array[int]:
	for team: TeamDetails in get_all_teams():
		if team.teamId == teamId:
			return team.playerIds
	push_error("Team ID '%d' not found!" % teamId)
	return []


func get_playerIds_without_team() -> Array[int]:
	var peers: Array[int] = NetworkService.get_all_peers()
	for team: TeamDetails in get_all_teams():
		peers = peers.filter(func(id: int) -> bool: return id not in team.playerIds)
	return peers


func _on_peers_changed(_id: int) -> void:
	if not multiplayer.is_server():
		# The signal should only be connect for the server. But it's still called on non-hosts.
		push_warning("called on non-host")
		return
	# Filter all players out which are not connected anymore
	for team: TeamDetails in get_all_teams():
		team.playerIds = team.playerIds.filter(func(id: int) -> bool: return id not in NetworkService.get_all_peers())

	# Add all unassigned players to spectator team
	for id: int in NetworkService.get_all_peers():
		var not_found: int = 0
		for team: TeamDetails in get_all_teams():
			if id not in team.playerIds:
				not_found += 1

		if not_found >= get_all_teams().size():
			assign_player_to_team(id, 0)
