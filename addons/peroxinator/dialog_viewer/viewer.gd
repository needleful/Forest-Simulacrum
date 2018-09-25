tool
extends Control

enum ViewerState {
	DLG_WRITING,
	DLG_VIEW_REPLIES,
	DLG_FREE,
	DLG_CLOSED
}

signal view_state_changed(previous, next)
signal dialog_command(command, args)

const VIEWER = preload("viewer.tscn")
const DialogTree = preload("res://addons/peroxinator/dialog_tree.gd")

export(String) var entry = "Home"
export var text_speed = 2.0 setget set_speed

var viewer
var reply_box : VBoxContainer
var textbox: Label
var scrollbox : ScrollContainer
var timer = Timer.new()
var dialog_tree : DialogTree

var mouse_capture

# State for rendering
var text_id: String
var current_text
var page = 0
var state = DLG_CLOSED setget set_state

func _input(event):
	if Input.is_action_just_pressed("gm_act"):
		match state:
			DLG_WRITING:
				textbox.visible_characters = textbox.get_total_character_count()
			DLG_VIEW_REPLIES:
				return
			DLG_FREE:
				if page >= current_text.pages.size()-1:
					set_state(DLG_VIEW_REPLIES)
					show_replies_or_exit()
				else:
					page += 1
					update_text(false)

func _enter_tree():
	viewer = VIEWER.instance()
	add_child(viewer)
	add_child(timer)
	textbox = viewer.get_node("margin/scroll/text")
	reply_box = viewer.get_node("margin/replies")
	reply_box.get_parent().remove_child(reply_box)
	
	scrollbox = viewer.get_node("margin/scroll")
	timer.connect("timeout", self, "on_timeout")

func _ready():
	set_process_input(false)
	hide()

func _exit_tree():
	set_process_input(false)
	for child in get_children():
		child.queue_free()

func enter():
	show()
	text_id = entry
	update_text()
	mouse_capture = Input.get_mouse_mode()
	set_process_input(true)

func update_text(new_pages = true):
	set_state(DLG_WRITING)
	if new_pages == true:
		page = 0
		current_text = dialog_tree.get_text(text_id)
	textbox.set_visible_characters(0)
	textbox.text = current_text.pages[page].text
	for c in current_text.pages[page].commands:
		send_command(c)
	timer.start()

func on_timeout():
	textbox.set_visible_characters(textbox.get_visible_characters()+1)
	if textbox.get_visible_characters() >= textbox.get_total_character_count():
		timer.stop()
		set_state(DLG_FREE)

func show_replies_or_exit():
	var replies = dialog_tree.get_replies(text_id)
	if replies.size() == 0:
		dlg_exit()
	else:
		set_state(DLG_VIEW_REPLIES)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		for reply in replies:
			#A hack for compositing multiple messages
			if reply.text == "__AUTO_REPLY__":
				on_reply(reply)
				return
			var button = Button.new()
			button.theme = reply_box.theme
			button.connect("pressed", self, "on_reply", [reply], CONNECT_ONESHOT)
			button.text = reply.text
			reply_box.add_child(button)

func on_reply(reply):
	text_id = reply.next
	for c in reply.commands:
		send_command(c)
	Input.set_mouse_mode(mouse_capture)
	for child in reply_box.get_children():
		child.queue_free()
	if text_id == null or text_id == '':
		print_debug("Exiting dialog...")
		dlg_exit()
	else:
		update_text()

func dlg_exit():
	set_process_input(false)
	hide()
	timer.stop()
	set_state(DLG_CLOSED)

func set_speed(val):
	text_speed = val
	timer.wait_time = 0.1/val

func set_state(next):
	emit_signal("view_state_changed", state, next)
	match(next):
		DLG_WRITING:
			scrollbox.scroll_vertical = 0
			scrollbox.remove_child(reply_box)
			scrollbox.add_child(textbox)
		DLG_VIEW_REPLIES:
			scrollbox.scroll_vertical = 0
			scrollbox.remove_child(textbox)
			scrollbox.add_child(reply_box)
	state = next
	
func set_source(src:String):
	dialog_tree = DialogTree.new(src)
	
func send_command(c):
	emit_signal("dialog_command", c.command, c.args)