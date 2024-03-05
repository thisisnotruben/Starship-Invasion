extends Node3D
class_name AsteroidTurret

@export var bullet_scene: PackedScene = null

@onready var snd_shoot: AudioStreamPlayer3D = $snd_shoot
@onready var snd_generator: AudioStreamPlayer3D = $generator
@onready var snd_shoot1: AudioStreamPlayer = $snd_shoot1
@onready var pivot: Node3D = $pivot
@onready var ray: RayCast3D = $pivot/ray
@onready var laser_mesh: MeshInstance3D = $pivot/ray/laser_sight
@onready var anim_shoot: AnimationPlayer = $anim_shoot

@export var rotate_gun := false : set = _set_rotate
@export var scan_color: Color = Color.RED
@export var scan_hit_color: Color = Color.GREEN

@export_category("Shooting")
@export var random_shoot := false: set = _set_rand_shoot
@export var spatial_sound := true
@export_range(1.0, 10.0) var time_to_shoot := 1.5
@export_range(0.0, 0.5) var rand_amount := 0.5


func _ready():
	set_physics_process(false)
	reset_laser()

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
	anim_shoot.play("recoil")
	bullet_scene.instantiate().spawn_shot( \
		{"asteroid_turret": self, "damage": 1, \
		"snd_player": snd_shoot if spatial_sound else snd_shoot1})

func _set_rotate(_rotate_gun: bool):
	rotate_gun = _rotate_gun
	if _rotate_gun:
		$anim.play("rotate")
	else:
		$anim.stop()

func _set_rand_shoot(_random_shoot: bool):
	random_shoot = _random_shoot
	if _random_shoot:
		$timer.start(_get_rand_amount())
	else:
		$timer.stop()

func _on_timer_timeout():
	if random_shoot:
		shoot()
		$timer.start(_get_rand_amount())

func _get_rand_amount() -> float:
	var timer_sec := time_to_shoot
	if randi_range(0, 1) == 1:
		timer_sec *= (1.0 + rand_amount)
	else:
		timer_sec *= (1.0 - rand_amount)
	return timer_sec
