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
			call_deferred("_html5_load_im", path)
	else:
		thread = Thread.new()
		thread.start(self, "_thread_load", path)


func _thread_load(path: String) -> void:
	var ril: ResourceInteractiveLoader = ResourceLoader.load_interactive(path)
	
	var res: Resource
	
	while true:
		var err = ril.poll()
		if err == ERR_FILE_EOF:
			print("Epic! Load success!")
			res = ril.get_resource()
			break
		elif err != OK:
			printerr("Oopsies, loading failed.")
			return
	
	if instance_immediately:
		call_deferred("_end_load_im", res)
	else:
		call_deferred("_end_load", res)


func _end_load(res: Resource) -> void:
	thread.wait_to_finish()
	emit_signal("done", res)


func _end_load_im(res: Resource) -> void:
	thread.wait_to_finish()
	
	if res is PackedScene:
		var ins: Node = res.instance()
		get_node("/root").add_child(ins, true)
		get_tree().current_scene = ins
	
	emit_signal("done")


func _html5_load_im(path: String) -> void:
	var res: Resource = load(path)
	
	if res is PackedScene:
		var ins: Node = res.instance()
		get_node("/root").add_child(ins, true)
		get_tree().current_scene = ins
	
	emit_signal("done")
