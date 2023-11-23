extends Trap

enum ExcludeGroup{ NONE, FRIENDLY, FOE }

@export var bullet_scene: PackedScene
@export var target: Marker3D = null
@export_range(0.25, 15.0) var shoot_interval_sec := 7.5
@export var exclude_group := ExcludeGroup.NONE

@export_subgroup("movement")
@export var path_follow: PathFollow3D = null
@export_range(0.0, 40.0) var speed: float = 20.0

@onready var snd_shoot: AudioStreamPlayer3D = $snd_shoot


func _ready():
	set_physics_process(false)
	super._ready()
	if target == null:
		print_debug("[%s] doesn't have set vale 'target'." % get_path())

func _physics_process(delta: float):
	if path_follow != null and speed > 0.0:
		path_follow.progress += speed * delta

func toggle(activate: bool):
	super.toggle(activate)
	set_physics_process(activate)
	if activate:
		$timer_shoot.start(shoot_interval_sec)
	else:
		$timer_shoot.stop()

func _on_timer_shoot_timeout():
	var exclude := []
	match exclude_group:
		ExcludeGroup.FRIENDLY:
			exclude = get_tree().get_nodes_in_group("friendly")
		ExcludeGroup.FOE:
			exclude = get_tree().get_nodes_in_group("foe")

	bullet_scene.instantiate().spawn_shot( \
		{"trap": self, "target": target, "exclude": exclude})
