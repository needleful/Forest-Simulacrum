tool
extends HBoxContainer

signal value_changed(value)

export(String) var label_text setget set_label
export(float) var max_value setget set_max
export(float) var min_value setget set_min

func _ready():
	self.label_text = label_text
	self.max_value = max_value
	self.min_value = min_value

func on_value_changed(value:float):
	emit_signal("value_changed", value)
	if $value:
		$value.text = "%.02f" % value

func set_label(value:String):
	label_text = value
	if $Label:
		$Label.text = label_text

func set_max(val:float):
	max_value = val
	if $slide:
		$slide.max_value = val

func set_min(val:float):
	min_value = val
	if $slide:
		$slide.min_value = val

func grab_focus():
	$slide.grab_focus()