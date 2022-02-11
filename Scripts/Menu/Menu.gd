extends Control

var can_transition: bool = false


func _ready() -> void:
	$Credits.hide()
	
	$BlackOverlay.show()
	$Tween.interpolate_property($BlackOverlay, "color:a", 1, 0, 0.75)
	$Tween.interpolate_property($BlackOverlay, "visible", true, false, 0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.75)
	$Tween.start()
	
	yield(get_tree().create_timer(0.7), "timeout")
	can_transition = true


func _on_PlayBtn_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_touch") and can_transition:
		$SettingsBtn.disabled = true
		$CreditsBtn.disabled = true
		call_deferred("_transition")


func _transition() -> void:
	$Music.stop()
	$StartGameSound.play()
	
	$Tween.stop_all()
	
	$BlackOverlay.color.a = 0
	$BlackOverlay.show()
	$WhiteOverlay.show()
	
	rect_pivot_offset = Vector2(rect_size.x / 2, rect_size.y / 2)
	
	$Tween.interpolate_property($WhiteOverlay, "color:a", 1, 0, 0.7)
	$Tween.interpolate_method(self, "_set_shader_strength", 0, -0.2, 1, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", Vector2(1, 1), Vector2(3.2, 3.2), 1, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property($BlackOverlay, "color:a", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.7)
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
