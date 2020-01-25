extends VehicleBody

func rotation(event : InputEventKey):
	match char(event.scancode):
		"A": return 0.8
		"D": return -0.8
	return 0

func force(event : InputEventKey):
	match char(event.scancode):
		"W": return 400
		"S": return -400
	return 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_engine_force(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("engine force: ", get_engine_force(), " steering: ", get_steering())

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if rotation(event) != NAN:
			print("setting steering to ", rotation(event))
			set_steering(rotation(event))
		
		if force(event) != NAN:
			print("setting force to ", force(event))
			set_engine_force(force(event))
			
	if event is InputEventKey and not event.is_pressed():
		set_steering(0)
		set_engine_force(0)