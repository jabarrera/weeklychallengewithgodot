extends Area2D

signal in_hole()

var playing : bool = false

func _on_hole_area_entered(area):
	if playing:
		emit_signal("in_hole")
