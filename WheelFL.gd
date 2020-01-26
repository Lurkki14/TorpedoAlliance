extends VehicleWheel

signal wheel_contact_fl
var contact

func _physics_process(delta):
	if is_in_contact():
		contact = true
	else:
		contact = false
	emit_signal("wheel_contact_fl", contact)
