extends Node

var action_context

var cam_invert:Vector2 = Vector2(-1,1)
var cam_delta:Vector2 = Vector2(0,0)
const mouse_sns:Vector2 = Vector2(0.007, 0.007)
const analog_sns:Vector2 = Vector2(0.06, 0.04)

func _ready():
	action_context = get_parent().get_node("action_context")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		cam_delta += event.relative*mouse_sns
	elif event.is_action_pressed("gm_act") && action_context.has_selected:
		action_context.act()
	elif event.is_action_pressed("debug_event_phase_increment"):
		get_node("/root/global").register_event("build_house")

func get_camera_movement()->Vector2:
	var l = Input.get_action_strength("cam_left")
	var r = Input.get_action_strength("cam_right")
	var f = Input.get_action_strength("cam_up")
	var b = Input.get_action_strength("cam_down")
	var cam: Vector2 = Vector2((r-l), (b-f))
	if cam.length_squared() > 1:
		cam = cam.normalized()
	cam *= analog_sns
	cam += cam_delta
	cam *= cam_invert
	cam_delta.x = 0
	cam_delta.y = 0
	return cam

func is_jumping()->bool:
	return Input.is_action_just_pressed("mv_jump")

func get_direction(basis:Basis)->Vector3:
	var l = Input.get_action_strength("mv_left")
	var r = Input.get_action_strength("mv_right")
	var f = Input.get_action_strength("mv_forward")
	var b = Input.get_action_strength("mv_backward")
	return basis.x*(l-r)+basis.z*(f-b)