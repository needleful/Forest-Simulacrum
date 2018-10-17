extends KinematicBody

#constants
const speed = 4
const jump_vel = 3
const gravity = -10
const accel = 12
const deaccel = 24
onready var height_correction = $Body/Leggy.cast_to.length()/2
const height_rate = 8

onready var G = get_node("/root/global")
onready var ac_cast:RayCast = $head/camera/action_cast
onready var ac = get_node("/root/World/ui/action_context")

#variables
var velocity = Vector3(0,0,0)
var paused = false
var can_move = true
var cam_angle = 0
var saw_angle = Vector3(0,0,0)
var saw_x = 0
var in_air = false

#Camera Sway
const cam_speed_base = Vector3(1, 1, 1)
const cam_speed_shift = Vector3(.3, 0.3, .3)
const cam_span_base = Vector3(0.03, 0.05, .02) 
const cam_span_shift = Vector3(0.02, 0.03, .01)
onready var cam_base = $head/camera.translation

var rnd_cam_speed : Vector3
var rnd_cam_span : Vector3
var rnd_cam_timer = Vector3(0,0,0)

func _ready() -> void:
	ac_cast.add_exception($Body)
	rnd_cam_span = cam_span_base
	rnd_cam_speed = cam_speed_base
	set_process(true)
	set_physics_process(true)
	ac.bind_player(self)

func _physics_process(delta) -> void:
	if ac.enabled:
		if ac_cast.is_colliding():
			var c: Object = ac_cast.get_collider()
			if c.has_method("act") && c.active:
				if !ac.has_selected or c != ac.selected:
					ac.select(c)
			else:
				ac.deselect()
		else:
			ac.deselect()
	var direction: Vector2
	if can_move:
		direction = G.inp.get_direction()
	else:
		direction = Vector2(0,0)
	
	#: apply input
	var b = $head.global_transform.basis
	var vel = (b.z*direction.x + b.x*direction.y)*speed
	vel.y = velocity.y
	var a = accel if vel.dot(velocity) > 0 else deaccel
	
	velocity = velocity.linear_interpolate(vel,a*delta)
	
	var vcorrection : float = 0
	if $Body/Leggy.is_colliding():
		var rel_pos = $Body/Leggy.global_transform.origin-$Body/Leggy.get_collision_point()
		vcorrection = height_correction-rel_pos.y
	else:
		in_air = true
	if in_air:
		if velocity.y < 1 and vcorrection >= 0.1:
			in_air = false
		velocity.y += gravity*delta
	else:
		velocity.y = 0
		if G.inp.is_jumping():
			velocity.y = jump_vel
			in_air = true
	if $head/saw.visible:
		$head/saw.rotate_z(direction.y*delta*0.3+velocity.y*delta*0.2)
		saw_angle.z += direction.y*delta*0.3+velocity.y*delta*0.2
		$head/saw.rotate_x(velocity.y*delta*0.3)
		saw_x += velocity.y*delta*0.3
	
	velocity = move_and_slide(velocity,Vector3())
	if !in_air:
		translate(Vector3(0,vcorrection*delta*height_rate,0))

func _process(delta) -> void:
	look(G.inp.get_camera_movement(delta))
	#Random camera movement
	rnd_cam_timer += delta*rnd_cam_speed
	for i in range(3):
		if rnd_cam_timer[i] >= PI*2:
			rnd_cam_timer[i] = 0
			rnd_cam_span[i] = cam_span_base[i] + randf()*2*cam_span_shift[i]-cam_span_shift[i]
			rnd_cam_speed[i] = cam_speed_base[i] + randf()*2*cam_speed_shift[i]-cam_speed_shift[i]
	$head/camera.set_translation(cam_base +
		Vector3(sin(rnd_cam_timer.x)*rnd_cam_span.x, 
		sin(rnd_cam_timer.y)*rnd_cam_span.y, 
		sin(rnd_cam_timer.z))*rnd_cam_span.z)
	if $head/saw.visible:
		$head/saw.rotate_y(-saw_angle.y*delta*4)
		saw_angle.y -= saw_angle.y*delta*4
		$head/saw.rotate_z(-saw_angle.z*delta*5)
		saw_angle.z -= saw_angle.z*delta*5
		$head/saw.rotate_x(-saw_x*delta*3)
		saw_x -= saw_x*delta*3

func look(movement) -> void:
	$head.rotate_y(movement.x)
	var cam_delta = movement.y
	if cam_delta+cam_angle < PI/2 && cam_delta+cam_angle > -PI/2:
		$head/camera.rotate_x(cam_delta)
		cam_angle += cam_delta
		if $head/saw.visible:
			saw_angle.x = cam_delta/2
			$head/saw.rotate_x(cam_delta/2)
	if $head/saw.visible:
		saw_angle.y -= movement.x/3
		saw_angle.z += movement.x/5
		$head/saw.rotate_y(-movement.x/3)
		$head/saw.rotate_z(movement.x/5)

func get_camera()->Camera:
	var c:Camera = $head/camera
	return c

func reset_camera():
	$head.rotation_degrees.y = 0
	cam_angle = 0
	$head/camera.rotation_degrees.x = 0
	$head/saw.rotate_x(-saw_angle.x - saw_x)
	$head/saw.rotate_y(-saw_angle.y)
	$head/saw.rotate_z(-saw_angle.z)
	saw_angle = Vector3(0,0,0)
	saw_x = 0

func force_act(n:NodePath):
	var body = get_node(n).b
	ac.select(body)
	ac.act()

func show_saw(show):
	if show:
		$head/saw.show()
	else:
		$head/saw.hide()