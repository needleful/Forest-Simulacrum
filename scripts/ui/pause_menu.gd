extends Control

signal pause(paused)

var mouse_capture

var paused:bool = false setget set_pause

onready var G = get_node("/root/global")

func _input(event):
	if event.is_action_pressed("gm_pause"):
		G.using_controller = event is InputEventJoypadButton
		if G.using_controller:
			G.controller_name = Input.get_joy_name(event.device)
		self.paused = !paused
	elif $options.visible:
		var t = $options/vbox/tab
		var c = t.current_tab
		if event.is_action_pressed("ui_page_down"):
			if c+1 < t.get_tab_count():
				t.current_tab = c+1
				t.get_current_tab_control().get_focus()
		elif event.is_action_pressed("ui_page_up"):
			if c > 0:
				t.current_tab = c-1
				t.get_current_tab_control().get_focus()

func _ready():
	set_process_input(true)

func set_pause(p:bool):
	paused = p
	get_tree().paused = paused
	if paused:
		pause()
	else:
		hide()
		Input.set_mouse_mode(mouse_capture)
	emit_signal("pause", paused)

func pause():
	show()
	show_main_menu()
	mouse_capture = Input.get_mouse_mode()
	if !G.using_controller:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func show_options():
	$options.display()
	if G.using_controller:
		$options/vbox/tab.get_current_tab_control().get_focus()
	$main_menu.hide()

func show_main_menu():
	$options.hide()
	$main_menu.show()
	if G.using_controller:
		$main_menu/buttons/resume.grab_focus()

func _on_resume():
	self.paused = false

func _on_exit():
	get_tree().quit()
