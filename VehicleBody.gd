extends VehicleBody

var wheel_contact = [false, false, false, false]
var car_jump: int = 2 # 0 is no jump, 1 is one jump, 2 is two jumps remaining
var wheels = []

# Member variables
const STEER_SPEED = 1
const STEER_LIMIT = 0.7

var steer_angle = 0
var steer_target = 0

var pitch_force = 400

var count = 0

export var engine_force_value = 400

func _ready():
	for node in get_children():
		if node is VehicleWheel:
			wheels.append(node)

func countertorque() -> Vector3:
	# FIXME reported angular velocity seems to reach infinity in some cases
	var vel_vec = get_angular_velocity()
	print(vel_vec)
	var magnitude = sqrt(pow(vel_vec.x, 2) + pow(vel_vec.y, 2) + pow(vel_vec.z, 2))
	if magnitude < 0.1:
		return Vector3(0, 0, 0)
	var ang_vel_sqr = vel_vec.x*vel_vec.x + vel_vec.y*vel_vec.y + vel_vec.z*vel_vec.z
	var ang_vel = sqrt(ang_vel_sqr)
	if ang_vel < 0.1:
		return Vector3(0, 0, 0)
	var ct_magnitude =  (-pitch_force / 2e4) * ang_vel_sqr
	var ct = Vector3(ct_magnitude*vel_vec.x/ang_vel, ct_magnitude*vel_vec.y/ang_vel, ct_magnitude*vel_vec.z/ang_vel)
	return ct

func torque(basis : Vector3, force : int) -> Vector3:
	var fx = basis.x * force
	var fy = basis.y * force
	var fz = basis.z * force
	return Vector3(fx, fy, fz)

func get_contact() -> bool:
	for wheel in wheels:
		if not wheel.is_in_contact():
			return false
	return true
		
func _physics_process(delta):
	var fwd_mps = transform.basis.xform_inv(linear_velocity).x
	
	if Input.is_action_just_pressed("car_jump") and car_jump > 0:
		apply_central_impulse(Vector3(0, 600, 0))
		car_jump -= 1
	
	var ct = countertorque()
	apply_torque_impulse(ct)
	print(delta)
	
	if Input.is_action_pressed("car_pitch_up") and car_jump < 2:
		apply_torque_impulse(-torque(get_global_transform().basis.x, pitch_force))
		
	if Input.is_action_pressed("car_pitch_down") and car_jump < 2:
		apply_torque_impulse(torque(get_global_transform().basis.x, pitch_force))
		
	if Input.is_action_pressed("car_yaw_left") and car_jump < 2:
		apply_torque_impulse(torque(get_global_transform().basis.y, pitch_force))
		
	if Input.is_action_pressed("car_yaw_right") and car_jump < 2:
		apply_torque_impulse(-torque(get_global_transform().basis.y, pitch_force))
	
	if Input.is_action_pressed("car_roll_right") and car_jump < 2:
		apply_torque_impulse(torque(get_global_transform().basis.z, pitch_force))
		
	if Input.is_action_pressed("car_roll_left") and car_jump < 2:
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
	
	if get_contact():
		car_jump = 2
