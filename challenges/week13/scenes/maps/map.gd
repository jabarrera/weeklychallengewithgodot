extends Node2D

signal entering_finish(map)
signal exiting_finish(map)

func ball_position() -> Vector2:
	return $ball_start_position.position
	
func hole_position() -> Vector2:
	return $hole_position.position

func enter_scene():
	$Actions.play("Entering")
	
func exit_scene():
	$Actions.play("Exiting")


func _on_Actions_animation_finished(anim_name):
	match anim_name:
		"Entering":
			emit_signal("entering_finish", self)
		"Exiting":
			emit_signal("exiting_finish", self)
		
	
	
