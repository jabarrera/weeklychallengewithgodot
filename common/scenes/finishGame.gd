extends Node2D

func _on_Button_pressed():
	get_tree().change_scene("res://challenges/week4/scenes/main.tscn")

func set(message : String, background_colour : Color):
	$Label.text = message
	$ColorRect.color = background_colour
