extends RigidBody2D
class_name Ball

@onready var goal_detection: GoalDetection = $GoalDetection
@onready var mp_sync: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready() -> void:
	Glob.game_manager.game_end.connect(_on_game_end)

func _on_game_end() -> void:
	if is_multiplayer_authority():
		mp_sync.public_visibility = false
		mp_sync.set_multiplayer_authority(0)
