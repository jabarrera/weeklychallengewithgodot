extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	
func _draw():
	draw_mouse_position()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	
func draw_mouse_position():
	draw_circle(get_viewport().get_mouse_position(), 1, Color(1, 0, 0))
