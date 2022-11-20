extends Node2D

export var letter : String


func _ready():
	$letter_area/Label.text = letter
	add_to_group("letters")

func explode():
	$letter_area/Label.visible = false
	$letter_area.monitoring = false
	$letter_area.monitorable = false
	$letter_area/CPUParticles2D.emitting = true
