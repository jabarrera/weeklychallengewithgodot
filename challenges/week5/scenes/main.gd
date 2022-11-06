extends Node

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)

func _ready():
	randomize()


func show_location_mark(location : Vector2):
	$locationMark.position = location
	$locationMark.emit_signal("show_me")

func hide_location_mark():
	$locationMark.emit_signal("hide_me")


func _on_character_destination(new_location):
	show_location_mark(new_location)

func _on_character_destination_reached():
	hide_location_mark()
