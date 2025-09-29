extends PanelContainer
class_name DebugPanel

@onready var property_container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	Glob.debug_panel = self
	visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_debug_toggle"):
		visible = !visible

func _process(delta: float) -> void:
	if not visible: return
	add_property("FPS", "%.2f" % (1.0/delta), 0)


## Adds or replaces given debug property.
func add_property(title: StringName, value: StringName, order: int = -1) -> void:
	var target: Label = property_container.find_child(title, true, false)
	if not target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title

	target.text = "%s: %s" % [target.name, value]
	if order > -1:
		property_container.move_child(target, mini(order, property_container.get_children().size()))
