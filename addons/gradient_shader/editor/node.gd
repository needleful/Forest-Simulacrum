tool
extends Node

export var color_light = Color(1,1,1) setget set_light
export var color_dark = Color(0,0,0) setget set_dark

export(float) var scale = 1 setget set_scale
export(float) var top = 1 setget set_top

var material : ShaderMaterial = load("res://addons/gradient_shader/gradient.tres")
var material2d : ShaderMaterial = load("res://addons/gradient_shader/gradient2d.tres")

#ui Styles
var ui_theme : Theme = load("res://addons/gradient_shader/ui_theme.theme")
var box_norm : StyleBoxFlat = load("res://addons/gradient_shader/ui/box_flat_normal.tres")
var box_highlight : StyleBoxFlat = load("res://addons/gradient_shader/ui/box_flat_highlight.tres")
var box_scroll : StyleBoxFlat = load("res://addons/gradient_shader/ui/box_flat_scrollbar.tres")

const text_classes: Array = ["Button", "Panel", "Label"]

var color_mid

func _ready():
	set_dark(color_dark)
	set_light(color_light)
	material.set_shader_param("y_scale", scale)
	material.set_shader_param("y_top", top)
	
func set_dark(val):
	material.set_shader_param("color_dark", color_dark)
	material2d.set_shader_param("color_dark", color_dark)
	color_dark = val
	color_mid = color_dark.linear_interpolate(color_light, 0.5)
	box_norm.bg_color = color_mid
	box_norm.border_color = color_dark.linear_interpolate(color_light, 0.2)
	box_highlight.bg_color = color_dark.linear_interpolate(color_light, 0.8)
	box_highlight.border_color = color_dark
	box_scroll.bg_color = color_mid
	box_scroll.border_color = color_dark
	for name in text_classes:
		ui_theme.set_color("font_color_focus", name, color_dark)
		ui_theme.set_color("font_color_hover", name, color_dark)
		ui_theme.set_color("font_color_pressed", name, color_mid)
	

func set_light(val):
	material.set_shader_param("color_light", color_light)
	material2d.set_shader_param("color_light", color_light)
	color_light = val
	color_mid = color_dark.linear_interpolate(color_light, 0.5)
	box_norm.bg_color = color_mid
	box_norm.border_color = color_dark.linear_interpolate(color_light, 0.2)
	box_highlight.bg_color = color_dark.linear_interpolate(color_light, 0.8)
	box_scroll.bg_color = color_mid
	for name in text_classes:
		ui_theme.set_color("font_color", name, color_light)
		ui_theme.set_color("font_color_pressed", name, color_mid)
	
func set_scale(val):
	material.set_shader_param("y_scale", scale)
	scale = val

func set_top(val):
	material.set_shader_param("y_top", top)
	top = val