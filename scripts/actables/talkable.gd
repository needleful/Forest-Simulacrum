extends Node

signal exit
signal enter

export(String) var ac_name
export(String, FILE) var dialog_source = "res://Scenes/viewables.json"
export(String) var dialog_entry = "Home"
export(String, "talk", "view", "take") var action_type = "talk"

onready var G = get_node("/root/global")
onready var dlg = get_node("/root/World/ui/DialogViewer")

var anim_player:AnimationPlayer

var talked: bool = false
var active: bool = true

func act():
	dlg.connect("view_state_changed", self, "on_view_state_changed")
	dlg.connect("dialog_command", self, "on_command")
	emit_signal("enter")
	dlg.set_source(dialog_source)
	dlg.entry = dialog_entry
	dlg.enter()
	
#If the dictionary of required items has been met
func met(req:Dictionary) ->bool:
	var met:bool
	if req.size() > 0:
		met = true
		for key in req.keys():
			met = met and G.has_item(key, req[key])
	else:
		met = false
	return met
	
func clear_items(items:Dictionary)->void:
	for key in items.keys():
		G.remove_item(key, items[key])

func exit():
	talked = true
	dlg.disconnect("view_state_changed", self, "on_view_state_changed")
	dlg.disconnect("dialog_command", self, "on_command")
	emit_signal("exit")
	
func on_view_state_changed(prev, next):
	if next == dlg.DLG_VIEW_REPLIES:
		G.inp.set_process_input(false)
	elif next == dlg.DLG_CLOSED:
		G.inp.set_process_input(true)
		exit()
	else:
		G.inp.set_process_input(true)

func on_command(op:String, args:Array):
	if has_method("dlg_" + op):
		call_deferred("dlg_" + op, args)
	else:
		print_debug("Unknown command: ", op, args)

#Dialog command functions
func dlg_anim(anims):
	if anim_player == null:
		print_debug("Tried to play animations without an AnimationPlayer!")
		return
	for a in anims:
		anim_player.play(a)

func dlg_event(events):
	for event in events:
		G.register_event(event)

func dlg_defer(args):
	var command = "dlg_" + args[0]
	args.remove(0)
	if !has_method(command):
		print_debug("Unknown defered command: ",command, args)
	connect("exit", self,
		command,
		[args],
		CONNECT_ONESHOT)
	
func dlg_entry(args):
	dialog_entry = args[0]
	
func dlg_give(args):
	for item in args:
		G.add_item(item)
	