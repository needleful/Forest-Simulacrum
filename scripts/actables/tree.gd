extends Node

export(NodePath) var body_path = "StaticBody"
export(NodePath) var chopped_path = "chopped"
export(NodePath) var mesh_path = "Cube"
export(String) var size = ""

onready var body:StaticBody = get_node(body_path)
onready var chopped:MeshInstance = get_node(chopped_path)
onready var mesh:MeshInstance = get_node(mesh_path)

func _ready():
	body.action_type = "saw"
	body.active = false
	body.ac_name = "Tree_"+size
	body.connect("exit", self, "chop")

func chop():
	mesh.hide()
	chopped.show()
	body.active = false
	body.get_node("CollisionShape").disabled = true