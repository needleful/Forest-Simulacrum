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
	prepare_display()

func display():
	prepare_display()
	show()

func prepare_display(advanced = false):
	prev_options = G.Options.new(G.options)
	$vbox/tab/graphics/Fullscreen.set_value(G.options.fullscreen)
	for c in $vbox/tab/controls/actions/vbox.get_children():
		if c is Control:
			$vbox/tab/controls/actions/vbox.remove_child(c)
	for action in G.options.controls.keys():
		if not advanced && not action_names.has(action):
			continue
		var ac = action_editor.instance()
		ac.set_action(action, G.options.controls[action])
		if not advanced:
			ac.label_text = action_names[action]
		else:
			ac.label_text = action
		$vbox/tab/controls/actions/vbox.add_child(ac)
		ac.connect("change_action_request", self, "change_action")
		ac.connect("focus_requested", self, "scroll_to_action")
		$controller_remap.connect("hide", self, "_on_remap_hide")
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
	var v = $vbox/tab/controls/actions.scroll_vertical
	var r = action_control.rect_position
	if G.using_controller && r.y < v:
		$vbox/tab/controls/actions.scroll_vertical = r.y
	if G.using_controller && r.y > v+90:
		$vbox/tab/controls/actions.scroll_vertical += r.y-v - 85
	$vbox/tab/controls/actions.scroll_horizontal = r.x

func _on_set_fullscreen(val):
	G.options.fullscreen = val

func _on_cancel_pressed():
	G.options = prev_options
	G.options.apply()
	emit_signal("exit")

func _on_apply_pressed():
	G.save_options(G.options)
	emit_signal("exit")

func _on_advanced_value_changed(value):
	prepare_display(value)
