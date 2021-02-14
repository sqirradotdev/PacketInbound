extends Control
class_name Stage

signal destroy_all_packets

onready var spawner = $Spawner
onready var gauge_display = $GaugeDisplay
onready var time_display = $TimeDisplay
onready var stream_area = $StreamArea
onready var pass_gradient = $PassGradient
onready var glitch_filter = $GlitchFilter
onready var color_flash = $ColorFlash
onready var passed_particle = $PassedParticle
onready var music = $Music
onready var game_over_screen = $GameOverScreen
onready var game_over_sound = $GameOverSound
onready var glitch_start = $GlitchStart
onready var passed_sound_good = $PassedSoundGood
onready var passed_sound_bad = $PassedSoundBad
onready var tutorial_screen = $Tutorial
onready var tutorial_screen_rtl = $Tutorial/RichTextLabel
onready var tween = $Tween
onready var tween2 = $Tween2

var tutorial: bool = false
var can_skip_tutorial: bool = false

var active: bool = false

var good_chance: int = 60
var good_chance_min: int = 38
var speed: float = 250
var speed_multiplier: float = 1
var speed_multiplied: float
var gauge_deductor: float = 4

var gauge: float = 100

var time_start: int
var time_now: int
var elapsed: int = 0
var prev_elapsed: int = -1

var stream_width_start_end: Vector2


func _ready() -> void:
	stream_width_start_end = Vector2(stream_area.rect_position.x, stream_area.rect_position.x + stream_area.rect_size.x)
	game_over_screen.hide()
	tutorial_screen.hide()
	
	var p_dup = passed_particle.duplicate()
	passed_particle.queue_free()
	passed_particle = p_dup
	
	glitch_start.play()
	glitch_filter.show()
	tween.interpolate_method(self, "_set_glitch_amount", 0.7, 0, 0.25)
	tween.interpolate_property(glitch_filter, "visible", true, false, 0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.25)
	tween.start()
	
	yield(get_tree().create_timer(0.25), "timeout")
	
	music.play()
	
	if not Global.played_once:
		Global.played_once = true
		call_deferred("_init_tutorial")
	else:
		call_deferred("_start")


func _process(delta: float) -> void:
	speed_multiplied = speed * speed_multiplier
	
	if active:
		if not speed > 430:
			speed += 3.0 * delta
		else:
			speed = 450
		
		gauge_deductor += 0.003 * delta
		gauge -= gauge_deductor * delta
		gauge = clamp(gauge, -1, 100)
	
		time_now = OS.get_unix_time()
		elapsed = time_now - time_start
		var elapsed_str = format_second(elapsed)
		
		# Difficulty step every 50 seconds
		if elapsed > 1 and not elapsed % 10 and not elapsed == prev_elapsed and good_chance > good_chance_min:
			good_chance -= 3
			good_chance = clamp(good_chance, good_chance_min, 100)
			prev_elapsed = elapsed
		
		gauge_display.modulate.r = clamp(1 - (gauge - 50) / (100 - 50), 0, 1)
		gauge_display.modulate.g = 1.0 - clamp(1 - (gauge - 0) / (50 - 0), 0, 1)
		gauge_display.text = str(ceil(gauge))
		
		time_display.text = "UPTIME: " + elapsed_str
		
		if gauge < 0:
			call_deferred("_game_over")
		
		# Debug purposes
		$Label.text = "Gauge: " + str(gauge) + "\nTime: " + elapsed_str + "\nChance: " + str(100 - good_chance) + "%\nSpeed: " + str(speed)
	elif tutorial:
		if Input.is_action_just_pressed("ui_touch") and can_skip_tutorial:
			call_deferred("_skip_tutorial")


func format_second(second: int) -> String:
	var minutes = second / 60
	var seconds = second % 60
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)


func _init_tutorial() -> void:
	tutorial = true
	tutorial_screen.modulate.a = 0
	tutorial_screen.show()
	
	var text: String = " anywhere to continue."
	var f_text: String
	if OS.has_feature("mobile"):
		f_text = Global.interact_verb.get("mobile") + text
	else:
		f_text = Global.interact_verb.get("desktop") + text
	
	tutorial_screen_rtl.bbcode_text = tutorial_screen_rtl.bbcode_text.format({"ca": f_text})
	
	tween.interpolate_property(tutorial_screen, "modulate:a", 0, 1, 0.6)
	tween.start()
	
	yield(get_tree().create_timer(0.8), "timeout")
	
	can_skip_tutorial = true


func _skip_tutorial() -> void:
	tutorial = false
	
	tween.interpolate_property(tutorial_screen, "modulate:a", 1, 0, 0.6)
	tween.start()
	
	yield(get_tree().create_timer(0.8), "timeout")
	
	can_skip_tutorial = false
	call_deferred("_start")
	tutorial_screen.queue_free()


func _start() -> void:
	spawner.active = true
	active = true
	time_start = OS.get_unix_time()


func _game_over() -> void:
	spawner.active = false
	active = false
	
	gauge_display.text = str(0)
	
	emit_signal("destroy_all_packets")
	game_over_sound.play()
	
	tween.stop_all()
	
	color_flash.color.r = 1
	color_flash.color.v = 0.001
	tween.interpolate_property(color_flash, "color:v", 0.4, 0, 1)
	tween.interpolate_property(self, "speed_multiplier", 1, 0, 1)
	tween2.interpolate_property(music, "pitch_scale", 1, 0.3, 3.5)
	tween.start()
	tween2.start()
	
	glitch_filter.show()
	_set_glitch_amount(1)
	
	yield(get_tree().create_timer(1), "timeout")
	
	get_tree().call_group("Game", "queue_free")
	game_over_screen.go()
	
	glitch_filter.show()
	tween.interpolate_method(self, "_set_glitch_amount", 0.3, 0, 0.65)
	tween.interpolate_property(glitch_filter, "visible", true, false, 0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.65)
	tween.start()
	
	yield(tween2, "tween_all_completed")
	music.stop()


func _on_packet_passed(point: int) -> void:
	gauge += point
	
	if gauge > 0:
		if point < 0:
			glitch_filter.show()
			color_flash.color.r = 1
			color_flash.color.v = 0.001
			tween.interpolate_method(self, "_set_glitch_amount", 0.2, 0, 0.7)
			tween.interpolate_property(glitch_filter, "visible", true, false, 0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.7)
			tween.interpolate_property(color_flash, "color:v", 0.3, 0, 0.3)
			tween.interpolate_property(pass_gradient, "modulate", Color(1, 0, 0, 0.78), Color(0, 0, 0, 0.47), 0.5)
			tween.start()
			
			var p_ins = passed_particle.duplicate()
			add_child_below_node(pass_gradient, p_ins)
			p_ins.modulate = Color.red
			
			passed_sound_bad.play()
		else:
			tween.interpolate_property(pass_gradient, "modulate", Color(0, 1, 0, 0.78), Color(0, 0, 0, 0.47), 0.5)
			tween.start()
			
			var p_ins = passed_particle.duplicate()
			add_child_below_node(pass_gradient, p_ins)
			p_ins.modulate = Color.green
			
			passed_sound_good.play()


func _set_glitch_amount(amount: float) -> void:
	glitch_filter.material.set_shader_param("amount", amount)
