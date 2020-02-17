extends Spatial

func disable_car_controls(node: Node) -> void:
	for n in node.get_children():
		if n.get_child_count() > 0:
			if n is VehicleBody:
				print(n)
				n.set_process_input(false)
			disable_car_controls(n)
		elif n is VehicleBody:
			print(n)
			n.set_process_input(false)

func _ready():
	# Disable car controls
	disable_car_controls(self)
