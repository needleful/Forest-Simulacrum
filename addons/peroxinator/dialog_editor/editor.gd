extends Control

export(String, FILE, "*.json") var dialog_source setget set_dialog_source

const DialogNode = preload("dialog_node.tscn")

var dlg_nodes:Dictionary = {}

onready var g:GraphEdit = $split/graph
onready var e:PanelContainer = $split/edit

var edited_dlg:GraphNode

func _input(event):
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_RIGHT:
		var pos = g.get_local_mouse_position()
		var nd = DialogNode.instance()
		nd.id = nd.name+str(OS.get_ticks_msec())
		nd.offset = pos
		dlg_nodes[nd.id] = nd
		g.add_child(nd)

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
		g.add_child(dn)
		dlg_nodes[key] = dn
	for dn in dlg_nodes.values():
		var slot = 1
		for rep in dn.replies:
			if rep.next_id != "" && rep.next_id != null:
				econnect(dn.name, slot, dlg_nodes[rep.next_id].name, 0)
			slot += 1

func on_id_change(node, old_id, new_id):
	dlg_nodes.erase(old_id)
	dlg_nodes[new_id] = node

func econnect(from, fromslot, to, toslot):
	var from_node = g.get_node(from)
	if from_node.is_reply_connected(fromslot):
		edisconnect(from, fromslot, from_node.get_connection(fromslot), 0)
	from_node.connect_reply(g.get_node(to), to, fromslot)
	g.connect_node(from, fromslot, to, toslot)

func edisconnect(from, fromslot, to, toslot):
	var from_node = g.get_node(from)
	from_node.disconnect_reply(fromslot)
	g.disconnect_node(from, fromslot, to, toslot)

func eselect(val:GraphNode):
	e.select(val)

func edelete(id:String):
	g.remove_child(dlg_nodes[id])
	dlg_nodes.erase(id)

func act_on_file(id):
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