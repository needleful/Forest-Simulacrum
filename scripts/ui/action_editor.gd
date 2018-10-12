extends Control

signal change_action_request(action_control)
signal focus_requested(action_control)

var action:String
var events:Array
var buttons:Array = []

var label_text setget set_label_text
var index_to_change:int

const unbound_event = "---"

func set_action(action:String, events:Array):
	self.action = action
	self.events = events
	var action_count = 0
	for event in events:
		var name = get_event_name(event)
		if name == "":
			continue
		add_event_button(name, action_count, event)
		action_count += 1
	for i in range(action_count, 3):
		add_event_button(unbound_event, i, null)

func add_event_button(name, index, event=null):
	var b = Button.new()
	b.size_flags_horizontal = SIZE_EXPAND_FILL
	b.text = name
	add_child(b)
	buttons.push_back(b)
	b.connect("pressed", self, "set_action_event", [index])
	b.connect("focus_entered", self, "request_focus")

func set_new_action(event:InputEvent):
	print("Remapping Control")
	if event is InputEventJoypadMotion:
		if event.axis_value > 0:
			event.axis_value = 1
		else:
			event.axis_value = -1
	if events.find(event) >= 0:
		return
	if events.size() <= index_to_change:
		index_to_change = events.size()
		events.push_back(event)
	else:
		var old = events[index_to_change]
		InputMap.action_erase_event(action, old)
	InputMap.action_add_event(action, event)
	events.push_back(event)
	buttons[index_to_change].text = get_event_name(event)

func request_focus():
	emit_signal("focus_requested", self)

func set_action_event(index:int):
	index_to_change = index
	emit_signal("change_action_request", self)

func get_event_name(event:InputEvent) -> String:
	if event is InputEventJoypadMotion:
		var name = ""
		match(event.axis):
			JOY_AXIS_0:
				name = "Left X"
			JOY_AXIS_1:
				name= "Left Y"
			JOY_AXIS_2:
				name="Right X"
			JOY_AXIS_3:
				name="Right Y"
			JOY_AXIS_4:
				name="Axis 4"
			JOY_AXIS_5:
				name="Axis 5"
			JOY_AXIS_6:
				name="Axis 6"
			JOY_AXIS_7:
				name="Axis 7"
			JOY_AXIS_8:
				name="Axis 8"
			JOY_AXIS_9:
				name="Axis 9"
		if event.axis_value > 0:
			name += "+"
		else:
			name += "-"
		return name
	elif event is InputEventJoypadButton:
		return "Joy "+str(event.button_index)
	elif event is InputEventMouseButton:
		var m = ""
		match(event.button_index):
			BUTTON_LEFT:
				m = "Left "
			BUTTON_RIGHT:
				m = "Right "
			BUTTON_MIDDLE:
				m = "Middle "
		return m + "Mouse"
	else:
		return event.as_text()

func set_label_text(val):
	$Label.text = val