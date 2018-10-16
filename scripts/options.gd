extends Object
class_name Options

signal set_sns_x(val)
signal set_sns_y(val)

signal set_mouse_sns_x(val)
signal set_mouse_sns_y(val)

var fullscreen:bool setget set_fullscreen
var anti_aliasing:bool setget set_anti_aliasing
var vsync:bool setget set_vsync

var sensitivity_x:float setget set_sns_x
var sensitivity_y:float setget set_sns_y

var mouse_sns_x:float setget set_mouse_sns_x
var mouse_sns_y:float setget set_mouse_sns_y


const unbound_event = "---"

# Button indexes, with XBox, Playstation, and Nintendo names
const button_index_names = [
	["A", "X", "B"], #0
	["B", "Circle", "A"], #1
	["X", "Square", "Y"], #2
	["Y", "Triangle", "X"],#3
	["LB", "L1", "L"], #4
	["RB", "R1", "R"],#5
	["LT", "L2", "L2"],#6
	["RT", "R2", "R2"],#7
	["LS", "L3", "LS"],#8
	["RS", "R3", "RS"],#9
	["Back", "Select", "-"],#10
	["Start", "Start", "+"],#11
	["D-Up", "D-Up","D-Up"],#12
	["D-Down","D-Down","D-Down"],#13
	["D-Left","D-Left","D-Left"],#14
	["D-Right","D-Right","D-Right"],#15
]

var controls: Dictionary

static func get_event_name(event:InputEvent, G:Node) -> String:
	if event is InputEventJoypadMotion:
		var name = ""
		match(event.axis):
			JOY_AXIS_0:
				name = "Left X"
			JOY_AXIS_1:
				name= "Left Y"
			JOY_AXIS_2:
				name="Right X"
			JOY_AXIS_3:
				name="Right Y"
			_:
				name="Axis "+str(event.axis)
		if event.axis_value > 0:
			name += "+"
		else:
			name += "-"
		return name
	elif event is InputEventJoypadButton:
		var idx = G.inp.controller_type%3
		return "["+ button_index_names[event.button_index][idx]+"]"
	elif event is InputEventMouseButton:
		var m = ""
		match(event.button_index):
			BUTTON_LEFT:
				m = "Left "
			BUTTON_RIGHT:
				m = "Right "
			BUTTON_MIDDLE:
				m = "Middle "
		return m + "Mouse"
	else:
		return event.as_text()

func _init(to_copy = null):
	controls = {}
	if to_copy:
		fullscreen = to_copy.fullscreen
		anti_aliasing = to_copy.anti_aliasing
		vsync = to_copy.vsync
		for key in to_copy.controls.keys():
			controls[key] = to_copy.controls[key]
	else:
		fullscreen = OS.window_fullscreen
		vsync = OS.vsync_enabled
	if controls.size() < InputMap.get_actions().size():
		get_default_controls()

func to_dict()->Dictionary:
	var d = {}
	d['fullscreen'] = fullscreen
	d['controls'] = controls
	d['vsync'] = vsync
	d['anti_aliasing'] = anti_aliasing
	d['sensitivity_x'] = sensitivity_x
	d['sensitivity_y'] = sensitivity_y
	d['mouse_sns_x'] = mouse_sns_x
	d['mouse_sns_y'] = mouse_sns_y
	return d

func from_dict(dict):
	if dict.has('fullscreen'):
		fullscreen = dict['fullscreen']
	if dict.has("vsync"):
		vsync = dict['vsync']
	if dict.has("anti_aliasing"):
		anti_aliasing = dict['anti_aliasing']
	if dict.has('sensitivity_x'):
		sensitivity_x = dict['sensitivity_x']
	if dict.has('sensitivity_y'):
		sensitivity_y = dict['sensitivity_y']
	if dict.has('mouse_sns_x'):
		mouse_sns_x = dict['mouse_sns_x']
	if dict.has('mouse_sns_y'):
		mouse_sns_y = dict['mouse_sns_y']
#		controls = dict['controls']
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

func set_anti_aliasing(val):
	anti_aliasing = val
	#TODO

func set_vsync(val):
	vsync = val
	OS.vsync_enabled = val

func set_sns_x(val):
	sensitivity_x = val
	emit_signal("set_sns_x", val)

func set_sns_y(val):
	sensitivity_y = val
	emit_signal("set_sns_y", val)

func set_mouse_sns_x(val):
	mouse_sns_x = val
	emit_signal("set_mouse_sns_x", val)

func set_mouse_sns_y(val):
	mouse_sns_y = val
	emit_signal("set_mouse_sns_y", val)

func apply():
	set_fullscreen(fullscreen)
	set_anti_aliasing(anti_aliasing)
	set_vsync(vsync)
	set_sns_x(sensitivity_x)
	set_sns_y(sensitivity_y)
	for ac in controls.keys():
		InputMap.action_erase_events(ac)
		for ev in controls[ac]:
			InputMap.action_add_event(ac, ev)