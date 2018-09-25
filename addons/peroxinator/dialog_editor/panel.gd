tool
extends PanelContainer

var drag_position: Vector2 = Vector2(0,0)

func ready():
	hint_tooltip = "Dialog Panel"

func _on_gui_input(ev):
	if ev is InputEventMouseButton:
		if ev.pressed:
			drag_position = get_global_mouse_position() - rect_global_position
		else:
			drag_position = Vector2(0,0)
	elif ev is InputEventMouseMotion and drag_position.x*drag_position.y != 0:
		rect_global_position = get_global_mouse_position() - drag_position
