extends Node

@export var lights: Array[Light3D] = []

@export_category("Color Gradient")
@export var gradient: Gradient = null
@export_range(0.25, 15.0) var gradient_loop_time := 1.0


func _ready():
	color_gradient()

func color_gradient():
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	for light in lights:
		#light.light_color = gradient.colors[0]
		for c in gradient.colors:
			tween.tween_property(light, "light_color", c, \
				gradient_loop_time / gradient.colors.size())
	tween.tween_callback(color_gradient)
