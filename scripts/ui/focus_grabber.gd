extends Control

export(NodePath) var focused_control

func get_focus():
	var c = get_node(focused_control)
	if c and c is Control:
		c.grab_focus()