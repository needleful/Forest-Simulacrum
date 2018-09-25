tool
extends GraphNode

signal id_change(node, old_id, new_id)
signal reply_disconnect(from_slot, to)

var id:String setget set_id
var text:String setget set_text

const message_slot_color = Color(1,1,1,0.7)
const reply_slot_color = Color(1, 0.4, 0.6, 0.7)

class Reply:
	var text:String
	var next:GraphNode
	var type:String = "Circle" setget set_type
	var _label:Label
	
	func set_type(val):
		if _label != null:
			_label.text = val
		type = val

var replies:Array = []

func _ready():
	set_slot(0, true, TYPE_STRING, 
		message_slot_color, true, TYPE_NIL, Color(0,0,0,0))

func set_node_data(nd:Dictionary):
	offset.x = ge(nd, "_editor_x")
	offset.y = ge(nd, "_editor_y")
	self.id = ge(nd, "id")
	self.text = ge(nd, "text")

func set_replies(nd:Dictionary, dlg_nodes:Dictionary):
	var re = ge(nd,"replies")
	for r in re:
		var reply:Reply = Reply.new()
		reply.text = ge(r, "text")
		var next_id = ge(r, "id")
		if dlg_nodes.has(next_id):
			reply.next = dlg_nodes[next_id]
		reply.type = ge(r, "type")
		replies.push_back(reply)
	update_replies()

func set_id(val):
	emit_signal("id_change", self, id, val)
	$Label.text = val
	id = val

func set_text(val):
	text = val

func add_reply(reply):
	add_reply_slots(reply)
	replies.push_back(reply)

func update_replies():
	var i = 1
	for reply in replies:
		add_reply_slots(reply, i)
		i += 1

func add_reply_slots(reply, slot=-1):
	if slot < 0:
		slot = replies.size()+1
	var r = Label.new()
	r.align = Label.ALIGN_RIGHT
	r.text = reply.type
	r.hint_tooltip = reply.text
	add_child(r)
	reply._label = r
	set_slot(slot, false, TYPE_NIL, 
		Color.black, true, TYPE_STRING, reply_slot_color)

func remove_reply(reply:Reply):
	var idx = -1
	for r in replies:
		idx += 1
		if r == reply:
			break
	if idx < 0:
		print_debug("Tried to delete nonexistant reply!  Possible bug")
		return
	var slot = idx + 1
	remove_child(reply._label)
	replies.remove(idx)
	clear_slot(slot)
	emit_signal("reply_disconnect", slot, reply.next.name)

func connect_reply(message:GraphNode, connection:String, slot:int):
	var reply = replies[slot-1]
	reply.next = message

func disconnect_reply(message:GraphNode, slot:int):
	replies[slot-1].next = null

func get_connection(slot:int):
	return replies[slot-1].next.name

func is_reply_connected(slot:int):
	var id = replies[slot-1].next
	return id != null

func export_data():
	var data = {
		_editor_x = offset.x,
		_editor_y = offset.y,
		id = self.id,
		text = self.text,
		replies = []
	}
	for reply in replies:
		data.replies.push_back({
			id = reply.next.id,
			text = reply.text,
			type = reply.type
		})
	return data

func ge(dict, key):
	if dict.has(key):
		return dict[key]
	else:
		return ""