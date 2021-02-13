extends Node2D

var packet_scene = preload("res://Scripts/Game/Packet/Packet.tscn")

var active: bool = false
var y_trigger: float = 0

var last_instance: KinematicBody2D


func _ready() -> void:
	# For debugging purposes, activate right away
	if get_tree().current_scene == self:
		active = true


func _process(delta: float) -> void:
	if active:
		# Dont spawn before it hits the trigger
		if last_instance and last_instance.position.y > 1280 - y_trigger:
			return
		
		var instance = packet_scene.instance()
		instance.position.x = rand_range(251, 540)
		instance.position.y = 1446
		last_instance = instance
		add_child(instance)
		
		if get_parent() is Stage:
			instance.connect("passed", get_parent(), "_on_packet_passed")
