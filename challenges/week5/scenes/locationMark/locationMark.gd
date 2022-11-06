extends Node2D

signal show_me
signal hide_me


# Called when the node enters the scene tree for the first time.
func _ready():
	hide_me()


func hide_me():
	hide()
	$AnimationPlayer.stop()
	
func show_me():
	show()
	$AnimationPlayer.play("jumping")



func _on_locationMark_hide_me():
	hide_me()

func _on_locationMark_show_me():
	show_me()
