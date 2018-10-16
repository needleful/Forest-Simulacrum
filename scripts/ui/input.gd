extends Node

#Settings
var sensitivity:Vector2 = Vector2(1,1)
var cam_acceleration:float = 24
var mouse_sns = Vector2(1,1)
var cam_invert:Vector2 = Vector2(-1,1)

#Constants
const mouse_factor:Vector2 = Vector2(0.007, 0.007)
const analog_sns:Vector2 = Vector2(0.05, 0.05)

#Aggregate Input
var cam_delta:Vector2 = Vector2(0,0)
var cam_velocity:Vector2 = Vector2(0,0)

class AnalogUiInputStatus:
	var clicks:int = 0
	var time_held:float = 0.0
	var last_click_time:float = 0.0
	var action_name:String
	var digital_name:String
	
	func _init(name):
		action_name = name
		digital_name = action_name.replace("_analog", "")
		
	func should_click()->bool:
		if clicks > 100:
			return false
		var to_click = false
		var now = OS.get_ticks_msec()
		if clicks == 0:
			to_click = true
		else:
			var required_delta
			match clicks:
				1,2:
					required_delta = 600
				3,4,5:
					required_delta = 200
				_:
					required_delta = 90
				
			if now-last_click_time > required_delta:
				to_click = true
		if to_click:
			clicks += 1
			last_click_time = now
			print("Click ",digital_name, clicks)
		return to_click
	
	func reset():
		clicks = 0

var to_reset = false
var dt:float=  0

var analog_ui_dirs = [
	AnalogUiInputStatus.new("ui_up_analog"),
	AnalogUiInputStatus.new("ui_down_analog"),
	AnalogUiInputStatus.new("ui_left_analog"),
	AnalogUiInputStatus.new("ui_right_analog"),
]

onready var G = get_node("/root/global")
onready var action_context = get_parent().get_node("action_context")
onready var ui:Control = get_parent()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process(true)

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		cam_delta += event.relative*mouse_factor*mouse_sns
	elif event.is_action_pressed("gm_act") && action_context.has_selected:
		action_context.act()
	var c = event is InputEventJoypadButton or event is InputEventJoypadMotion
	if not event is InputEventAction and G.using_controller != c:
		G.using_controller = c
		if c:
			var s = Input.get_joy_name(event.device)
			print("New Input Device: ",s)
			G.controller_name = s

func _process(delta):
	process_analog_input(delta)

func process_analog_input(delta):
	var reset_actions = true
	for dir in analog_ui_dirs:
		if Input.get_action_strength(dir.action_name) > 0.5 and dir.should_click():
			var a = InputEventAction.new()
			a.action = dir.digital_name
			a.pressed = true
			Input.parse_input_event(a)
			var a2 = InputEventAction.new()
			a2.action = dir.digital_name
			a2.pressed = false
			Input.parse_input_event(a2)
			to_reset = true
		reset_actions = reset_actions and Input.get_action_strength(dir.action_name) < 0.05
			
	if to_reset and reset_actions:
		print("\t reset")
		for dir in analog_ui_dirs:
			dir.reset()
		to_reset = false

func get_camera_movement(delta)->Vector2:
	var l = Input.get_action_strength("cam_left")
	var r = Input.get_action_strength("cam_right")
	var f = Input.get_action_strength("cam_up")
	var b = Input.get_action_strength("cam_down")
	var cam: Vector2 = Vector2(inp(r-l), inp(b-f))
	cam_velocity = cam_velocity.linear_interpolate(cam, cam_acceleration*delta)
	$analog/raw.rect_position = Vector2(48,48) + 60*Vector2(r-l, b-f)
	cam = cam_velocity
	cam *= sensitivity
	$analog/processed.rect_position = Vector2(48,48) + 60*cam
	cam *= analog_sns
	cam += cam_delta
	cam *= cam_invert
	cam_delta.x = 0
	cam_delta.y = 0
	return cam

func inp(x:float)->float:
	return sign(x)*pow(abs(x), 0.5)

func is_jumping()->bool:
	return Input.is_action_just_pressed("mv_jump")

func get_direction(basis:Basis)->Vector3:
	var l = Input.get_action_strength("mv_left")
	var r = Input.get_action_strength("mv_right")
	var f = Input.get_action_strength("mv_forward")
	var b = Input.get_action_strength("mv_backward")
	return basis.x*(l-r)+basis.z*(f-b)