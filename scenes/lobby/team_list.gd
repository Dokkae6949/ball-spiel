extends VBoxContainer
class_name TeamList

@onready var title: RichTextLabel = $Title
@onready var player_list: VBoxContainer = $ScrollContainer/PlayerList
@onready var switch_to_button: Button = $SwitchToButton

## The corresponding Team associated with this TeamList. If it is null, it is the spectators list.
var teamId: int


func _ready() -> void:
	Glob.game_manager.teams_refreshed.connect(refresh)


func refresh(_teams: Array[TeamDetails]) -> void:
	var peers: Array[int] = []
	if teamId:
		peers = Glob.game_manager.get_playerIds_of_team(teamId)
	else:
		peers = Glob.game_manager.get_playerIds_without_team()

	title.text = "Spectators" if is_spectator_team() else "Team %d" % teamId
	for child: Node in player_list.get_children():
		child.queue_free()

	switch_to_button.disabled = false
	for id: int in peers:
		if id == multiplayer.get_unique_id(): switch_to_button.disabled = true
		var label: Label = Label.new()
		label.text = str(id)
		player_list.add_child(label)


func _on_switch_to_button_pressed() -> void:
	Glob.game_manager.assign_player_to_team(multiplayer.get_unique_id(), teamId)


func is_spectator_team() -> bool:
	return not teamId
