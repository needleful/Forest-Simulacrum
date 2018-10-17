extends Control

signal change_action_request(action_control)
signal focus_requested(action_control)

var action:String
var events:Array
var buttons:Array = []

var label_text setget set_label_text
var index_to_change:int
var G:Node

func set_action(action:String, events:Array, G:Node):
	self.G = G
	self.action = action
	self.events = events
	var action_count = 0
	for event in events:
		var name = Options.get_event_name(event, G.inp.controller_type)
		if name == "":
			name = "???"
		add_event_button(name, action_count, event)
		action_count += 1
	for i in range(action_count, 3):
		add_event_button(Options.unbound_event, i, null)

func add_event_button(name, index, event=null):
	var b = Button.new()
	b.size_flags_horizontal = SIZE_EXPAND_FILL
	b.text = name
	add_child(b)
	buttons.push_back(b)
	b.connect("pressed", self, "set_action_event", [index])
	b.connect("focus_entered", self, "request_focus")

func set_new_action(event:InputEvent):
	if event is InputEventJoypadMotion:
		if event.axis_value > 0:
			event.axis_value = 1
		else:
			event.axis_value = -1
	if events.size() <= index_to_change:
		index_to_change = events.size()
		events.push_back(event)
	else:
		var old = events[index_to_change]
		InputMap.action_erase_event(action, old)
	var new_name = Options.unbound_event
	
	var idx = find_existing_event(event)
	if idx >= 0 && idx != index_to_change:
		events.remove(index_to_change)
	else:
		events[index_to_change] = event
		InputMap.action_add_event(action, event)
		new_name = Options.get_event_name(event, G.inp.controller_type)
	buttons[index_to_change].text = new_name

func request_focus():
	emit_signal("focus_requested", self)

func set_action_event(index:int):
	index_to_change = index
	emit_signal("change_action_request", self)

func set_label_text(val):
	$Label.text = val

func find_existing_event(event:InputEvent)->int:
	var idx:int = -1
	for e in events:
		idx += 1
		if Options.get_event_name(e, G.inp.controller_type) == Options.get_event_name(event, G.inp.controller_type):
			return idx
	return -1