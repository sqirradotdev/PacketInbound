extends Control
class_name Stage

signal destroy_all_packets

onready var spawner = $Spawner
onready var gauge_display = $GaugeDisplay
onready var time_display = $TimeDisplay
onready var stream_area = $StreamArea
onready var glitch_filter = $GlitchFilter
onready var color_flash = $ColorFlash
onready var music = $Music
onready var game_over_screen = $GameOverScreen
onready var game_over_audio = $GameOverAudio
onready var tween = $Tween
onready var tween2 = $Tween2

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
	
	yield(get_tree().create_timer(2), "timeout")
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
		var minutes = elapsed / 60
		var seconds = elapsed % 60
		var elapsed_str = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
		
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


func _start() -> void:
	spawner.active = true
	active = true
	time_start = OS.get_unix_time()


func _game_over() -> void:
	spawner.active = false
	active = false
	
	gauge_display.text = str(0)
	
	emit_signal("destroy_all_packets")
	game_over_audio.play()
	
	color_flash.color.r = 1
	color_flash.color.v = 0.001
	tween.interpolate_property(color_flash, "color:v", 0.4, 0, 1)
	tween.interpolate_property(self, "speed_multiplier", 1, 0, 1)
	tween2.interpolate_property(music, "pitch_scale", 1, 0.3, 3.5)
	tween.start()
	tween2.start()
	
	glitch_filter.show()
	_set_glitch_amount(1)
	
	yield(tween, "tween_all_completed")
	
	get_tree().call_group("Game", "queue_free")
	game_over_screen.go()
	
	glitch_filter.show()
	tween.interpolate_method(self, "_set_glitch_amount", 0.3, 0, 0.65)
	tween.start()
	
	yield(tween2, "tween_all_completed")
	
	music.stop()


func _on_packet_passed(point: int) -> void:
	gauge += point
	
	# If negative (bad packet)
	if gauge > 0:
		if point < 0:
			glitch_filter.show()
			color_flash.color.r = 1
			color_flash.color.v = 0.001
			tween.interpolate_method(self, "_set_glitch_amount", 0.2, 0, 0.7)
			tween.interpolate_property(glitch_filter, "visible", true, false, 0.7)
			tween.interpolate_property(color_flash, "color:v", 0.3, 0, 0.3)
			tween.start()


func _set_glitch_amount(amount: float) -> void:
	glitch_filter.material.set_shader_param("amount", amount)
