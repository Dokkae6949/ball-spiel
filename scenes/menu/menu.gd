class_name Menu
extends CanvasLayer


@onready var join_server_button: Button = %JoinServer
@onready var host_server_button: Button = %HostServer
@onready var host_address_input: LineEdit = %HostAddress
@onready var error_message: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/ErrorMessage


func _ready() -> void:
	error_message.visible = false
	join_server_button.pressed.connect(_join_pressed)
	host_server_button.pressed.connect(_host_pressed)
	
	NetworkService.hosted.connect(_on_hosted)
	NetworkService.joined.connect(_on_joined)

	if OS.has_feature('host_server'):
		_host_pressed.call_deferred()
	elif OS.has_feature('join_server'):
		host_address_input.text = '127.0.0.1:9912'
		_join_pressed.call_deferred()


func _join_pressed() -> void:
	var address_parts: PackedStringArray = host_address_input.text.split(":")
	
	if address_parts.size() != 2:
		set_error_message("Host address must be of format <ip>:<port>")
		push_warning("Host address must be of format <ip>:<port>")
		return
	if !address_parts[1].is_valid_int():
		set_error_message("Host port must be a valid number")
		push_warning("Host port must be a valid number")
		return
	
	var ip: StringName = address_parts[0]
	var port: int = address_parts[1].to_int()
	
	print("[Menu] Trying to connect to %s:%s" % [ip, port])
	
	NetworkService.join(ip, port)

func _host_pressed() -> void:
	print("[Menu] Trying to host")
	
	NetworkService.host(9912)


func _on_hosted(port: int) -> void:
	print("[Menu] Hosting server (Port %s). Trying to open lobby." % port)

func _on_joined(port: int, ip: String)-> void:
	print("[Menu] Joined server (%s:%s). Trying to open lobby." % [ip, port])


func set_error_message(txt: String) -> void:
	error_message.add_theme_color_override("default_color", Color("ff554a"))
	error_message.text = txt
	error_message.visible = not txt.is_empty()


func set_info_message(txt: String) -> void:
	error_message.add_theme_color_override("default_color", Color.WHITE)
	error_message.text = txt
	error_message.visible = not txt.is_empty()
