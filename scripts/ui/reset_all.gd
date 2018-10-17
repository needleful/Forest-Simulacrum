extends Popup

var last_focused:Control
signal reset

func _input(event):
	if event.is_action_pressed("ui_back"):
		exit()
		get_tree().set_input_as_handled()

func _ready():
	connect("confirmed", self, "reset_all")

func get_confirmation():
	last_focused = get_focus_owner()
	set_process_input(true)
	popup_centered()
	$m/vbox/buttons/no.grab_focus()

func exit():
	set_process_input(false)
	if last_focused != null:
		last_focused.grab_focus()
	hide()

func reset_all():
	var g = get_node("/root/global")
	g.set_options(g.load_options("res://default.var"))
	emit_signal("reset")
	exit()