extends Node
class_name GameManager


signal teams_refreshed(teams: Array[TeamDetails])
@export var teams: Array[TeamDetails] = []


func start_game() -> void:
	get_parent().spawn_players()
	_create_teams()
	_add_players_to_random_teams()
	teams_refreshed.emit(teams)
	for team: TeamDetails in teams:
		sync_team.rpc(team.teamId, team.score, team.playerIds)


func add_score(teamId: int, value: int) -> void:
	var team_index: int = teams.find_custom(func(t: TeamDetails): return t.teamId == teamId)
	if team_index < 0:
		var teams_str: String = ""
		for team: TeamDetails in teams:
			teams_str += "%d " % team.teamId
		push_warning("Team with Id '%s' was not found in: %s" % [teamId, teams_str])
		return

	var team: TeamDetails = teams[team_index]
	team.score += value
	sync_team(team.teamId, team.score, team.playerIds)


## [param amount] of teams to create
func _create_teams(amount: int = 2) -> void:
	for i: int in range(amount):
		teams.append(TeamDetails.new(i))


## Adds all players in [method LobbyManager.get_spawned_players] to random teams
func _add_players_to_random_teams() -> void:
	var players_to_assign: Array[Player] = Glob.lobby_manager.get_spawned_players()
	while not players_to_assign.is_empty():
		for i: int in range(teams.size()):
			if players_to_assign.is_empty(): return
			var player: Player = players_to_assign.pick_random()
			players_to_assign = players_to_assign.filter(func(p: Player): return p.name != player.name)
			teams[i].playerIds.append(int(player.name))


@rpc("reliable")
func sync_team(teamId: int, score: int, playerIds: Array[int]) -> void:
	var new_team: TeamDetails = TeamDetails.new(teamId, score, playerIds)
	teams = teams.filter(func(t: TeamDetails): return t.teamId != teamId)
	teams.append(new_team)
	teams_refreshed.emit(teams)
