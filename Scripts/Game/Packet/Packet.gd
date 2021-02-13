extends KinematicBody2D
signal passed

onready var shape = $Shape
onready var sprite = $Sprite
onready var sprite_glow = $Sprite/Glow
onready var point_disp = $PointDisp
onready var particle = $ExplosionParticle
onready var tween = $Tween

enum {
	PACKET_GOOD,
	PACKET_BAD
}

var type: int

var points: int = 0

var rng_size: RandomNumberGenerator = RandomNumberGenerator.new()
var rng_types: RandomNumberGenerator = RandomNumberGenerator.new()

var dieded: bool = false # Hi it's me le epic 9gag army
var is_grabbing: bool = false

var good_chance: int = 80


func _ready() -> void:
	call_deferred("_randomize")
	
	if get_tree().current_scene is Stage:
		good_chance = get_tree().current_scene.good_chance


func _process(delta: float) -> void:
#	if Input.is_action_just_pressed("ui_accept"):
#		call_deferred("_randomize")
	
	if position.y < -90:
		if type == PACKET_GOOD:
			emit_signal("passed", points / 5)
		else:
			emit_signal("passed", -(points / 2.5))
		queue_free()


func _physics_process(delta: float) -> void:
	if not is_grabbing and not dieded:
		if get_tree().current_scene is Stage:
			position.y -= get_tree().current_scene.speed * delta
		else:
			position.y -= 100 * delta


func _randomize() -> void:
	rng_size.randomize()
	rng_types.randomize()
	
	# Randomize size
	var s: float = rng_size.randi_range(84, 160)
	sprite.rect_size = Vector2(s, s)
	sprite.rect_position = Vector2(-s/2, -s/2)
	shape.shape.extents = Vector2(s/2, s/2)
	particle.emission_rect_extents = Vector2(s/2, s/2)
	
	var s_p: float = 1 + ((s - 84)) / (160 - 84)
	point_disp.rect_scale = Vector2(s_p ,s_p)
	
	points = stepify(64 * (s / 200), 2)
	
	# Randomize types (good packet or bad packet)
	var t_percent: int = rng_types.randi_range(1, 100)
	type = 1 if t_percent >= good_chance else 0
	
	# Temporary, will supply sprites later
	if type == PACKET_GOOD:
		sprite_glow.modulate = Color.green
		particle.modulate = Color.green
	else:
		sprite_glow.modulate = Color.red
		particle.modulate = Color.red
	
	point_disp.text = str(points)


func _check_if_outside() -> void:
	if get_tree().current_scene is Stage:
		var start_end: Vector2 = get_tree().current_scene.stream_width_start_end
		if position.x < start_end.x or position.x > start_end.y:
			dieded = true
			
			sprite.hide()
			point_disp.hide()
			particle.show()
			particle.emitting = true
			
			yield(get_tree().create_timer(particle.lifetime), "timeout")
			
			queue_free()



func _on_Packet_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("ui_touch") and not dieded:
		is_grabbing = true
		raise()


func _input(event: InputEvent) -> void:
	if is_grabbing:
		if event.is_action_released("ui_touch"):
			is_grabbing = false
			call_deferred("_check_if_outside")
		
		if is_grabbing and event is InputEventMouseMotion:
			position += event.relative
