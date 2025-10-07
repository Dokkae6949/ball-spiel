extends Node
class_name LobbyManager


signal scene_change(type: SceneType)

enum SceneType {
	ARENA,
	LOBBY,
	MENU
}

const SceneDict: Dictionary[SceneType, PackedScene] = {
	SceneType.ARENA: preload("uid://cflj1w58yi31p"),
	SceneType.LOBBY: preload("uid://bdvb0s1uft6ix"),
	SceneType.MENU: preload("uid://bbw6acpaxs688")
}

const PLAYER_SCENE: PackedScene = preload("uid://dloq01g4o4rqr")

@onready var players_node: Node2D = $Players
@onready var current_scene: Node = $CurrentScene
@onready var game_manager: GameManager = $GameManager
@onready var mp_spawner: MultiplayerSpawner = $MultiplayerSpawner

var current_scene_type: SceneType


func _ready() -> void:
	Glob.lobby_manager = self
	change_scene(SceneType.MENU)
	NetworkService.peer_disconnected.connect(_on_peer_disconnected)


func _on_peer_disconnected(id: int) -> void:
	if not multiplayer.is_server(): return
	for player: Player in players_node.get_children():
		if player.name == str(id):
			player.queue_free()
			return


@rpc("authority", "call_local", "reliable")
func change_scene(type: SceneType) -> void:
	if current_scene_type == type:
		print("Scene Type not changed. Skipping change.")
		return
	for child: Node in current_scene.get_children():
		child.queue_free()

	for player: Player in players_node.get_children():
		if player.input_sync.is_multiplayer_authority():
			player.input_sync.public_visibility = false
			player.input_sync.set_multiplayer_authority(0)
		if player.mp_sync.is_multiplayer_authority():
			player.mp_sync.public_visibility = false
			player.mp_sync.set_multiplayer_authority(0)
		if multiplayer.is_server():
			player.queue_free()

	var packed_scene: PackedScene = SceneDict.get(type)
	if not packed_scene:
		push_warning("Invalid SceneType given for SceneDict! %s" % type)
		return

	scene_change.emit()
	var new_scene: Node = packed_scene.instantiate()
	current_scene.add_child(new_scene, true)
	current_scene_type = type

	if not multiplayer.has_multiplayer_peer(): return
	if not multiplayer.is_server(): return
	if current_scene_type == SceneType.ARENA:
		game_manager.start_game()


func spawn_players() -> void:
	if not multiplayer.is_server(): return
	for team: TeamDetails in Glob.game_manager.get_all_teams():
		for peer: int in team.playerIds:
			var new_player: Player = PLAYER_SCENE.instantiate()
			new_player.name = str(peer)
			players_node.add_child(new_player)
			_on_multiplayer_spawner_spawned(new_player)


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is Player:
		node.input_sync.set_multiplayer_authority(int(node.name))
		node.refresh_players_team()


func get_spawned_players() -> Array[Player]:
	var array: Array[Player] = []
	for node: Node in players_node.get_children():
		if node is Player:
			array.append(node)
	return array


func get_player_by_id(id: int) -> Player:
	var players: Array[Player] = get_spawned_players()
	return players.get(players.find_custom(func(p: Player) -> bool: return int(p.name) == id))


func get_current_scene() -> Node:
	return current_scene.get_child(0) if current_scene.get_child_count() > 0 else null
