class_name Menu
extends Control


@onready var join_server_button: Button = %JoinServer
@onready var host_server_button: Button = %HostServer
@onready var host_address_input: LineEdit = %HostAddress


func _ready() -> void:
	join_server_button.pressed.connect(_join_pressed)
	host_server_button.pressed.connect(_host_pressed)


func _join_pressed() -> void:
	var address_parts := host_address_input.text.split(":")
	
	if address_parts.size() != 2:
		push_warning("Host address must be of format <ip>:<port>")
		return
	
	var ip := address_parts[0]
	var port := address_parts[1]
	
	print("[Menu] Trying to connect to %s:%s" % [ip, port])

func _host_pressed() -> void:
	print("[Menu] Trying to host")
