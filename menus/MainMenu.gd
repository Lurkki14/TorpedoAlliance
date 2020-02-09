extends Control

func _load_scene(scene: String):
	var loaded_scene = load(scene).instance()
	add_child(loaded_scene)

func _change_scene(scene: String):
	queue_free()
	get_tree().change_scene(scene)

func _on_Play_pressed(button):
	_change_scene("res://Field.tscn")

func _on_Options_pressed():
	var scene = preload("res://menus/OptionsMenu.tscn").instance()
	add_child(scene)
	scene.get_node("PopupMenu").show()
