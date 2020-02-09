extends CPUParticles

func _ready():
	set_emitting(false)
	
func _process(delta):
	if Input.is_action_pressed("car_boost"):
		set_emitting(true)
	else:
		set_emitting(false)
