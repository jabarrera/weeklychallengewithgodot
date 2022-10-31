extends Node2D

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)
