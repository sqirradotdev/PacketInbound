extends Control


export (float, 2, 10)    var duration             = 2
export (float, 0.25, 1)  var fade_duration        = 0.75
export (float, 1)        var dolly_amount : float = 0.3


func _ready() -> void:
	var clear_color : Color = ProjectSettings.get("application/boot_splash/bg_color")
	VisualServer.set_default_clear_color(clear_color)
	
	var timer := Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", self, "_on_splash_finished")
	
	var tween = Tween.new()
	add_child(tween)
	
	tween.interpolate_property(self, "modulate:a", 0, 1, fade_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate:a", 1, 0, fade_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT, duration - fade_duration)
	tween.start()
	
	timer.start()


func _process(delta: float) -> void:
	if dolly_amount > 0:
		$TeamLogo.scale += Vector2(dolly_amount / 20, dolly_amount / 20) * delta


func _on_splash_finished() -> void:
	SceneLoader.start_load("res://Scripts/Menu/Menu.tscn", true)
	queue_free()
