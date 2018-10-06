tool
extends PanelContainer

signal node_deleted(id)

var selected:GraphNode setget select

const ReplyEditor = preload("res://addons/peroxinator/dialog_editor/reply-editor.tscn")

func _ready():
	$v/dialog.connect("text_changed", self, "set_text")

func select(val:GraphNode):
	if selected != null:
		for c in $v/replies.get_children():
			c.disconnect("reply_deleted", self, "delete_reply")
			if c is HBoxContainer:
				$v/replies.remove_child(c)
		$v/id_text.disconnect("text_changed", selected, "set_id")
		$v/final.disconnect("toggled", selected, "finalize")
	
	selected = val
	if val != null:
		$v/id_text.text = val.id
		$v/dialog.text = val.text
		$v/final.pressed = val.final
		for r in val.replies:
			var red = ReplyEditor.instance()
			$v/replies.add_child(red)
			red.bind_reply(r)
			red.connect("reply_deleted", self, "delete_reply")
		$v/id_text.connect("text_changed", selected, "set_id")
		$v/final.connect("toggled", selected, "finalize")

func set_text():
	if selected != null:
		selected.text = $v/dialog.text

func delete_node():
	emit_signal("node_deleted", selected.id)
	selected = null

func delete_reply(reply):
	if selected != null:
		selected.remove_reply(reply)

func add_reply():
	selected.add_reply(selected.Reply.new(selected))
	var r = selected.replies
	if r.size() == 0:
		var reply 
	var reply = r[r.size()-1]
	var red = ReplyEditor.instance()
	$v/replies.add_child(red)
	red.bind_reply(reply)
	red.connect("reply_deleted", self, "delete_reply")

func clear():
	selected = null
	for c in $v/replies.get_children():
		c.disconnect("reply_deleted", self, "delete_reply")
		if c is HBoxContainer:
			$v/replies.remove_child(c)
	$v/id_text.disconnect("text_changed", selected, "set_id")
	$v/dialog.text = ""
	$v/id_text.text = ""
	
	