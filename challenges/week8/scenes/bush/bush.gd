extends Area2D

signal bush_destroyed(position)


func _ready():
	add_to_group("bushes")

func destroy():
	$BushDestroySound.play()
	$Sprite.hide()
	$CPUParticles2D.emitting = true
	monitorable = false
	emit_signal("bush_destroyed", global_position)
	
