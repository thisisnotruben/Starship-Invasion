extends Node

var thread = Thread.new()

@export var progress_bar_path: NodePath = ""
var progress_bar: Range = null

signal done_loading(packed_scene)


func _ready():
	progress_bar = get_node_or_null(progress_bar_path)

func start(scene_path: String):
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)
	return
	ResourceLoader.load_threaded_request(scene_path)
	
	var progress := []
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	if progress_bar != null:
		thread.start(Callable(self, "_on_load_diplay").bind(status, progress))
		
	var resource: PackedScene = null
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		resource = ResourceLoader.load_threaded_get(scene_path)
	emit_signal("done_loading", resource)
	
func _on_load_diplay(status: ResourceLoader.ThreadLoadStatus, progress: Array):
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		progress_bar.value = progress[0] * 100

func _exit_tree():
	if thread.is_started():
		thread.wait_to_finish()
