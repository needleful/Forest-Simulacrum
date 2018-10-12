extends Node

signal registered_event(name)
signal phase_change(old_phase, new_phase)

var inventory: Dictionary = {}
var ui: Control

const InputController = preload("res://scripts/ui/input.gd")
var inp : InputController

const options_file:String = "res://settings.var"

var using_controller = false setget use_controller
var controller_type = PAD_XBOX setget set_controller_type

var controller_name = "" setget set_controller_name

var options setget set_options

enum ControllerType{
	PAD_XBOX,
	PAD_PLAYSTATION,
	PAD_NINTENDO,
	PAD_OTHER,
}

enum Phase{
	FLOWERS,
	HOUSE,
	BEDTIME,
}
var phase = FLOWERS
var events: Array = []

func _ready():
	print("Ready")
	options = Options.new()

func enable_options():
	self.options = load_options()

func set_options(val):
	options.disconnect("set_sns_x", self, "set_sns_x")
	options.disconnect("set_sns_y", self, "set_sns_y")
	options.disconnect("set_mouse_sns_x", self, "set_mouse_sns_x")
	options.disconnect("set_mouse_sns_y", self, "set_mouse_sns_y")
	options = val
	options.connect("set_sns_x", self, "set_sns_x")
	options.connect("set_sns_y", self, "set_sns_y")
	options.connect("set_mouse_sns_x", self, "set_mouse_sns_x")
	options.connect("set_mouse_sns_y", self, "set_mouse_sns_y")
	options.apply()

func load_options():
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

func save_options(options):
	var f = File.new()
	var err = f.open(options_file, File.WRITE)
	if err != OK:
		print_debug("Failed to save options with code: ", err)
	else:
		f.store_string(to_json(options.to_dict()))
		f.close()

func use_controller(use:bool):
	using_controller = use
	if ui:
		ui.get_node("DialogViewer").controller_focus = use

func set_controller_type(val):
	controller_type = val

func set_controller_name(name:String):
	if name == controller_name:
		return
	if name.matchn("*XInput*") or name.matchn("*XBox*"):
		set_controller_type(PAD_XBOX)
	else:
		set_controller_type(PAD_OTHER)
	controller_name = name

func set_sns_x(val):
	if inp == null:
		return
	inp.sensitivity.x = val

func set_sns_y(val):
	if inp == null:
		return
	inp.sensitivity.y = val

func set_mouse_sns_x(val):
	if inp == null:
		return
	inp.mouse_sns.x = val

func set_mouse_sns_y(val):
	if inp == null:
		return
	inp.mouse_sns.y = val

func has_item(item, count=1) -> bool:
	return inventory.has(item) && inventory[item] >= count
	
func remove_item(item, number = 1) -> void:
	if !inventory.has(item):
		return
	inventory[item] -= number
	if inventory[item] <= 0:
		inventory.erase(item)
		
func add_item(item, count = 1) -> void:
	if !inventory.has(item):
		inventory[item] = count
	else:
		inventory[item] += count
		
func register_event(event_name: String):
	events.push_back(event_name)
	emit_signal("registered_event", event_name)
	
func change_phase(next_phase):
	emit_signal("phase_change", phase, next_phase)
	phase = next_phase

func dlg_has(args)->bool:
	for arg in args:
		if !has_item(arg):
			return false
	return true