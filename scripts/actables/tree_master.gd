extends Node

var phase = 1

onready var body:StaticBody = $StaticBody
onready var mesh:MeshInstance = $Cube

func _ready():
	body.action_type = "saw"
	body.active = false
	body.ac_name = "Tree_Master"
	body.connect("exit", self, "chop")

func chop():
	if phase == 1:
		mesh.hide()
	else:
		if phase == 4:
			body.active = false
			body.get_node("CollisionShape").disabled = true
		elif phase == 3:
			body.ac_name = "Final_Wood"
		get_node("chopped"+str(phase-1)).hide()
	get_node("chopped"+str(phase)).show()
	phase += 1