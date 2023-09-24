extends Node
class_name IState

signal change_state(_state)


func init(args := {}) -> IState:
	return self

func enter():
	pass

func exit():
	pass

func physics_process(delta: float):
	pass

func process(delta: float):
	pass
	
func input(event: InputEvent):
	pass
