extends Control


func _ready() -> void:
	VisualServer.set_default_clear_color(Color.black)
	SceneLoader.start_load("res://Scripts/Splash/Splash.tscn", true)
	queue_free()
