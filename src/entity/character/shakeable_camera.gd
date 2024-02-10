extends Node

@export var trauma_reduction_rate := 1.0

@export var max_x := 10.0
@export var max_y := 10.0
@export var max_z := 5.0

@export var noise: FastNoiseLite
@export var noise_speed := 50.0

var trauma := 0.0
var time := 0.0

@export var camera: Camera3D = null
var initial_rotation: Vector3 = Vector3.ZERO


func _ready():
	set_process(false)
	if camera != null:
		initial_rotation = camera.rotation_degrees

func _process(delta: float):
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)

	camera.rotation_degrees.x = initial_rotation.x + max_x * _get_shake_intensity() * _get_noise_from_seed(0)
	camera.rotation_degrees.y = initial_rotation.y + max_y * _get_shake_intensity() * _get_noise_from_seed(1)
	camera.rotation_degrees.z = initial_rotation.z + max_z * _get_shake_intensity() * _get_noise_from_seed(2)

func _get_shake_intensity() -> float:
	return trauma * trauma

func _get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)

func add_trauma(trauma_amount : float):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func shake(duration_sec: float):
	set_process(true)
	var tween := get_tree().create_tween()
	tween.tween_method(add_trauma, 0.8, 0.8, duration_sec)
	await tween.finished
	set_process(false)
