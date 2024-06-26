extends CharacterState
class_name Move

@onready var player_move: IState = $player
@onready var npc_move: IState = $npc

@export_group("Movement Variables")
@export_subgroup("Movement")
@export_range(0.0, 20.0) var speed: float = 6.0

@export_subgroup("Camera Bop")
@export_range(0.0, 10.0) var BOB_FREQ: float = 2.4
@export_range(0.0, 0.5) var BOB_AMP: float = 0.095

var t_bob: float = 0.0
var velocity := Vector3.ZERO: set = _set_velocity, get = _get_velocity
var pivot: Node3D = null
var pivot_offset := Vector3.ZERO


func _init():
	type = CharacterStates.Type.MOVE

func init(args := {}) -> IState:
	super.init(args)
	pivot = args["character"].get_node("img/pivot")
	pivot_offset = pivot.position
	return self

func exit():
	super.exit()
	velocity = Vector3(0.0, velocity.y, 0.0)

func physics_process(delta: float):
	super.physics_process(delta)
	if character.npc:
		npc_move.physics_process(delta)
	else:
		player_move.physics_process(delta)

# animation
func apply_animation(input_dir: Vector2):
	if input_dir.length() > 0.0:
		var anim_direction := input_dir.normalized()
		anim_direction.y *= -1.0
		for anim in ["idle", "move", "melee"]:
			var anim_path: String = "parameters/%s/blend_position" % anim
			if character.anim_tree.get(anim_path) != null:
				character.anim_tree[anim_path] = anim_direction

# camera
func apply_camera_movement(delta: float):
	t_bob += delta * velocity.length() * float(character.is_on_floor())
	pivot.transform.origin = pivot_offset + _headbob(t_bob)

func _headbob(time: float) -> Vector3:
	return Vector3(cos(time * BOB_FREQ / 2.0) * BOB_AMP, \
	sin(time * BOB_FREQ) * BOB_AMP, 0.0)

# util
func _set_velocity(_velocity: Vector3):
	character.velocity = _velocity

func _get_velocity() -> Vector3:
	return character.velocity
