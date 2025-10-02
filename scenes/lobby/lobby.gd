extends CanvasLayer

@onready var playerlist: VBoxContainer = $CenterContainer/VBoxContainer/Playerlist
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var lobby_name: RichTextLabel = $CenterContainer/VBoxContainer/LobbyName


func _ready() -> void:
	NetworkService.peer_connected.connect(refresh)
	NetworkService.peer_disconnected.connect(refresh)
	start_button.disabled = not multiplayer.is_server()
	refresh(multiplayer.get_unique_id())


func refresh(_id: int) -> void:
	var ip_address: StringName = IP.resolve_hostname(OS.get_environment("HOSTNAME"), IP.TYPE_IPV4)
	if not ip_address:
		ip_address = "127.0.0.1"
	#lobby_name.text = "IP: %s:%s" % [ip_address, multiplayer.]

	for child: Node in playerlist.get_children():
		child.queue_free()

	for peer: int in PackedInt32Array([multiplayer.get_unique_id()]) + multiplayer.get_peers():
		var new_label: Label = Label.new()
		new_label.text = str(peer)
		playerlist.add_child(new_label)


func _on_button_pressed() -> void:
	Glob.lobby_manager.change_scene.rpc(Glob.lobby_manager.SceneType.ARENA)
