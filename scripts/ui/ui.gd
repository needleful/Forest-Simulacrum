extends Control

export(float, 0.0, 1.0) var fadeout_alpha = 0.0 setget set_fade

onready var fade = $ColorRect
onready var input = get_node("/root/input")

var dlg_was_visible = false

func _ready():
	set_process(false)
	var g = get_node("/root/global")
	g.ui = self
	$DialogViewer.resolver = g
	input.connect("use_controller", self, "_on_use_controller")
	_on_use_controller(input.using_controller)

func _process(delta):
	$input_viewer/analog/raw.rect_position = (
		Vector2(48,48) + input.analog_status_raw*60)
	$input_viewer/analog/processed.rect_position = (
		Vector2(48,48) + input.analog_status_processed*60)

func set_fade(val):
	fadeout_alpha = val
	if fade == null:
		return
	fade.color.a = val
	if val == 0:
		fade.visible = false
	else:
		fade.visible = true

func _on_pause(paused):
	if paused:
		dlg_was_visible = $DialogViewer.visible
		$DialogViewer.set_process_input(false)
		$DialogViewer.hide()
	else:
		$DialogViewer.visible = dlg_was_visible
		$DialogViewer.set_process_input(dlg_was_visible)

func _on_use_controller(use):
	$DialogViewer.controller_focus = use

func _on_GradientProperties_update():
	var f = get_focus_owner()
	hide()
	show()
	if f != null:
		f.grab_focus()
