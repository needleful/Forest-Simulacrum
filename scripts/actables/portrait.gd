extends Spatial

onready var b = $Panel/body
func _ready():
	b.connect("enter", self, "on_entry")
	
onready var G = get_node("/root/global")

func on_entry():
	if G.phase == G.FLOWERS:
		if G.has_item("forbidden_knowledge"):
			b.dialog_entry = "Knowledge"
		elif b.talked:
			b.dialog_entry = "Talked"
