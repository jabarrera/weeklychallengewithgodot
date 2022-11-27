extends Node2D

signal empty_life

var life : int = 100


func _ready():
	init()

func init():
	life = 100;
	$life.scale.x = 1
	
func lose_life(amount):
	life -= amount
	if life - amount > 0:
		$life.scale.x -= amount * 0.01
	else:
		$life.scale.x = 0.0
		emit_signal("empty_life")


func _on_main_damaged_by_lava(amount):
	lose_life(amount)
