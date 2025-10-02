extends CanvasLayer

@onready var playerlist: VBoxContainer = $CenterContainer/VBoxContainer/Playerlist
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton


func _ready() -> void:
	NetworkService.peer_connected.connect(_on_peers_changed)
	NetworkService.peer_disconnected.connect(_on_peers_changed)
	start_button.disabled = not multiplayer.is_server()


func _on_peers_changed(_id: int) -> void:
	for child: Node in playerlist.get_children():
		child.queue_free()

	for peer: int in multiplayer.get_peers():
		var new_label: Label = Label.new()
		new_label.text = str(peer)
		playerlist.add_child(new_label)


func _on_button_pressed() -> void:
	Glob.lobby_manager.change_scene.rpc(Glob.lobby_manager.SceneType.ARENA)
