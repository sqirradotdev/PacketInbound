extends Node

const interact_verb: Dictionary = {
	"desktop": "Click",
	"mobile" : "Tap"
}


var played_once: bool = false

func _ready() -> void:
	print("Global singleton!")
	print("Played once: " + str(played_once) + "\n")
