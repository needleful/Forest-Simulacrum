extends Control

export(String, FILE, "*.json") var dialog_source = null setget set_dialog_source

const DialogNode = preload("dialog_node.tscn")

var dlg_nodes:Dictionary = {}

onready var g:GraphEdit = $split/tabs/graph
onready var e:PanelContainer = $split/edit

var current_tab:int = 0
const max_tab_title_len:int = 20

var edited_dlg:GraphNode

func _input(event):
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_RIGHT:
		var pos = g.get_global_mouse_position()
		var nd = DialogNode.instance()
		nd.connect("reply_disconnect", self, "on_reply_disconnect", [nd])
		nd.connect("id_change", self, "on_id_change")
		nd.id = nd.name+str(OS.get_ticks_msec())
		nd.offset = pos
		dlg_nodes[nd.id] = nd
		g.add_child(nd)

func _enter_tree():
	pass

func _ready():
	set_process_input(true)
	$menu_bar/file.get_popup().add_item("Open File..")
	$menu_bar/file.get_popup().add_item("Save")
	$menu_bar/file.get_popup().add_item("Save As..")
	$menu_bar/file.get_popup().connect("id_pressed", self, "act_on_file")
	
	g.connect("connection_request", self, "econnect")
	g.connect("disconnection_request", self, "edisconnect")
	g.connect("node_selected", self, "eselect")
	
	e.connect("node_deleted", self, "edelete")
	set_dialog_source(dialog_source)
	
func _exit_tree():
	clear_graph()

func clear_graph():
	dlg_nodes.clear()
	g.clear_connections()
	for c in g.get_children():
		if c is GraphNode:
			c.disconnect("reply_disconnect", self, "on_reply_disconnect")
			c.disconnect("id_change", self, "on_id_change")
			g.remove_child(c)

func set_dialog_source(val):
	dialog_source = val
	if g == null || val == null:
		return
	clear_graph()
	var f = File.new()
	var res = f.open(val, File.READ)
	if res != OK:
		print_debug("Bad: Failed to open file "+ val)
		return res
	
	var json = f.get_as_text()
	var data = parse_json(json)
	if(typeof(data) != TYPE_DICTIONARY):
		print_debug("Bad: Unexpected type of JSON")
		return ERR_PARSE_ERROR
	
	for key in data.keys():
		var dn = DialogNode.instance()
		dn.set_node_data(data[key])
		dn.connect("reply_disconnect", self, "on_reply_disconnect", [dn])
		dn.connect("id_change", self, "on_id_change")
		g.add_child(dn)
		dlg_nodes[key] = dn
	for key in dlg_nodes.keys():
		var dn = dlg_nodes[key]
		var dat = data[key]
		dn.set_replies(dat, dlg_nodes)
		var slot = 1
		for rep in dn.replies:
			if rep.next != null:
				econnect(dn.name, slot, rep.next.name, 0)
			slot += 1
	#minimize tab title
	
	$split/tabs.set_tab_title(current_tab, dialog_source)

func on_id_change(node:GraphNode, old_id:String, new_id:String):
	dlg_nodes.erase(old_id)
	dlg_nodes[new_id] = node

func econnect(from:String, fromslot:int, to:String, toslot:int):
	var from_node:GraphNode = g.get_node(from)
	if from_node.is_reply_connected(fromslot):
		edisconnect(from, fromslot, from_node.get_connection(fromslot), 0)
	from_node.connect_reply(g.get_node(to), to, fromslot)
	g.connect_node(from, fromslot, to, toslot)

func edisconnect(from:String, fromslot:int, to:String, toslot:int):
	var from_node:GraphNode = g.get_node(from)
	from_node.disconnect_reply(g.get_node(to), fromslot)
	g.disconnect_node(from, fromslot, to, toslot)

func eselect(val:GraphNode):
	e.select(val)

func edelete(id:String):
	var dn = dlg_nodes[id]
	g.remove_child(dn)
	dlg_nodes.erase(id)
	dn.disconnect("reply_disconnect", self, "on_reply_disconnect")

func on_reply_disconnect(from_slot:int, to:String, message:GraphNode):
	#TODO work this
	g.disconnect_node(message.name, from_slot, to, 0)

func act_on_file(id:int):
	#saving
	if id == 0:
		$File.mode = FileDialog.MODE_OPEN_FILE
		$File.connect("file_selected", self, "set_dialog_source", [], CONNECT_ONESHOT)
		$File.popup()
	elif id == 1:
		save_to_file(dialog_source)
	elif id == 2:
		$File.mode = FileDialog.MODE_SAVE_FILE
		$File.connect("file_selected", self, "save_to_file", [], CONNECT_ONESHOT)
		$File.popup()

func save_to_file(src):
	var f = File.new()
	var err = f.open(src, File.WRITE)
	if err != OK:
		print_debug("Saving to %s failed with error code %s" % [src, err])
	var dict = {}
	for key in dlg_nodes.keys():
		dict[key] = dlg_nodes[key].export_data()
	f.store_string(to_json(dict))