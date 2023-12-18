extends Node
class_name Fsm

var state = null : set = _set_state, get = _get_state
# _curr := {"state": IState, "type": enum}
var _curr := {"state": null, "type": -1}
var states := {}

signal state_changed(_statee)


func init(_states := {}, _state_args := {}) -> Fsm:
	for _state_type in _states:
		_states[_state_type].init(_state_args) \
			.change_state.connect(_set_state)
	states = _states
	return self

func _set_state(_state_type) -> bool:
	if  _state_type == null or (_curr["state"] != null \
	and _curr["type"] == _state_type):
		return false
	if _curr["state"] != null:
		_curr["state"].exit()
	states[_state_type].enter()
	_curr = {"state": states[_state_type], "type": _state_type}
	emit_signal("state_changed", _state_type)
	return true

func _get_state():
	return _curr["type"]

func physics_process(delta: float):
	if _curr["state"] != null:
		_curr["state"].physics_process(delta)

func process(delta: float):
	if _curr["state"] != null:
		_curr["state"].process(delta)

func input(event: InputEvent):
	if _curr["state"] != null:
		_curr["state"].input(event)
