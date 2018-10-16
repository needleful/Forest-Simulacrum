extends Control

export(float, 0.0, 1.0) var fadeout_alpha = 0.0 setget set_fade

onready var fade = $ColorRect
onready var input = get_node("/root/input")

func _ready():
	set_process(true)
	$pause.hide()
	get_node("/root/global").ui = self
	$DialogViewer.resolver = get_node("/root/global")
	get_node("/root/input").connect("use_controller", self, "on_use_controller")

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

func on_use_controller(use):
	$DialogViewer.controller_focus = use