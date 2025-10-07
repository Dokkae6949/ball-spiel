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
	multiplayer.connection_failed.connect(_connection_not_resolved)
	multiplayer.connected_to_server.connect(_successful_connection)


func host(port: int) -> void:
	if _state != State.DISCONNECTED:
		print("Already running as %s, shutting down first" % [State.values()[_state]])
		quit()

	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(port)
	if error != Error.OK:
		_on_error("Failed to host on port %s. Code %d" % [port, error])
		return

	multiplayer.multiplayer_peer = peer
	hosted.emit(port)
	_successful_connection()


func join(ip: String, port: int) -> void:
	if Glob.lobby_manager.get_current_scene() is Menu:
		(Glob.lobby_manager.get_current_scene() as Menu).set_info_message("Trying to connect ...")

	if _state != State.DISCONNECTED:
		print("Already running as %s, shutting down first" % [_state])
		quit()

	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(ip, port)
	if error != Error.OK:
		_on_error("Failed to join host at %s:%s. Code %d" % [ip, port, error])
		return

	multiplayer.multiplayer_peer = peer
	joined.emit(port, ip)


func _connection_not_resolved() -> void:
	if _state != State.DISCONNECTED: return
	_on_error("Connection could not be resolved.")
	quit()


func _successful_connection() -> void:
	Glob.lobby_manager.change_scene(LobbyManager.SceneType.LOBBY)


func quit() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer = null
	peer = null
	_state = State.DISCONNECTED
	Glob.lobby_manager.change_scene(LobbyManager.SceneType.MENU)


func get_state() -> State:
	return _state


## Same as [method multiplayer.get_peers] but also returns the id of the current [param MultiplayerApi.multiplayer_peer]
func get_all_peers() -> Array[int]:
	var array: Array[int] = [multiplayer.get_unique_id()]
	array.append_array(multiplayer.get_peers())
	return array


func _on_peer_connected(id: int) -> void:
	_state = State.HOST if multiplayer.is_server() else State.CLIENT
	peer_connected.emit(id)

func _on_peer_disconnected(id: int) -> void:
	peer_disconnected.emit(id)

func _on_error(msg: StringName) -> void:
	if Glob.lobby_manager.get_current_scene() is Menu:
		(Glob.lobby_manager.get_current_scene() as Menu).set_error_message(msg)
	push_warning(msg)
