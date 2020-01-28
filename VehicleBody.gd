extends VehicleBody

var wheel_contact = [false, false, false, false]
var car_jump: int = 2 # 0 is no jump, 1 is one jump, 2 is two jumps remaining

# Member variables
const STEER_SPEED = 1
const STEER_LIMIT = 0.7

var steer_angle = 0
var steer_target = 0

var count = 0

export var engine_force_value = 400

func get_contact():
	for element in wheel_contact:
		if not element:
			return false
		return true
		
func _physics_process(delta):
	var fwd_mps = transform.basis.xform_inv(linear_velocity).x
	
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
