extends CanvasLayer

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var lobby_name: RichTextLabel = $CenterContainer/VBoxContainer/LobbyName
@onready var first_team_list: TeamList = $CenterContainer/VBoxContainer/Teams/FirstTeamList
@onready var spectator_list: TeamList = $CenterContainer/VBoxContainer/Teams/SpectatorList
@onready var second_team_list: TeamList = $CenterContainer/VBoxContainer/Teams/SecondTeamList


func _ready() -> void:
	start_button.disabled = not multiplayer.is_server()
	first_team_list.teamId = Glob.game_manager.first_team.teamId
	second_team_list.teamId = Glob.game_manager.second_team.teamId
	refresh_ip()


func refresh_ip() -> void:
	var ip_address: StringName = IP.resolve_hostname(OS.get_environment("HOSTNAME"), IP.TYPE_IPV4)
	if not ip_address:
		ip_address = "127.0.0.1"
	lobby_name.text = "IP: %s:%s" % [ip_address, 9912]


func _on_start_button_pressed() -> void:
	Glob.lobby_manager.change_scene.rpc(Glob.lobby_manager.SceneType.ARENA)

func _on_leave_button_pressed() -> void:
	NetworkService.quit()
