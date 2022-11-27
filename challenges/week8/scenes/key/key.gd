extends Area2D

signal key_captured

func _on_key_body_entered(body):
	$CPUParticles2D.emitting = true
	emit_signal("key_captured")
