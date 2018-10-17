extends Node

signal registered_event(name)
signal phase_change(old_phase, new_phase)

var inventory: Dictionary = {}
var ui: Control

onready var inp = get_node("/root/input")

const options_file:String = "res://settings.var"

var options setget set_options

enum Phase{
	FLOWERS,
	HOUSE,
	BEDTIME,
}
var phase = FLOWERS setget change_phase
var events: Array = []

func _ready():
	print("Ready")
	if inp == null:
		print("inp is NULL")
	options = Options.new()

func enable_options():
	self.options = load_options()

func set_options(val):
	if val == null:
		return
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

func load_options(file=options_file):
	var opt = Options.new()
	var f = File.new()
	var err = f.open(file, File.READ)
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

func dlg_not(args)->bool:
	var m = "dlg_" + str(args[0])
	if !has_method(m):
		return false
	else:
		args.remove(0)
		return not call(m, args)