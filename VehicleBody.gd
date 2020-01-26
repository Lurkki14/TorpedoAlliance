extends VehicleBody

# Member variables
const STEER_SPEED = 1
const STEER_LIMIT = 0.7

var steer_angle = 0
var steer_target = 0

var wheel_contact_bl
var wheel_contact_fr
var wheel_contact_fl
var wheel_contact_br

var count = 0

export var engine_force_value = 400

func _on_WheelBL_wheel_contact_bl(contact):
	wheel_contact_bl = contact

func _on_WheelFR_wheel_contact_fr(contact):
	wheel_contact_fr = contact

func _on_WheelFL_wheel_contact_fl(contact):
	wheel_contact_fl = contact

func _on_WheelBR_wheel_contact_br(contact):
	wheel_contact_br = contact

func _ready():
	var wheel_bl_node = get_node("WheelBL")
	var wheel_fr_node = get_node("WheelFR")
	var wheel_fl_node = get_node("WheelFL")
	var wheel_br_node = get_node("WheelBR")
	wheel_bl_node.connect("wheel_contact_bl", self, "_on_WheelBL_wheel_contact_bl")
	wheel_fr_node.connect("wheel_contact_fr", self, "_on_WheelFR_wheel_contact_fr")
	wheel_fl_node.connect("wheel_contact_fl", self, "_on_WheelFL_wheel_contact_fl")
	wheel_br_node.connect("wheel_contact_br", self, "_on_WheelBR_wheel_contact_br")
	
func _physics_process(delta):
	var fwd_mps = transform.basis.xform_inv(linear_velocity).x
	
	if Input.is_action_pressed("ui_left"):
		steer_target = STEER_LIMIT
	elif Input.is_action_pressed("ui_right"):
		steer_target = -STEER_LIMIT
	else:
		steer_target = 0
	
	if Input.is_action_pressed("ui_up"):
		engine_force = engine_force_value
	else:
		engine_force = 0
	
	if Input.is_action_pressed("ui_down"):
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
	
	if wheel_contact_bl and wheel_contact_br and wheel_contact_fl and wheel_contact_fr:
		print("all4wheel ", count)
