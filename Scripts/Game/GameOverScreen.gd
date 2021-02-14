extends Control

onready var tween = $Tween

var final_time: int
var final_time_interp: int = 0

var can_retry: bool = false


func _ready() -> void:
	$Label.show()
	$Label2.hide()
	$Label3.hide()
	$FinalTime.hide()
	
	set_process(false)


func _process(delta: float) -> void:
	$FinalTime.text = get_parent().format_second(final_time_interp)


func go() -> void:
	set_process(true)
	final_time = get_parent().elapsed
	
	show()
	
	tween.interpolate_property($Label, "modulate:a", 1, 0, 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.75)
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	$Label2.show()
	$Label3.show()
	$FinalTime.show()
	
	get_parent().glitch_filter.show()
	tween.interpolate_method(get_parent(), "_set_glitch_amount", 0.1, 0, 0.5)
	tween.interpolate_property(get_parent().glitch_filter, "visible", true, false, 0.7)
	tween.interpolate_property(self, "final_time_interp", 0, final_time, 1.5)
	tween.start()
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	can_retry = true


func _on_Label3_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_touch") and can_retry:
		get_tree().reload_current_scene()

