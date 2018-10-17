tool
extends Control

enum ViewerState {
	DLG_WRITING,
	DLG_VIEW_REPLIES,
	DLG_FREE,
	DLG_CLOSED
}

export(bool) var controller_focus = false

signal view_state_changed(previous, next)
signal dialog_command(command, args)

const VIEWER = preload("viewer.tscn")
const DialogTree = preload("res://addons/peroxinator/dialog_tree.gd")

export(String) var entry = "Home"
export var text_speed = 1 setget set_speed

var viewer
var reply_box : VBoxContainer
var textbox: Label
var scrollbox : ScrollContainer
var timer = Timer.new()
var dialog_tree : DialogTree

#This one's basically a dynamic Strategy Pattern object
var resolver

var mouse_capture

# State for rendering
var text_id: String
var current_text
var page = 0
var state = DLG_CLOSED setget set_state

var focused = false
var last_focused:Control

func _input(event):
	if event.is_action_pressed("gm_act"):
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
	if state == DLG_VIEW_REPLIES && !focused && (
		event.is_action_pressed("ui_down") ||
		event.is_action_pressed("ui_up")
	):
		for b in reply_box.get_children():
			if b is Button:
				b.grab_focus()
				break
		focused = true
		get_tree().set_input_as_handled()

func _enter_tree():
	viewer = VIEWER.instance()
	add_child(viewer)
	add_child(timer)
	textbox = viewer.get_node("margin/scroll/text")
	textbox.get_parent().remove_child(textbox)
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
	if replies == null || replies.size() == 0:
		exit()
	else:
		set_state(DLG_VIEW_REPLIES)
		if !controller_focus:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		for reply in replies:
			var cond = true
			for c in reply.conditions:
				var res = is_true(c)
				cond = cond and res
			if !cond:
				continue
			#A hack for compositing multiple messages
			if reply.type == "Auto":
				on_reply(reply)
				return
			var button = Button.new()
			button.theme = reply_box.theme
			button.connect("pressed", self, "on_reply", [reply], CONNECT_ONESHOT)
			button.connect("focus_entered", self, "focus_on_reply", [button])
			button.text = reply.text
			reply_box.add_child(button)

func focus_on_reply(button:Control):
	if controller_focus:
		scrollbox.scroll_vertical = button.rect_position.y

func on_reply(reply):
	focused = false
	text_id = reply.next
	for c in reply.commands:
		send_command(c)
	Input.set_mouse_mode(mouse_capture)
	for child in reply_box.get_children():
		child.queue_free()
	if text_id == null or text_id == '':
		exit()
	else:
		update_text()

func exit():
	set_process_input(false)
	hide()
	timer.stop()
	set_state(DLG_CLOSED)

func set_speed(val):
	text_speed = val
	timer.wait_time = 0.1/val

func set_state(next):
	if state == next:
		return
	emit_signal("view_state_changed", state, next)
	match(next):
		DLG_WRITING:
			scrollbox.scroll_vertical = 0
			if textbox.get_parent() != scrollbox:
				scrollbox.remove_child(reply_box)
				scrollbox.add_child(textbox)
		DLG_VIEW_REPLIES:
			scrollbox.scroll_vertical = 0
			if reply_box.get_parent() != scrollbox:
				scrollbox.remove_child(textbox)
				scrollbox.add_child(reply_box)
	state = next
	
func set_source(src:String):
	dialog_tree = DialogTree.new(src)
	
func send_command(c):
	emit_signal("dialog_command", c.command, c.args)

func _on_pause(paused:bool):
	focused = false

func is_true(c: DialogTree.Command):
	if resolver != null && resolver.has_method("dlg_"+c.command):
		return resolver.call("dlg_"+c.command, c.args)
	else:
		return true