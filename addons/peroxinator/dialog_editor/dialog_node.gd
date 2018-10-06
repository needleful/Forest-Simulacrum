tool
extends GraphNode

signal id_change(node, old_id, new_id)
signal reply_disconnect(from_slot, to)
signal reply_connect(from_slot, to)

var id:String setget set_id
var text:String setget set_text
var final:bool setget finalize

const reply_slot_color = Color(1, 0.4, 0.6, 0.7)
const auto_slot_color = Color(0.2, 1, 0.5, 0.7)

var loaded = false

class Reply:
	var text:String
	var next:GraphNode
	var type:String = "Circle" setget set_type
	var _label:Label
	var _slot:int
	var _parent:GraphNode
	
	func _init(parent):
		_parent = parent
	
	func set_type(val):
		if _label != null:
			_label.text = val
		type = val
		if _parent.loaded:
			var sl_color:Color = reply_slot_color
			if type == "Auto":
				sl_color = auto_slot_color
			_parent.set_slot(_slot, false, TYPE_NIL, 
				Color.black, true, TYPE_STRING, sl_color)

var replies:Array = []

func set_node_data(nd:Dictionary):
	offset.x = ge(nd, "_editor_x")
	offset.y = ge(nd, "_editor_y")
	self.id = ge(nd, "id")
	self.text = ge(nd, "text")
	if nd.has("final"):
		self.final = nd["final"]
	else:
		self.final = false
	var message_slot_color = Color(1,1,1,0.7)
	if final:
		message_slot_color = Color(0.7,0.5, 0, 0.7)
	set_slot(0, true, TYPE_STRING, 
		message_slot_color, true, TYPE_NIL, Color(0,0,0,0))

func set_replies(nd:Dictionary, dlg_nodes:Dictionary):
	var re = ge(nd,"replies")
	for r in re:
		var reply:Reply = Reply.new(self)
		reply.text = ge(r, "text")
		var next_id = ge(r, "id")
		if dlg_nodes.has(next_id):
			reply.next = dlg_nodes[next_id]
		reply.type = ge(r, "type")
		replies.push_back(reply)
	update_replies()
	loaded = true

func set_id(val):
	if val != null and val != "":
		id = val
		$Label.text = val
		emit_signal("id_change", self, id, val)

func set_text(val):
	text = val

func finalize(val):
	final = val
	var message_slot_color = Color(1,1,1,0.7)
	if final:
		message_slot_color = Color(0.7,0.5, 0, 0.7)
	set_slot(0, true, TYPE_STRING, 
		message_slot_color, true, TYPE_NIL, Color(0,0,0,0))

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
	reply._slot = slot
	var r = Label.new()
	if reply.text == "__AUTO_REPLY__":
		reply.type = "Auto"
	r.align = Label.ALIGN_RIGHT
	r.text = reply.type
	r.hint_tooltip = reply.text
	add_child(r)
	reply._label = r
	var sl_color = reply_slot_color
	if reply.type == "Auto":
		sl_color = auto_slot_color
	set_slot(slot, false, TYPE_NIL, 
		Color.black, true, TYPE_STRING, sl_color)

func remove_reply(reply:Reply):
	var idx = replies.find(reply)
	if idx < 0:
		print_debug("Tried to delete nonexistant reply!  Possible bug")
		return
	#Move all connections up one slot
	for slot in range(idx + 1, replies.size()+1):
		var next = replies[slot-1].next
		if next != null:
			emit_signal("reply_disconnect", slot, next.name)
			if slot > idx+1:
				emit_signal("reply_connect", slot-1, next.name)
	#Clear final slot and remove children
	clear_slot(replies.size()+1)
	remove_child(reply._label)
	replies.remove(idx)
	#TODO: Resize container

func disconnect_from_node(node:GraphNode):
	for reply in replies:
		if reply.next == node:
			reply.next = null

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
		final = self.final,
		replies = []
	}
	for reply in replies:
		var id
		if reply.next != null:
			id = reply.next.id
		else:
			id = null
		data.replies.push_back({
			id = id,
			text = reply.text,
			type = reply.type
		})
	return data

func ge(dict, key):
	if dict.has(key):
		return dict[key]
	else:
		return ""