extends Node3D

@onready var snd_space: AudioStreamPlayer = $space_sound
@export var hit_box: Area3D = null
@export var spawns: Array[Spawn] = []

@export var space_celestials: Node3D = null


func _on_space_sound_area_body_entered(body: Node3D):
	if _is_player(body):
		toggle(true)
		if space_celestials != null:
			space_celestials.show()

func _on_space_sound_area_body_exited(body: Node3D):
	if _is_player(body):
		toggle(false)
		for character in hit_box.get_overlapping_bodies():
			character.health = 0
		if space_celestials != null:
			space_celestials.hide()

func _is_player(body: Node3D) -> bool:
	return body is Character and not body.npc

func toggle(activate: bool):
	snd_space.fade(activate)
	spawns.map(func(s): s.toggle(activate))
	get_tree().call_group("celestial", "toggle", activate)
