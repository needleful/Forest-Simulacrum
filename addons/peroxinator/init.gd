tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("DialogViewer", "Control",
		preload("dialog_viewer/viewer.gd"), 
		preload("dialog_viewer/node_icon.png"))

func _exit_tree():
	remove_custom_type("DialogViewer")
	