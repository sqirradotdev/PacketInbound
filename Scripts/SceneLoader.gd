extends Node
signal done

var thread: Thread
var instance_immediately: bool = false


func _ready() -> void:
	pass


func start_load(path: String, immediate: bool) -> void:
	instance_immediately = immediate
	
	if OS.has_feature("HTML5"):
		if instance_immediately:
			call_deferred("_html5_load_immediate", path)
	else:
		thread = Thread.new()
		thread.start(self, "_thread_load", path)
	
	print("Loading scene from path: " + path)


func _thread_load(path: String) -> void:
	var ril: ResourceInteractiveLoader = ResourceLoader.load_interactive(path)
	
	var res: Resource
	
	while true:
		var err = ril.poll()
		if err == ERR_FILE_EOF:
			print("Scene loaded.")
			res = ril.get_resource()
			break
		elif err != OK:
			printerr("Scene load failed, error code " + str(err))
			return
	
	if instance_immediately:
		call_deferred("_end_load_immediate", res)
	else:
		call_deferred("_end_load", res)


func _end_load(res: Resource) -> void:
	thread.wait_to_finish()
	emit_signal("done", res)
	
	print("Scene resource is passed to a signal")


func _end_load_immediate(res: Resource) -> void:
	thread.wait_to_finish()
	
	if res is PackedScene:
		var ins: Node = res.instance()
		get_node("/root").add_child(ins, true)
		get_tree().current_scene = ins
	
	emit_signal("done")
	
	print("Scene is instanced to the scene tree")


func _html5_load_immediate(path: String) -> void:
	var res: Resource = load(path)
	
	if res is PackedScene:
		var ins: Node = res.instance()
		get_node("/root").add_child(ins, true)
		get_tree().current_scene = ins
	
	emit_signal("done")
	
	print("Scene is instanced to the scene tree (HTML5)")
