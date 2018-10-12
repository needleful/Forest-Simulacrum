extends Panel

signal exit

var action_editor = load("res://ui/action_editor.tscn")
var prev_options

onready var G = get_node("/root/global")
var old_focus:Control

const action_names:Dictionary = {
	"mv_left":"Left",
	"mv_right":"Right",
	"mv_forward":"Forward",
	"mv_backward":"Backward",
	"mv_jump": "Jump",
	"gm_act":"Act",
	"gm_pause":"Pause"
}

func _ready():
	$controller_remap.connect("hide", self, "_on_remap_hide")
	$vbox/tab.set_tab_title(2, "Advanced Controls")
	prepare_display()

func display():
	prepare_display()
	show()

func prepare_display(advanced = false):
	$vbox/tab/Buttons/buttons/advanced.set_value(advanced)
	prev_options = Options.new(G.options)
	$vbox/tab/Graphics/Fullscreen.set_value(G.options.fullscreen)
	$vbox/tab/Graphics/AntiAliasing.set_value(G.options.anti_aliasing)
	$vbox/tab/Graphics/VSync.set_value(G.options.vsync)
	if G.using_controller:
		$vbox/tab/Controls/sns_x/slide.value = G.options.sensitivity_x
		$vbox/tab/Controls/sns_y/slide.value = G.options.sensitivity_y
		$vbox/tab/Controls/Label.text = "Controller: "+G.controller_name
	else:
		$vbox/tab/Controls/sns_x/slide.value = G.options.mouse_sns_x
		$vbox/tab/Controls/sns_y/slide.value = G.options.mouse_sns_y
		$vbox/tab/Controls/Label.text = "Keyboard and Mouse"

	for c in $vbox/tab/Buttons/actions/vbox.get_children():
		if c is Control:
			$vbox/tab/Buttons/actions/vbox.remove_child(c)
	for action in G.options.controls.keys():
		if not advanced && not action_names.has(action):
			continue
		var ac = action_editor.instance()
		ac.set_action(action, G.options.controls[action])
		if not advanced:
			ac.label_text = action_names[action]
		else:
			ac.label_text = action
		$vbox/tab/Buttons/actions/vbox.add_child(ac)
		ac.connect("change_action_request", self, "change_action")
		ac.connect("focus_requested", self, "scroll_to_action")
	$vbox/buttons/apply.focus_neighbour_right = NodePath("vbox/buttons/cancel")
	$vbox/buttons/cancel.focus_neighbour_left = NodePath("vbox/buttons/apply")

func _on_remap_hide():
	$vbox.show()
	if old_focus:
		old_focus.grab_focus()

func change_action(action_control:Control):
	old_focus = get_focus_owner()
	$vbox.hide()
	$controller_remap.request_input()
	$controller_remap.connect(
		"new_action", action_control, 
		"set_new_action", [], CONNECT_ONESHOT)

func scroll_to_action(action_control:Control):
	var v = $vbox/tab/Buttons/actions.scroll_vertical
	var r = action_control.rect_position
	if G.using_controller && r.y < v:
		$vbox/tab/Buttons/actions.scroll_vertical = r.y
	if G.using_controller && r.y > v+90:
		$vbox/tab/Buttons/actions.scroll_vertical += r.y-v - 85
	$vbox/tab/Buttons/actions.scroll_horizontal = r.x

func _on_set_fullscreen(val):
	G.options.fullscreen = val

func _on_vsync_toggled(value):
	G.options.vsync = value

func _on_anti_aliasing_toggled(value):
	G.options.anti_aliasing = value

func _on_cancel_pressed():
	G.options = prev_options
	emit_signal("exit")

func _on_apply_pressed():
	G.save_options(G.options)
	emit_signal("exit")

func _on_advanced_value_changed(value):
	prepare_display(value)

func _on_sns_x_changed(value):
	if G.using_controller:
		G.options.sensitivity_x = value
	else:
		G.options.mouse_sns_x = value
	$vbox/tab/Controls/sns_x/value.text = "%.02f" % value

func _on_sns_y_changed(value):
	if G.using_controller:
		G.options.sensitivity_y = value
	else:
		G.options.mouse_sns_y = value
	$vbox/tab/Controls/sns_y/value.text = "%.02f" % value
