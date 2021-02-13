extends KinematicBody2D

enum {
	PACKET_GOOD,
	PACKET_BAD
}

var type: int

var points: int = 0

var rng_scale: RandomNumberGenerator = RandomNumberGenerator.new()
var rng_types: RandomNumberGenerator = RandomNumberGenerator.new()

var dieded: bool = false # Hi it's me le epic 9gag army
var is_hovering: bool = false
var is_pressed: bool = false
var is_grabbing: bool = false

var good_chance: int = 80


func _ready() -> void:
	call_deferred("_randomize")
	
	if get_tree().current_scene is Stage:
		good_chance = get_tree().current_scene.good_chance


func _process(delta: float) -> void:
	if position.y < -90:
		if get_tree().current_scene is Stage:
			if type == PACKET_GOOD:
				get_tree().current_scene.gauge += points
			else:
				get_tree().current_scene.gauge -= points
		queue_free()


func _physics_process(delta: float) -> void:
	if not is_grabbing and not dieded:
		if get_tree().current_scene is Stage:
			position.y -= get_tree().current_scene.speed * delta
		else:
			position.y -= 250 * delta


func _randomize() -> void:
	rng_scale.randomize()
	rng_types.randomize()
	
	# Randomize scale
	var f: float = stepify(rng_scale.randf_range(0.3, 1.0), 0.05)
	scale = Vector2(f, f)
	
	points = 16 * f
	
	print("points:" + str(points))
	
	# Randomize types (good packet or bad packet)
	var t_percent: int = rng_types.randi_range(1, 100)
	type = 1 if t_percent >= good_chance else 0
	
	# Temporary, will supply sprites later
	if type == PACKET_GOOD:
		modulate = Color.white
	else:
		modulate = Color.red
	
	print("percent: " + str(t_percent))
	print("actual: " + str(type))
	print()


func _check_if_outside() -> void:
	if get_tree().current_scene is Stage:
		var start_end: Vector2 = get_tree().current_scene.stream_width_start_end
		if position.x < start_end.x or position.x > start_end.y:
			dieded = true
			
			$Tween.interpolate_property(self, "scale", scale, Vector2(scale.x - 0.2, scale.y - 0.2), 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			$Tween.interpolate_property(self, "modulate:a", 1, 0, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			$Tween.start()
			
			yield($Tween, "tween_all_completed")
			
			queue_free()


func _input(event: InputEvent) -> void:
	if not dieded:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed and is_hovering:
					is_grabbing = true
				else:
					is_grabbing = false
					call_deferred("_check_if_outside")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_grabbing:
			var rel: Vector2 = event.relative
			position += rel


func _on_Packet_mouse_entered() -> void:
	is_hovering = true
	pass


func _on_Packet_mouse_exited() -> void:
	is_hovering = false
	pass
