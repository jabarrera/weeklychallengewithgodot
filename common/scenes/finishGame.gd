extends Node2D

var scene : String

func _on_Button_pressed():
	get_tree().change_scene(scene)

func configure(message : String, background_colour : Color, scene_path : String):
	$Label.text = message
	$ColorRect.color = background_colour
	scene = scene_path
