extends Panel

var paused = false
var mouse_capture

var tex_checked:Texture = load("res://addons/gradient_shader/ui/icons/checked.svg")
var tex_unchecked:Texture = load("res://addons/gradient_shader/ui/icons/unchecked.svg")

func _input(event):
	if !paused && event.is_action_pressed("gm_pause"):
		pause()
	elif paused && event.is_action_pressed("gm_pause"):
		_on_resume()

func _ready():
	hide()
	set_fullscreen(OS.window_fullscreen)
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

func set_fullscreen(fullscreen):
	OS.set_window_fullscreen(fullscreen)
	if fullscreen:
		$buttons/Fullscreen/Icon.texture = tex_checked
	else:
		$buttons/Fullscreen/Icon.texture = tex_unchecked

func _on_fullscreen_pressed():
	set_fullscreen(!OS.window_fullscreen)
