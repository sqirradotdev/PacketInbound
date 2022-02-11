extends Control


func _ready() -> void:
	pass


func _on_ResumeBtn_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_touch"):
		_unpause()


func _on_MainMenuBtn_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_touch"):
		SceneLoader.start_load("res://Scripts/Menu/Menu.tscn", true)
		yield(SceneLoader, "done")
		_unpause()
		get_parent().queue_free()


func _unpause():
	get_tree().paused = false
	self.hide()
