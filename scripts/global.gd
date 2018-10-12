extends Node

signal registered_event(name)
signal phase_change(old_phase, new_phase)

var inventory: Dictionary = {}
var ui: Control

const InputController = preload("res://scripts/ui/input.gd")
var inp : InputController

const options_file:String = "res://settings.var"

var using_controller = false setget use_controller

class Options:
	var fullscreen:bool setget set_fullscreen
	var controls: Dictionary
	func _init(to_copy = null):
		controls = {}
		if to_copy:
			fullscreen = to_copy.fullscreen
			for key in to_copy.controls.keys():
				controls[key] = to_copy.controls[key]
		else:
			fullscreen = OS.window_fullscreen
		if controls.size() < InputMap.get_actions().size():
			get_default_controls()

	func to_dict()->Dictionary:
		var d = {}
		d['fullscreen'] = fullscreen
		d['controls'] = controls
		return d

	func from_dict(dict):
		fullscreen = dict['fullscreen']
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
	
	func apply():
		set_fullscreen(fullscreen)
		for ac in controls.keys():
			InputMap.action_erase_events(ac)
			for ev in controls[ac]:
				InputMap.action_add_event(ac, ev)

var options:Options

enum Phase{
	FLOWERS,
	HOUSE,
	BEDTIME,
}
var phase = FLOWERS
var events: Array = []

func _ready():
	options = load_options()
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