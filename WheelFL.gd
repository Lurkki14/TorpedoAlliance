extends VehicleWheel

onready var body = get_node("../../placeholder_car")

func _physics_process(delta):
	if is_in_contact():
		body.wheel_contact.insert(2, true)
	else:
		body.wheel_contact.insert(2, false)
