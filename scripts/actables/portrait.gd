extends Spatial

onready var b = $Panel/body
func _ready():
	b.connect("enter", self, "on_entry")
	G.connect("phase_change", self, "on_phase_change")
	
onready var G = get_node("/root/global")

func on_entry():
	if G.phase == G.FLOWERS:
		if G.has_item("forbidden_knowledge"):
			b.dialog_entry = "Knowledge"
		elif b.talked:
			b.dialog_entry = "Talked"
	if G.phase == G.HOUSE:
		if G.has_item("wrath"):
			b.dialog_entry = "Doom"
		elif G.has_item("saw"):
			b.dialog_entry = "Building"

func on_phase_change(old_phase, new_phase):
	b.talked = false
	b.dialog_entry = "Home"
	if new_phase == G.HOUSE:
		b.dialog_source = $dlg_phase_2.source_path
	else:
		print_debug("Unknown phase: ", new_phase)
