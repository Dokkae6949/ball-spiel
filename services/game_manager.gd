extends Node
class_name GameManager


@export var teams: Array[TeamDetails] = []


func _ready() -> void:
	if not multiplayer.is_server(): return
	Glob.lobby_manager.spawn_players()
	_create_teams()
	_add_players_to_random_teams()
	for team: TeamDetails in teams:
		sync_team.rpc(team.teamId, team.score, team.playerIds)


func add_score(teamId: int, value: int) -> void:
	var found_team: TeamDetails
	for team: TeamDetails in teams:
		if team.teamId == teamId:
			found_team = team
			break

	if not found_team:
		push_warning("Team with Id '%s' was not found in: %s" % [teamId, teams])
		return

	found_team.score += value
	print("Check if score of teamId '%d' is %d now)" % [teamId, found_team.score])
	print("New Teams: %s" % teams)


## [param amount] of teams to create
func _create_teams(amount: int = 2) -> void:
	for i: int in range(amount):
		teams.append(TeamDetails.new(i))


## Adds all players in [method LobbyManager.get_spawned_players] to random teams
func _add_players_to_random_teams() -> void:
	var players_to_assign: Array[Player] = Glob.lobby_manager.get_spawned_players()
	print(players_to_assign)
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
