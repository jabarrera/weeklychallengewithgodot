extends StaticBody2D

var door_is_open : bool = false

func _ready():
	$AnimatedSprite.play("closed")
	$AnimationPlayer.play("RESET")


func _on_open_door_area2D_body_entered(body):
	if body.name == "character":
		if body.has_key():
			open_door()


func open_door():
	$DoorSound.play()
	$AnimatedSprite.play("opening")
	$AnimationPlayer.play("opening")
	door_is_open = true


func _on_open_door_area2D_body_exited(body):
	if body.name == "character" and door_is_open:
		close_door()
		
func close_door():
	$DoorSound.play()
	$AnimatedSprite.play("closing")
	$AnimationPlayer.play_backwards("opening")
