extends Control

onready var cl_label = $Clickanywhere

var can_transition: bool = false


func _ready() -> void:
	$Credits.hide()
	
	var text = " anywhere to play!"
	
	if OS.has_feature("mobile"):
		cl_label.text = Global.interact_verb.get("mobile") + text
	
	$BlackOverlay.show()
	$Tween.interpolate_property($BlackOverlay, "color:a", 1, 0, 0.75)
	$Tween.interpolate_property($BlackOverlay, "visible", true, false, 0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.75)
	$Tween.start()
	
	yield(get_tree().create_timer(0.7), "timeout")
	can_transition = true


func _on_ClickRegion_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_touch") and can_transition:
		$CreditsBtn.disabled = true
		call_deferred("_transition")


func _transition() -> void:
	$Music.stop()
	$StartGameSound.play()
	
	$Tween.stop_all()
	
	$BlackOverlay.color.a = 0
	$BlackOverlay.show()
	
	$WhiteOverlay.show()
	$Tween.interpolate_property($WhiteOverlay, "color:a", 1, 0, 0.7)
	$Tween.interpolate_method(self, "_set_shader_strength", 0, 3, 1, Tween.TRANS_CUBIC, Tween.EASE_IN, 0.25)
	$Tween.interpolate_property($BlackOverlay, "color:a", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.1)
	$Tween.start()
	$RadialBlurFilter.show()
	
	yield(get_tree().create_timer(3), "timeout")
	
	SceneLoader.start_load("res://Scripts/Game/Stage.tscn", true)
	yield(SceneLoader, "done")
	queue_free()


func _set_shader_strength(amount: float) -> void:
	$RadialBlurFilter.material.set_shader_param("blur", amount)


func _on_CreditsBtn_pressed() -> void:
	$Credits.show()


func _on_BackBtn_pressed() -> void:
	$Credits.hide()
