extends Button

signal value_changed(value)
export(String) var label_text = "Toggle" setget set_label_text

var tex_checked:Texture = load("res://addons/gradient_shader/ui/icons/checked.svg")
var tex_unchecked:Texture = load("res://addons/gradient_shader/ui/icons/unchecked.svg")

var value:bool = false setget set_value

func toggle():
	self.value = !value
	emit_signal("value_changed", value)

func set_value(val):
	value = val
	if value:
		$Icon.texture = tex_checked
	else:
		$Icon.texture = tex_unchecked

func set_label_text(val):
	text = val
