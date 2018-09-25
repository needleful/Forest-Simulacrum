extends Node

export(NodePath) var body_path
export(String) var size

onready var body = get_node(body_path)

func _ready():
	body.ac_name = "Tree_"+size