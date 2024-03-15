extends ITriggerable
class_name ShipExplosion

const CEILING_HEIGHT := 3.8

@onready var shake_cam: ShakeCam = $shake_cam
@onready var snd: AudioStreamPlayer = $offset/snd
@onready var particles: GPUParticles3D = $particles

@export var snd_library: Array[AudioStream] = []
@export_range(1.0, 3.0) var shake_cam_sec_max := 2.5
@export var rand_coll := true
@export_range(0.5, 10.0) var coll_min_radius := 2.75
@export_range(0.5, 10.0) var coll_max_radius := 6.0
@export_range(0.5, 10.0) var min_sec_explode_again = 1.5
@export_range(0.5, 10.0) var max_sec_explode_again = 3.0

var passed_by := false


func _ready():
	shake_cam.noise = FastNoiseLite.new()
	if rand_coll:
		$offset/area3D/coll.shape.radius = randf_range( \
			coll_min_radius, coll_max_radius)

func trigger(node: Node3D):
	if not passed_by:
		if node != null:
			shake_cam.camera = node.camera
			shake_cam.shake(randf_range(1.0, shake_cam_sec_max), true)
		snd.stream = snd_library.pick_random()
		particles.position.y = randf_range(0.5, CEILING_HEIGHT)
		passed_by = true
		particles.emitting = true
		snd.play()
		await get_tree().create_timer( \
			randf_range(min_sec_explode_again, max_sec_explode_again)).timeout
		passed_by = false

func _on_area_3d_body_entered(body: Node3D):
	if body is Character and not body.npc:
		trigger(body)
