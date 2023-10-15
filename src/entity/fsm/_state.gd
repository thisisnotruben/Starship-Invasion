extends Node
class_name IState

var active: bool = false

signal change_state(_state)


func init(_args := {}) -> IState:
	return self

func enter():
	active = true

func exit():
	active = false

func physics_process(_delta: float):
	pass

func process(_delta: float):
	pass
	
func input(_event: InputEvent):
	pass
