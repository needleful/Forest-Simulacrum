tool
extends GraphNode

signal id_change(node, old_id, new_id)

var id:String setget set_id
var text:String setget set_text

const message_slot_color = Color(1,1,1,0.7)
const reply_slot_color = Color(1, 0.4, 0.6, 0.7)

class Reply:
	var text:String
	var next_id:String
	var type:String
	var _connection:String

var replies:Array = []

func _ready():
	set_slot(0, true, TYPE_STRING, 
		message_slot_color, true, TYPE_NIL, Color(0,0,0,0))

func set_node_data(nd:Dictionary):
	offset.x = ge(nd, "_editor_x")
	offset.y = ge(nd, "_editor_y")
	self.id = ge(nd, "id")
	self.text = ge(nd, "text")
	var re = ge(nd,"replies")
	for r in re:
		var reply:Reply = Reply.new()
		reply.text = ge(r, "text")
		reply.next_id = ge(r, "id")
		reply.type = ge(r, "type")
		replies.push_back(reply)
	update_replies()

func set_id(val):
	emit_signal("id_change", self, id, val)
	$Label.text = val
	id = val

func set_text(val):
	text = val

func update_replies():
	var i = 1
	for reply in replies:
		var r = Label.new()
		r.align = Label.ALIGN_RIGHT
		r.text = reply.type
		r.hint_tooltip = reply.text
		add_child(r)
		set_slot(i, false, TYPE_NIL, 
			Color.black, true, TYPE_STRING, reply_slot_color)
		i += 1

func connect_reply(message:GraphNode, connection:String, slot:int):
	var reply = replies[slot-1]
	reply.next_id = message.id
	reply._connection = connection

func disconnect_reply(slot:int):
	replies[slot-1].next_id = ""
	replies[slot-1]._connection = ""

func get_connection(slot:int):
	return replies[slot-1]._connection

func is_reply_connected(slot:int):
	var id = replies[slot-1].next_id
	return id != null && id != ""

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
			id = reply.next_id,
			text = reply.text,
			type = reply.type
		})
	return data

func ge(dict, key):
	if dict.has(key):
		return dict[key]
	else:
		return ""