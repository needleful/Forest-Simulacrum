extends Node

var action_context

var sensitivity:Vector2 = Vector2(1,1)
var mouse_sns = Vector2(1,1)

var cam_invert:Vector2 = Vector2(-1,1)
var cam_delta:Vector2 = Vector2(0,0)
const mouse_factor:Vector2 = Vector2(0.007, 0.007)
const analog_sns:Vector2 = Vector2(0.05, 0.05)

onready var G = get_node("/root/global")

func _ready():
	action_context = get_parent().get_node("action_context")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		cam_delta += event.relative*mouse_factor*mouse_sns
	elif event.is_action_pressed("gm_act") && action_context.has_selected:
		action_context.act()
	var c = event is InputEventJoypadButton or event is InputEventJoypadMotion
	if G.using_controller != c:
		G.using_controller = c
		if c:
			var s = Input.get_joy_name(event.device)
			print("New Input Device: ",s)
			G.controller_name = s

func get_camera_movement()->Vector2:
	var l = Input.get_action_strength("cam_left")
	var r = Input.get_action_strength("cam_right")
	var f = Input.get_action_strength("cam_up")
	var b = Input.get_action_strength("cam_down")
	var cam: Vector2 = Vector2(inp(r-l), inp(b-f))
	$analog/raw.rect_position = Vector2(48,48) + 60*Vector2(r-l, b-f)
#	cam.x += sign(cam.x) *abs(cam.x*cam.y)
#	cam.y += sign(cam.y) *abs(cam.x*cam.y)
	cam *= sensitivity
	$analog/processed.rect_position = Vector2(48,48) + 60*cam
	cam *= analog_sns
	cam += cam_delta
	cam *= cam_invert
	cam_delta.x = 0
	cam_delta.y = 0
	return cam

func inp(x:float)->float:
	return sign(x)*pow(abs(x), 1.2)

func is_jumping()->bool:
	return Input.is_action_just_pressed("mv_jump")

func get_direction(basis:Basis)->Vector3:
	var l = Input.get_action_strength("mv_left")
	var r = Input.get_action_strength("mv_right")
	var f = Input.get_action_strength("mv_forward")
	var b = Input.get_action_strength("mv_backward")
	return basis.x*(l-r)+basis.z*(f-b)