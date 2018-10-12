extends Control

var paused = false
var mouse_capture

func set_pause(paused:bool):
	if paused:
		hide()
		pause()
	else:
		_on_resume()

func pause():
	paused = true
	show()
	mouse_capture = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func show_options():
	$options.display()
	$main_menu.hide()

func show_main_menu():
	$options.hide()
	$main_menu.show()

func _on_resume():
	paused = false
	hide()
	Input.set_mouse_mode(mouse_capture)
	get_tree().paused = paused

func _on_exit():
	get_tree().quit()
