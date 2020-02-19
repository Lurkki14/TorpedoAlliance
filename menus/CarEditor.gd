extends Control

signal item_changed(node)

onready var option_button: OptionButton = $BoostSelection

var boosts: Array = []

func _emit_node(index: int) -> void:
	#print(boosts[index])
	emit_signal("item_changed", boosts[index])

# Called when the node enters the scene tree for the first time.
func _ready():
	for boost in SceneLoader.get_scenes("res://scenes/boosts/", "boosts"):
		boosts.append(boost)
		option_button.add_item(boost.name)
		
	option_button.connect("item_selected", self, "_emit_node")
