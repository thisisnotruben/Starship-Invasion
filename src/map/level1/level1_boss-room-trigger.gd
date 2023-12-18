extends Area3D

@export var marker: Marker3D = null
@onready var boss: Character = $"../../../characters/Space Warrior Gold"
var target: Character = null


func _ready():
	boss.health_changed.connect(_turn_off_turrets)

func _on_body_entered(body: Node3D):
	if body is Character and not body.npc and boss != null:
		target = body
		set_process(true)
		get_tree().call_group("boss_room_1", "toggle", true)
		get_tree().call_group("boss_room_1", "aggro", body)

func _on_body_exited(body: Node3D):
	if body == target:
		target = null

func _process(_delta: float):
	if target != null:
		marker.global_position = target.global_position
	else:
		set_process(false)

func _turn_off_turrets(health: int):
	if health == 0:
		get_tree().call_group("boss_room_1", "toggle", false)
