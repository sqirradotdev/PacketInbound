extends Control
class_name Stage

onready var spawner = $Spawner
onready var gauge_display = $GaugeDisplay
onready var stream_area = $StreamArea
onready var glitch_filter = $GlitchFilter
onready var tween = $Tween

var good_chance: int = 60
var good_chance_min: int = 38
var speed: float = 250
var gauge_deductor: float = 4

var gauge: float = 100

var time_start: int
var time_now: int
var elapsed: int = 0
var prev_elapsed: int = -1

var stream_width_start_end: Vector2


func _ready() -> void:
	spawner.active = true
	stream_width_start_end = Vector2(stream_area.rect_position.x, stream_area.rect_position.x + stream_area.rect_size.x)
	
	time_start = OS.get_unix_time()


func _process(delta: float) -> void:
	if not speed > 430:
		speed += 3.0 * delta
	else:
		speed = 450
	
	gauge_deductor += 0.003 * delta
	gauge -= gauge_deductor * delta
	gauge = clamp(gauge, 0, 100)
	
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
	
	gauge_display.modulate.r = (1 - (gauge / 100)) * 10
	gauge_display.modulate.g = 1.0 - clamp(1 - (gauge - 0) / (50 - 0), 0, 1)
	
	$Label.text = "Gauge: " + str(gauge) + "\nTime: " + elapsed_str + "\nChance: " + str(100 - good_chance) + "%\nSpeed: " + str(speed)
	
	gauge_display.text = str(ceil(gauge))


func _on_packet_passed(point: int) -> void:
	gauge += point
	
	# If negative (bad packet)
	if point < 0:
		glitch_filter.show()
		tween.interpolate_method(self, "_set_glitch_amount", 0.2, 0, 0.7)
		tween.interpolate_property(glitch_filter, "visible", true, false, 0.7)
		tween.start()


func _set_glitch_amount(amount: float) -> void:
	glitch_filter.material.set_shader_param("AMT", amount)
