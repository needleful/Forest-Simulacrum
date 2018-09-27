tool
extends EditorPlugin

var dialog_editor:Control
var icon = preload("dialog_viewer/node_icon.png")
func _enter_tree():
	dialog_editor = load("res://addons/peroxinator/dialog_editor/editor.tscn").instance()
	add_custom_type("DialogSource", "Node",
		DialogSource, icon)

	add_custom_type("DialogViewer", "Control",
		preload("dialog_viewer/viewer.gd"), icon)
	make_visible(false)
	get_editor_interface().get_editor_viewport().add_child(dialog_editor)

func _exit_tree():
	clear()
	remove_custom_type("DialogSource")
	remove_custom_type("DialogViewer")
	dialog_editor.queue_free()

func get_plugin_icon():
	return icon

func get_plugin_name():
	return "Peroxinator"

func has_main_screen():
	return true

func handles(object):
	return object is DialogSource

func make_visible(visible):
	if visible:
		dialog_editor.show()
	else:
		clear()
		dialog_editor.set_dialog_source("")
		dialog_editor.hide()

func apply_changes():
	if dialog_editor:
		dialog_editor.save_to_file()

func clear():
	dialog_editor.clear_graph()

func edit(object):
	var dialog:DialogSource = object
	print("Editing dialog file: ",dialog.source_path)
	dialog_editor.set_dialog_source(object.source_path)