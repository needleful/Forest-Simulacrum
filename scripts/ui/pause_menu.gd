extends Control

signal pause(paused)

var mouse_capture

var paused:bool = false setget set_pause

onready var G = get_node("/root/global")

func _ready():
	var input = $"/root/input"
	input.connect("pause", self, "set_pause")

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
	if !G.inp.using_controller:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func show_options():
	$options.display()
	if G.inp.using_controller:
		$options/vbox/tab.get_current_tab_control().get_focus()
	$main_menu.hide()

func show_main_menu():
	$options.hide()
	$main_menu.show()
	if G.inp.using_controller:
		$main_menu/buttons/resume.grab_focus()

func _on_resume():
	self.paused = false

func _on_exit():
	get_tree().quit()
