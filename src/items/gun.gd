extends Item


@onready var timer: Timer = $timer

@export var bullet_scene: PackedScene = null
@export var snd: AudioStream = null
@export_range(1, 10, 1) var damage: int = 2

@export_range(1.0, 60.0 * 5.0) var time_amount_sec := 60 * 2.0

var passed_by := false
var data := {}
var character


func _on_area_3d_body_entered(body: Node3D):
	if body is Character and not body.npc and type == Type.GUN \
	and not passed_by and not body.inventory.has(Type.GUN):
		$snd.play()
		add_powerup(body)

func add_powerup(_character: Character, timeout_sec := time_amount_sec):
	character = _character
	passed_by = true
	data = {"bullet": _character.fsm.get_node("shoot").bullet_scene,
		"snd_shoot": _character.snd_shoot.stream,
		"damage": _character.damage}
	_character.fsm.get_node("shoot").bullet_scene = bullet_scene
	_character.snd_shoot.stream = snd
	_character.damage = damage
	add_to_inventory(_character, true, self)
	timer.start(timeout_sec)

func _on_timer_timeout():
	if character != null:
		character.fsm.get_node("shoot").bullet_scene = data["bullet"]
		character.snd_shoot.stream = data["snd_shoot"]
		character.damage = data["damage"]
		add_to_inventory(character, false, self)
		queue_free()
