extends Node
class_name IState

@export_category("Performance Flags")
@export var need_physics_process := false
@export var need_process := false
@export var need_input_process := false


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
