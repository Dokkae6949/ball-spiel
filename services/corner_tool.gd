@tool
extends CollisionPolygon2D

@export_tool_button("Generate Corner") var generate_corner = corner_generater
@export var radius: int = 32
@export var steps: int = 16

func corner_generater() -> void:
	print("generating corner...")
	var new_polygon: PackedVector2Array = []
	for i: int in range(steps + 1):
		var theta: float = PI/2 * float(i) / steps
		var x: float = radius - radius * cos(theta)
		var y: float = radius - radius * sin(theta)
		new_polygon.append(Vector2(x, y))
	new_polygon.append(Vector2.ZERO)
	print(new_polygon)
	polygon = new_polygon
