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
var box_tab_fg :StyleBoxFlat = load("res://addons/gradient_shader/ui/box_flat_tab_fg.tres")
var box_tab_bg :StyleBoxFlat = load("res://addons/gradient_shader/ui/box_flat_tab_bg.tres")

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
	box_highlight.border_color = color_dark
	box_scroll.border_color = color_dark
	box_tab_fg.border_color = color_dark
	for name in text_classes:
		ui_theme.set_color("font_color_focus", name, color_dark)
		ui_theme.set_color("font_color_hover", name, color_dark)
		ui_theme.set_color("font_color_pressed", name, color_dark)
	ui_theme.set_color("font_color_fg", "TabContainer", color_dark)
	set_mid()

func set_light(val):
	material.set_shader_param("color_light", color_light)
	material2d.set_shader_param("color_light", color_light)
	color_light = val
	for name in text_classes:
		ui_theme.set_color("font_color", name, color_light)
	ui_theme.set_color("font_color_bg", "TabContainer", color_light)
	set_mid()

func set_mid():
	color_mid = color_dark.linear_interpolate(color_light, 0.5)
	var mid_light = color_dark.linear_interpolate(color_light, 0.8)
	var mid_dark = color_dark.linear_interpolate(color_light, 0.2)
	box_norm.bg_color = color_mid
	box_norm.border_color = mid_dark
	box_highlight.bg_color = mid_light
	box_scroll.bg_color = color_mid
	box_tab_bg.bg_color = color_mid
	box_tab_bg.border_color = mid_dark
	box_tab_fg.bg_color = mid_light

func set_scale(val):
	material.set_shader_param("y_scale", scale)
	scale = val

func set_top(val):
	material.set_shader_param("y_top", top)
	top = val