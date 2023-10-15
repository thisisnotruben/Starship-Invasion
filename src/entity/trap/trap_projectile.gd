extends Trap

@export var bullet_scene: PackedScene
@export var target: Marker3D = null
@export_range(1.0, 15.0) var shoot_interval_sec := 7.5
@export_subgroup("movement")
@export var path_follow: PathFollow3D = null
@export_range(0.0, 40.0) var speed: float = 20.0


func _ready():
	super._ready()
	if target == null:
		print_debug("[%s] doesn't have set vale 'target'." % get_path())

func toggle(activate: bool):
	super.toggle(activate)
	
	if path_follow != null and speed > 0.0:
		get_tree().create_tween().tween_property( \
			path_follow, "progress_ratio", 1.0, speed)
	
	if activate:
		$timer_shoot.start(shoot_interval_sec)
	else:
		$timer_shoot.stop()

func _on_timer_shoot_timeout():
	bullet_scene.instantiate().spawn_shot({"trap": self, "target": target})
