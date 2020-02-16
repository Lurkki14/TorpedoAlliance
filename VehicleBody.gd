extends VehicleBody
class_name RocketCar

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
var contact_ignore_time: float = CONTACT_IGNORE_MAX_TIME

var steer_angle = 0
var steer_target = 0

var pitch_force = 400
var ct_constant = pitch_force/64
var refspeed = 10
var max_downforce = 50

var dodge_active: bool
var dodge_basis: Vector3

var dodge_prev_vel: float
var dodge_time: float
var dodge_start_vec: Vector3
var dodge_delta_vec: Vector3
var dodge_prev_vec: Vector3

var count = 0

var wheels = []
var boost
var boost_exhausts = []

# Inputs
var boost_on: bool

var car_pitch_up: bool
var car_pitch_down: bool
var car_pitch_force: int

var car_yaw_left: bool
var car_yaw_right: bool
var car_yaw_force: int

var car_roll_left: bool
var car_roll_right: bool
var car_roll_force: int


export var engine_force_value = 400

func _ready():
	var boosts := SceneLoader.get_scenes("res://scenes/boosts/", "boosts")
	randomize()
	boost = boosts[randi() % boosts.size()]
	
	for node in get_children():
		if node is BoostExhaust:
			node.add_child(boost)
			boost_exhausts.append(node)
			
	dodge_active = false
	set_contact_monitor(true)
	set_max_contacts_reported(1)
	for node in get_children():
		if node is VehicleWheel:
			wheels.append(node)

func body_contact() -> bool:
	return get_colliding_bodies().size() > 0

func wheel_contact() -> bool:
	for wheel in wheels:
		if wheel.is_in_contact():
			return true
	return false

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

func _integrate_forces(state : PhysicsDirectBodyState):
	if dodge_active:
		dodge_time += state.step
		print(dodge_time)
		# Detect 360 rotation
		if dodge_time * 10 > 2 * PI:
			dodge_active = false
		else:
			state.set_angular_velocity(dodge_basis * 10)
			
func _input(event):
	var fwd_mps = transform.basis.xform_inv(linear_velocity).x
	
	if event.is_action_pressed("car_boost"):
		boost_on = true
	if event.is_action_released("car_boost"):
		boost_on = false
	
	if event.is_action_pressed("car_jump") and car_jump > 0:
		# Dodge jump
		if event.is_action_pressed("car_accelerate") and car_jump == 1:
			dodge_time = 0
			dodge_basis = get_global_transform().basis.x
			apply_central_impulse(get_global_transform().basis.z * pitch_force * 2)
			dodge_active = true
		else:
			if contact_ignore_time <= 0:
				contact_ignore_time = CONTACT_IGNORE_MAX_TIME
			contact_ignore_time = CONTACT_IGNORE_MAX_TIME
			var y_basis = get_global_transform().basis.y
			var force_vector = JUMP_FORCE * y_basis
			apply_central_impulse(force_vector)
		car_jump -= 1
		
	if event.is_action_pressed("car_pitch_up"):
		car_pitch_up = true
		car_pitch_force = event.get_action_strength("car_pitch_up")
	elif event.is_action_released("car_pitch_up"):
		car_pitch_up = false

		
	if event.is_action_pressed("car_pitch_down"):
		car_pitch_down = true
		car_pitch_force = event.get_action_strength("car_pitch_down")
	elif event.is_action_released("car_pitch_down"):
		car_pitch_down = false
		
	# Yaw is allowed if car is on its roof
	if event.is_action_pressed("car_yaw_left"):
		car_yaw_left = true
		car_yaw_force = event.get_action_strength("car_yaw_left")
	elif event.is_action_released("car_yaw_left"):
		car_yaw_left = false

	if event.is_action_pressed("car_yaw_right"):
		car_yaw_right = true
		car_yaw_force = event.get_action_strength("car_yaw_right")
	elif event.is_action_released("car_yaw_right"):
		car_yaw_right = false
		
	if event.is_action_pressed("car_roll_left"):
		car_roll_left = true
		car_roll_force = event.get_action_strength("car_roll_left")
	elif event.is_action_released("car_roll_left"):
		car_roll_left = false
		
	if event.is_action_pressed("car_roll_right"):
		car_roll_right = true
		car_roll_force = event.get_action_strength("car_roll_right")
	elif event.is_action_released("car_roll_right"):
		car_roll_right = false
	
	if event.is_action_pressed("car_steer_left"):
		steer_target = STEER_LIMIT * event.get_action_strength("car_steer_left")
	elif event.is_action_pressed("car_steer_right"):
		steer_target = -STEER_LIMIT * event.get_action_strength("car_steer_right")
	elif event.is_action_released("car_steer_left") or event.is_action_released("car_steer_right"):
		steer_target = 0
		
	if event.is_action_pressed("car_accelerate"):
		engine_force = engine_force_value * event.get_action_strength("car_accelerate")
	if event.is_action_released("car_accelerate"):
		engine_force = 0
	
	if event.is_action_pressed("car_reverse"):
		if (fwd_mps >= -1):
			engine_force = -engine_force_value * event.get_action_strength("car_reverse")
		else:
			brake = 80 * event.get_action_strength("car_reverse")
	elif event.is_action_released("car_reverse"):
		brake = 1
		engine_force = 0

func _physics_process(delta):
	#print(car_jump)
	#print(get_rotation())
	if boost_on:
		apply_central_impulse(boost(get_global_transform().basis.z))
		
	if not wheel_contact() and not body_contact():
		if car_pitch_up:
			apply_torque_impulse(-torque(get_global_transform().basis.x, pitch_force) * car_pitch_force)
			
		if car_pitch_down:
			apply_torque_impulse(torque(get_global_transform().basis.x, pitch_force) * car_pitch_force)
			
	if not wheel_contact():
		if car_yaw_left:
			apply_torque_impulse(torque(get_global_transform().basis.y, pitch_force) * car_yaw_force)
			
		if car_yaw_right:
			apply_torque_impulse(-torque(get_global_transform().basis.y, pitch_force) * car_yaw_force)
			
		if car_roll_left:
			apply_torque_impulse(-torque(get_global_transform().basis.z, pitch_force) * car_roll_force)
			
		if car_roll_right:
			apply_torque_impulse(torque(get_global_transform().basis.z, pitch_force) * car_roll_force)
		
	if contact_ignore_time > 0:
		contact_ignore_time -= delta
	
	if get_contact() and contact_ignore_time <= 0:
		apply_central_impulse(downforce(get_linear_velocity(), get_global_transform().basis.y))
		#print("downforce: ", downforce(get_linear_velocity(), get_global_transform().basis.y))
		car_jump = JUMP_LIMIT
		
	if not dodge_active:
		var ct = countertorque()
		apply_torque_impulse(ct)
	
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
	
