extends Panel

signal exit

var action_editor = load("res://ui/action_editor.tscn")

const options_file:String = "res://settings.var"

const action_names:Dictionary = {
	"mv_left":"Move Left",
	"mv_right":"Move Right",
	"mv_forward":"Move Forward",
	"mv_backward":"Move Backward",
	"mv_jump": "Jump",
	"gm_act":"Act",
	"gm_pause":"Pause"
}

class Options:
	var fullscreen:bool setget set_fullscreen
	var controls: Dictionary
	func _init(to_copy = null):
		if to_copy:
			fullscreen = to_copy.fullscreen
			for key in to_copy.controls.keys():
				controls[key] = to_copy.controls[key]
		else:
			fullscreen = OS.window_fullscreen
			controls = {}
		if controls.empty():
			get_default_controls()

	func to_dict()->Dictionary:
		var d = {}
		d['fullscreen'] = fullscreen
		d['controls'] = controls
		return d

	func from_dict(dict):
		fullscreen = dict['fullscreen']
		controls = dict['controls']
		if controls.empty():
			get_default_controls()

	func get_default_controls():
		for action in InputMap.get_actions():
			controls[action] = []
			for event in InputMap.get_action_list(action):
				controls[action].push_back(event)

	func set_fullscreen(val):
		fullscreen = val
		OS.set_window_fullscreen(val)
	
	func apply():
		set_fullscreen(fullscreen)
		for ac in controls.keys():
			InputMap.action_erase_events(ac)
			for ev in controls[ac]:
				InputMap.action_add_event(ac, ev)

onready var options: Options = Options.new()
var prev_options

func _ready():
	options = load_options()
	options.apply()
	for action in options.controls.keys():
		if not action_names.has(action):
			continue
		var ac = action_editor.instance()
		ac.get_node("Label").text = action_names[action]
		$vbox/tab/controls/actions/vbox.add_child(ac)

func display():
	show()
	prev_options = Options.new(options)
	$vbox/tab/graphics/Fullscreen.set_value(options.fullscreen)

func load_options()->Options:
	var opt = Options.new()
	var f = File.new()
	var err = f.open(options_file, File.READ)
	if err != OK:
		print_debug("Failed to open options with code: ", err)
		return Options.new()
	else:
		var s = f.get_as_text()
		var o = parse_json(s)
		if o == null || typeof(o)!= TYPE_DICTIONARY:
			print_debug("Whoops, all berries! ", typeof(o))
		else:
			opt.from_dict(o)
		f.close()
	return opt

func save_options(options:Options):
	var f = File.new()
	var err = f.open(options_file, File.WRITE)
	if err != OK:
		print_debug("Failed to save options with code: ", err)
	else:
		f.store_string(to_json(options.to_dict()))
		f.close()

func _on_set_fullscreen(val):
	options.fullscreen = val

func _on_cancel_pressed():
	options = prev_options
	options.apply()
	emit_signal("exit")

func _on_apply_pressed():
	save_options(options)
	emit_signal("exit")