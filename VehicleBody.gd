extends VehicleBody

const STEER_SPEED = 1
const STEER_LIMIT = 0.7

const JUMP_FORCE: int = 600
const JUMP_LIMIT: int = 2

const CONTACT_IGNORE_MAX_TIME: float = 5.0/60.0

const BOOST_FORCE = 50
const MAX_VELOCITY = 20
# 0 is no jump, 1 is one jump, 2 is two jumps remaining
var car_jump: int = JUMP_LIMIT
var reset_jump: bool
var wheels = []
var contact_ignore_time: float = CONTACT_IGNORE_MAX_TIME

var steer_angle = 0
var steer_target = 0

var pitch_force = 400
var ct_constant = pitch_force/64
var refspeed = 10
var max_downforce = 50

var count = 0

export var engine_force_value = 400

func _ready():
	for node in get_children():
		if node is VehicleWheel:
			wheels.append(node)

func sig(x : float) -> float:
	return (2 / (1 + exp(-x))) - 1

func downforce(velocity : Vector3, basis : Vector3) -> Vector3:
	var downforce_prc = sig(velocity.length() / refspeed)
	var downforce_mult = -max_downforce * downforce_prc
	return basis * downforce_mult

func boost(basis : Vector3) -> Vector3:
	if get_linear_velocity().length() > MAX_VELOCITY:
		return Vector3(0, 0, 0)
	return basis * BOOST_FORCE

func countertorque() -> Vector3:
	var vel_vec = get_angular_velocity()
	return -ct_constant * vel_vec.length_squared() * vel_vec.normalized()

# Used for pitch, yaw and roll torque
func torque(basis : Vector3, force : int) -> Vector3:
	return force * basis

func get_contact() -> bool:
	for wheel in wheels:
		if not wheel.is_in_contact():
			return false
	return true

func _physics_process(delta):
	print(car_jump)
	if contact_ignore_time > 0:
		contact_ignore_time -= delta
	
	if get_contact() and contact_ignore_time <= 0:
		apply_central_impulse(downforce(get_linear_velocity(), get_global_transform().basis.y))
		#print("downforce: ", downforce(get_linear_velocity(), get_global_transform().basis.y))
		car_jump = JUMP_LIMIT
		
	var fwd_mps = transform.basis.xform_inv(linear_velocity).x
	
	if Input.is_action_pressed("car_boost"):
		print(boost(get_global_transform().basis.z))
		apply_central_impulse(boost(get_global_transform().basis.z))
	
	if Input.is_action_just_pressed("car_jump") and car_jump > 0:
		if contact_ignore_time <= 0:
			contact_ignore_time = CONTACT_IGNORE_MAX_TIME
		contact_ignore_time = CONTACT_IGNORE_MAX_TIME
		var y_basis = get_global_transform().basis.y
		var force_vector = JUMP_FORCE * y_basis
		apply_central_impulse(force_vector)
		car_jump -= 1
	
	var ct = countertorque()
	apply_torque_impulse(ct)
	
	if Input.is_action_pressed("car_pitch_up") and car_jump < JUMP_LIMIT:
		apply_torque_impulse(-torque(get_global_transform().basis.x, pitch_force))
		
	if Input.is_action_pressed("car_pitch_down") and car_jump < JUMP_LIMIT:
		apply_torque_impulse(torque(get_global_transform().basis.x, pitch_force))
		
	if Input.is_action_pressed("car_yaw_left") and car_jump < JUMP_LIMIT:
		apply_torque_impulse(torque(get_global_transform().basis.y, pitch_force))
		
	if Input.is_action_pressed("car_yaw_right") and car_jump < JUMP_LIMIT:
		apply_torque_impulse(-torque(get_global_transform().basis.y, pitch_force))
	
	if Input.is_action_pressed("car_roll_right") and car_jump < JUMP_LIMIT:
		apply_torque_impulse(torque(get_global_transform().basis.z, pitch_force))
		
	if Input.is_action_pressed("car_roll_left") and car_jump < JUMP_LIMIT:
		apply_torque_impulse(-torque(get_global_transform().basis.z, pitch_force))
	
	if Input.is_action_pressed("car_steer_left"):
		steer_target = STEER_LIMIT
	elif Input.is_action_pressed("car_steer_right"):
		steer_target = -STEER_LIMIT
	else:
		steer_target = 0
	
	if Input.is_action_pressed("car_accelerate"):
		engine_force = engine_force_value
	else:
		engine_force = 0
	
	if Input.is_action_pressed("car_reverse"):
		if (fwd_mps >= -1):
			engine_force = -engine_force_value
		else:
			brake = 80
	else:
		brake = 0.1
	
	if steer_target < steer_angle:
		steer_angle -= STEER_SPEED * delta
		if steer_target > steer_angle:
			steer_angle = steer_target
	elif steer_target > steer_angle:
		steer_angle += STEER_SPEED * delta
		if steer_target < steer_angle:
			steer_angle = steer_target
	
	steering = steer_angle
	
	count = count + delta
	
