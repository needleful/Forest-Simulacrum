extends Control

export(float, 0.0, 1.0) var fadeout_alpha = 0.0 setget set_fade

onready var fade = $ColorRect

func _ready():
	get_node("/root/global").ui = self
	get_node("/root/global").inp = $input_handler
	$DialogViewer.resolver = get_node("/root/global")

func set_fade(val):
	fadeout_alpha = val
	if fade == null:
		return
	fade.color.a = val
	if val == 0:
		fade.visible = false
	else:
		fade.visible = true