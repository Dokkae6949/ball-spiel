extends Node


var player: Player
var debug_panel: DebugPanel
var lobby_manager: LobbyManager:
	set(value):
		lobby_manager = value
		game_manager = value.game_manager
var game_manager: GameManager
