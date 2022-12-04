extends Node



func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)
		
func _ready():
	$finishGame.hide()


func _on_slot_bankrupt():
	$finishGame.configure("Bankrupt!", Color(1, 0, 0, 0.5), \
			"res://challenges/week9/scenes/main.tscn")
	$finishGame.show()
