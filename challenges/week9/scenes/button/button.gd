extends Node2D

signal button_pressed

enum direction {UP, DOWN, LEFT, RIGHT}

export(direction) var arrow_direction


func _ready():
	$arrow.position = $arrow_button_up.position
	set_arrow_direction()

func _on_TextureButton_button_down():
	$ButtonDownSound.play()
	$arrow.position = $arrow_button_down.position
	emit_signal("button_pressed")


func _on_TextureButton_button_up():
	$arrow.position = $arrow_button_up.position
	
func set_arrow_direction():
	match arrow_direction:
		direction.DOWN:
			$arrow.flip_v = true
		direction.LEFT:
			$arrow.rotation_degrees = -90
		direction.RIGHT:
			$arrow.rotation_degrees = 90
