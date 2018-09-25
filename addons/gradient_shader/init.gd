tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("GradientProperties", "Node",
	    preload("editor/node.gd"), preload("editor/icon.png"))


func _exit_tree():
	remove_custom_type("GradientProperties")