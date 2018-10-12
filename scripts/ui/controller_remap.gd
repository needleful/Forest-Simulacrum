extends Popup

signal new_action(event)

func _ready():
	set_process_input(false)

func _input(event):
	if event is InputEventMouseMotion or !event.is_pressed():
		pass
	else:
		if !event.is_action_pressed("ui_cancel"):
			emit_signal("new_action", event)
		set_process_input(false)
		hide()
	get_tree().set_input_as_handled()

func request_input():
	set_process_input(true)
	popup_centered()