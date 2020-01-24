extends VehicleBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_max_contacts_reported(3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):

func _input(event):
	if event is InputEventKey and event.is_pressed() and char(event.scancode) == "W":
		engine_force = 300
	if event is InputEventKey and event.is_pressed() and char(event.scancode) == "A":
		steering = -0.8