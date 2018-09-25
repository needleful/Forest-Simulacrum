extends StaticBody

signal exit

export(String) var ac_name = "Item" setget set_name
export(String) var action_type = "take"
onready var G = get_node("/root/global")

var active: bool = true

func _ready():
	pass

func set_name(new_name):
	remove_from_group(ac_name)
	add_to_group(new_name)
	ac_name = new_name

func act():
	G.add_item(ac_name)
	emit_signal("exit")
	
func set_active(val: bool):
	active = val