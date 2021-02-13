extends Control


func _ready() -> void:
	$Label.show()
	
	$Label2.hide()
	$Label2.modulate.a = 0
	
	$FinalTime.hide()


func go() -> void:
	show()
