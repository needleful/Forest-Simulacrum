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
var in_air = false

#Camera Sway
const cam_speed_base = Vector3(.8, .9, .8)
const cam_speed_shift = Vector3(.3, 0.3, .3)
const cam_span_base = Vector3(0.04, 0.06, .04) 
const cam_span_shift = Vector3(0.05, 0.04, .03)

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
	if ac.enabled and ac_cast.is_colliding():
		var c: Object = ac_cast.get_collider()
		if (!ac.has_selected or c != ac.selected) and c.has_method("act"):
			ac.select(c)
	elif ac.enabled:
		ac.deselect()
	var direction: Vector3 
	if can_move:
		direction = G.inp.get_direction($head.global_transform.basis)
	else:
		direction = Vector3(0,0,0)

	#: apply input
	direction*=speed
	direction.y = velocity.y
	var a = accel if direction.dot(velocity) > 0 else deaccel
	
	velocity = velocity.linear_interpolate(direction,a*delta)
	velocity.y = direction.y
	
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
	velocity = move_and_slide(velocity,Vector3())
	if !in_air:
		translate(Vector3(0,vcorrection*delta*height_rate,0))


func _process(delta) -> void:
	look(G.inp.get_camera_movement())
	#Random camera movement
	rnd_cam_timer += delta*rnd_cam_speed
	for i in range(3):
		if rnd_cam_timer[i] >= PI*2:
			rnd_cam_timer[i] = 0
			rnd_cam_span[i] = cam_span_base[i] + randf()*2*cam_span_shift[i]-cam_span_shift[i]
			rnd_cam_speed[i] = cam_speed_base[i] + randf()*2*cam_speed_shift[i]-cam_speed_shift[i]
	$head.set_translation(
		Vector3(sin(rnd_cam_timer.x)*rnd_cam_span.x, 
		sin(rnd_cam_timer.y)*rnd_cam_span.y, 
		sin(rnd_cam_timer.z))*rnd_cam_span.z)

func look(movement) -> void:
	$head.rotate_y(movement.x)
	var cam_delta = movement.y
	if cam_delta+cam_angle < PI/2 && cam_delta+cam_angle > -PI/2:
		$head/camera.rotate_x(cam_delta)
		cam_angle += cam_delta

func reset_camera():
	$head.rotation_degrees.y = 0
	cam_angle = 0
	$head/camera.rotation_degrees.x = 0