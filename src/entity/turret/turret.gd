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

@export_category("Shooting")
@export var random_shoot := false
@export var hide_laser := false
@export_range(1.0, 10.0) var time_to_shoot := 1.5
@export_range(0.0, 0.5) var rand_amount := 0.5


func _ready():
	set_physics_process(false)
	reset_laser()
	if random_shoot:
		$timer.start(_get_rand_amount())
	#$turret_gun/ray/laser_sight.visible = not hide_laser

func _physics_process(_delta: float):
	if ray.is_colliding():
		arm_laser()
	else:
		reset_laser()

func arm_laser():
	laser_mesh.material_override.albedo_color = scan_hit_color
	laser_mesh.material_override.emission = scan_hit_color

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

func _on_timer_timeout():
	# TODO
	#arm_laser()
	#await get_tree().create_timer(0.2).timeout
	#await get_tree().create_timer(0.1).timeout
	#reset_laser()
	shoot()
	$timer.start(_get_rand_amount())

func _get_rand_amount() -> float:
	var timer_sec := time_to_shoot
	if randi_range(0, 1) == 1:
		timer_sec *= (1.0 + rand_amount)
	else:
		timer_sec *= (1.0 - rand_amount)
	return timer_sec
