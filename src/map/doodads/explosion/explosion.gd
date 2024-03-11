extends ITriggerable
class_name ShipExplosion

@onready var shake_cam: ShakeCam = $shake_cam
@onready var snd: AudioStreamPlayer = $offset/snd
@onready var particles: GPUParticles3D = $offset/particles

@export var snd_library: Array[AudioStream] = []
@export_range(1.0, 3.0) var shake_cam_sec_max := 2.5

var passed_by := false


func _ready():
	shake_cam.noise = FastNoiseLite.new()
	snd.stream = snd_library.pick_random()

func trigger(node: Node3D):
	if not passed_by and node is Character and not node.npc:
		passed_by = true
		shake_cam.camera = node.camera
		shake_cam.shake(randf_range(1.0, shake_cam_sec_max), true)
		snd.play()
		particles.emitting = true
		await get_tree().create_timer(5.0).timeout
		queue_free()

func _on_area_3d_body_entered(body: Node3D):
	trigger(body)
