extends Node2D

func _draw():
	draw_mouse_position()
	
func _process(delta):
	update()
	
func draw_mouse_position():
	draw_circle(get_viewport().get_mouse_position(), 1, Color(1, 0, 0))
