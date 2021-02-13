extends Control
class_name Stage

onready var spawner = $Spawner
onready var stream_area = $StreamArea

var good_chance: int = 80
var good_chance_min: int = 35
var speed: float = 250
var gauge_deductor: float = 5

var gauge: float = 100
var score: int = 0

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
		speed = 440
	
	gauge_deductor += 0.005 * delta
	gauge -= gauge_deductor * delta
	gauge = clamp(gauge, 0, 100)
	
	time_now = OS.get_unix_time()
	elapsed = time_now - time_start
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var elapsed_str = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
	
	# Difficulty step every 50 seconds
	if elapsed > 1 and not elapsed % 25 and not elapsed == prev_elapsed and good_chance > good_chance_min:
		good_chance -= 15
		good_chance = clamp(good_chance, good_chance_min, 100)
		prev_elapsed = elapsed
	
	$Label.text = "Gauge: " + str(gauge) + "\nTime: " + elapsed_str + "\nChance: " + str(100 - good_chance) + "%\nSpeed: " + str(speed)
