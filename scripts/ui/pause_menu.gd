extends Panel

var paused = false
var mouse_capture

func _input(event):
	if !paused && event.is_action_pressed("gm_pause"):
		pause()
	elif paused && event.is_action_pressed("gm_pause"):
		_on_resume()

func _ready():
	hide()
	$buttons/Fullscreen.pressed = OS.window_fullscreen
	set_process_input(true)

func pause():
	paused = true
	show()
	mouse_capture = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = paused

func _on_resume():
	paused = false
	hide()
	Input.set_mouse_mode(mouse_capture)
	get_tree().paused = paused

func _on_exit():
	get_tree().quit()

func _on_fullscreen_toggled(fullscreen):
	OS.set_window_fullscreen(fullscreen)
