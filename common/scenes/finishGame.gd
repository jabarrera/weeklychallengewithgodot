extends Node

var scene : String

func configure(message : String, background_colour : Color, scene_path : String):
	$Label.text = message
	$ColorRect.color = background_colour
	scene = scene_path

func _on_Button_button_up():
	get_tree().change_scene(scene)

func enable_button_timer(time : float):
	$Button.disabled = true
	yield(get_tree().create_timer(time), "timeout")
	$Button.disabled = false
