extends Resource
class_name TeamDetails

@export var teamId: int
@export var score: int = 0
@export var playerIds: Array[int] = []


func _init(_teamId: int, _score: int = 0, _playerIds: Array[int] = []) -> void:
	self.teamId = _teamId
	self.score = _score
	self.playerIds = _playerIds


static func find_team_by_id(teams: Array[TeamDetails], id: int) -> TeamDetails:
	return teams.get(teams.find_custom(func(t: TeamDetails) -> bool: return t.teamId == id))
