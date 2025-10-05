extends Node


enum State { DISCONNECTED, HOST, CLIENT }


signal hosted(port: int)
signal joined(port: int, ip: String)
signal peer_connected(id: int)
signal peer_disconnected(id: int)

const CONNECTION_TIMEOUT: float = 3

var peer: ENetMultiplayerPeer
var _state: State = State.DISCONNECTED


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func host(port: int) -> void:
	if _state != State.DISCONNECTED:
		push_warning("Already running as %s, shutting down first" % [State.values()[_state]])
		quit()

	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(port)
	if error != Error.OK:
		push_warning("Failed to host on port %s. Code %d" % [port, error])
		return

	multiplayer.multiplayer_peer = peer
	hosted.emit(port)


func join(ip: String, port: int) -> void:
	if Glob.lobby_manager.get_current_scene() is Menu:
		(Glob.lobby_manager.get_current_scene() as Menu).set_info_message("Trying to connect ...")

	if _state != State.DISCONNECTED:
		push_warning("Already running as %s, shutting down first" % [_state])
		quit()

	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(ip, port)
	if error != Error.OK:
		push_warning("Failed to join host at %s:%s. Code %d" % [ip, port, error])
		return

	multiplayer.multiplayer_peer = peer
	joined.emit(port, ip)
	get_tree().create_timer(CONNECTION_TIMEOUT).timeout.connect(_connection_not_resolved)


func _connection_not_resolved() -> void:
	if _state != State.DISCONNECTED: return
	push_warning("Connection could not be resolved. Disconnecting...")
	if Glob.lobby_manager.get_current_scene() is Menu:
		(Glob.lobby_manager.get_current_scene() as Menu).set_error_message("Connection could not be resolved.")
	quit()


func quit() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer = null
	peer = null
	_state = State.DISCONNECTED
	Glob.lobby_manager.change_scene(LobbyManager.SceneType.MENU)
	get_window().title = ProjectSettings.get_setting("application/config/name")


func get_state() -> State:
	return _state


func _on_peer_connected(id: int) -> void:
	_state = State.HOST if multiplayer.is_server() else State.CLIENT
	peer_connected.emit(id)

func _on_peer_disconnected(id: int) -> void:
	peer_disconnected.emit(id)
