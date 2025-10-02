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

const PLAYER_SCENE = preload("uid://dloq01g4o4rqr")

@onready var players: Node = $Players
@onready var current_scene: Node = $CurrentScene

var current_scene_type: SceneType


func _ready() -> void:
	Glob.lobby_manager = self
	NetworkService.hosted.connect(_on_connect)
	NetworkService.joined.connect(_on_connect)
	change_scene(SceneType.MENU)


func _on_peer_disconnected(id: int) -> void:
	if not multiplayer.is_server(): return
	for player: Player in players.get_children():
		if player.name == str(id):
			player.queue_free()
			return


func _on_connect(_x: Variant, _y: Variant = null) -> void:
	change_scene(SceneType.LOBBY)


@rpc("authority", "call_local", "reliable")
func change_scene(type: SceneType) -> void:
	scene_change.emit()
	if current_scene.get_child_count() > 0:
		current_scene.get_child(0).queue_free()

	var packed_scene: PackedScene = SceneDict.get(type)
	if not packed_scene:
		push_warning("Invalid SceneType given for SceneDict! %s" % type)
		return

	var new_scene: Node = packed_scene.instantiate()
	current_scene.add_child(new_scene)
	current_scene_type = type

	if type == SceneType.ARENA:
		spawn_players()


func spawn_players() -> void:
	if not multiplayer.is_server(): return
	var peers: Array[int] = [1]
	peers.append_array(multiplayer.get_peers())
	for peer: int in peers:
		var new_player: Player = PLAYER_SCENE.instantiate()
		new_player.name = str(peer)
		players.add_child(new_player)
		_on_multiplayer_spawner_spawned(new_player)


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is Player:
		node.player_sync.set_multiplayer_authority(int(node.name))
