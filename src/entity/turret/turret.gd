extends Node3D
class_name AsteroidTurret

@export var bullet_scene: PackedScene = null

@onready var laser_mesh: MeshInstance3D = $turret_gun/ray/laser_sight
@onready var snd_shoot: AudioStreamPlayer3D = $snd_shoot
@onready var ray: RayCast3D = $turret_gun/ray
@onready var pivot: Node3D = $turret_gun

@export var rotate_gun := false : set = _set_rotate
@export var scan_color: Color = Color.RED
@export var scan_hit_color: Color = Color.GREEN


func _ready():
	set_physics_process(false)
	reset_laser()

func _physics_process(_delta: float):
	if ray.is_colliding():
		laser_mesh.material_override.albedo_color = scan_hit_color
		laser_mesh.material_override.emission = scan_hit_color
	else:
		reset_laser()

func reset_laser():
	laser_mesh.mesh.height = ray.target_position.y
	laser_mesh.position.y = laser_mesh.mesh.height / 2.0
	laser_mesh.material_override.albedo_color = scan_color
	laser_mesh.material_override.emission = scan_color

func shoot():
	bullet_scene.instantiate().spawn_shot( \
		{"asteroid_turret": self, "damage": 1})

func _set_rotate(_rotate_gun: bool):
	rotate_gun = _rotate_gun
	if _rotate_gun:
		$anim.play("rotate")
	else:
		$anim.stop()
