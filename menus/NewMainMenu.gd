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

onready var main_view = $CanvasLayer/HBoxContainer
onready var car_editor = $CanvasLayer/CarEditor
onready var car = $Field/placeholder_car # This should be replaced as well as not hardcode a car to Field.tscn

func _ready():
	# Disable car controls
	disable_car_controls(self)

func _boost_changed(node) -> void:
	car.set_boost(node)

func _edit_car():
	main_view.set_visible(false)
	car_editor.set_visible(true)
	
	# Connect car_editor.item_changed to car.set_boost
	car_editor.connect("item_changed", self, "_boost_changed")
