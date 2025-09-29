extends Node


enum State { DISCONNECTED, HOST, CLIENT }


signal hosted(port: int)
signal joined(ip: String, port: int)
signal peer_connected(id: int)
signal peer_disconnected(id: int)


var peer: ENetMultiplayerPeer
var _state: State = State.DISCONNECTED


func host(port: int) -> void:
	if _state != State.DISCONNECTED:
		push_warning("Already running as %s, shutting down first" % [State.values()[_state]])
		quit()
	
	peer = ENetMultiplayerPeer.new()
	
	if peer.create_server(port) != OK:
		push_warning("Failed to host on port %s" % [port])
		return
	
	multiplayer.multiplayer_peer = peer
	hosted.emit(port)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func join(ip: String, port: int) -> void:
	if _state != State.DISCONNECTED:
		push_warning("Already running as %s, shutting down first" % [_state])
		quit()
	
	peer = ENetMultiplayerPeer.new()
	
	if peer.create_client(ip, port) != OK:
		push_warning("Failed to join host at %s:%s" % [ip, port])
		return
	
	multiplayer.multiplayer_peer = peer
	joined.emit(ip, port)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func quit() -> void:
	if multiplayer.peer:
		multiplayer.peer = null
	peer = null
	_state = State.DISCONNECTED

func get_state() -> State:
	return _state


func _on_peer_connected(id: int) -> void:
	peer_connected.emit(id)

func _on_peer_disconnected(id: int) -> void:
	peer_disconnected.emit(id)
