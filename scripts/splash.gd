extends Control

export (String, FILE, "*.tscn") var next_scene

var load_thread = Thread.new()

func _ready():
	load_thread.start(self, "load_scene")
	$AnimationPlayer.play("FadeIn")
	
func load_scene(_data) -> Resource:
	var res = ResourceLoader.load(next_scene)
	if res == null:
		print_debug("Couldn't load scene! ", next_scene)
	return res
	
func goto_scene():
	var scene = load_thread.wait_to_finish().instance()
	get_node("/root").add_child(scene)
	queue_free()