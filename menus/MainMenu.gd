extends Control

func _change_scene(scene):
	queue_free()
	get_tree().change_scene(scene)

func _on_Play_pressed(button):
	_change_scene("res://Field.tscn")
