extends Resource
class_name TeamDetails

@export var teamId: int
@export var score: int = 0
@export var playerIds: Array[int] = []


func _init(_teamId: int, _playerIds: Array[int] = []) -> void:
	self.teamId = _teamId
	self.playerIds = _playerIds
