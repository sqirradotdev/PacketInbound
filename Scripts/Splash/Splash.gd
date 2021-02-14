extends Control


func _ready() -> void:
	$AnimationRoot.play("splash")
	$DizzyAri/Animation.play("cool")


func _on_AnimationRoot_animation_finished(anim_name: String) -> void:
	SceneLoader.start_load("res://Scripts/Menu/Menu.tscn", true)
	queue_free()
