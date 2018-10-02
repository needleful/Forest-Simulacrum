extends Node

signal registered_event(name)
signal phase_change(old_phase, new_phase)

var inventory: Dictionary = {}
var ui: Control

const InputController = preload("res://scripts/ui/input.gd")
var inp : InputController

enum Phase{
	FLOWERS,
	HOUSE,
}
var phase = FLOWERS
var events: Array = []
	
func has_item(item, count=1) -> bool:
	return inventory.has(item) && inventory[item] >= count
	
func remove_item(item, number = 1) -> void:
	inventory[item] -= number
	if inventory[item] <= 0:
		inventory.erase(item)
		
func add_item(item, count = 1) -> void:
	if !inventory.has(item):
		inventory[item] = count
	else:
		inventory[item] += count
		
func register_event(event_name: String):
	print_debug("Event registered: ", event_name)
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