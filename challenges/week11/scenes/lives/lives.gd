extends Node2D

signal life_lost
signal life_empty

const MAX_LIVES : int = 3

onready var current_life: int = 1


func _on_lives_life_lost():
	if current_life <= MAX_LIVES:
		var life : Sprite = get_node("life_" + str(current_life))
		life.modulate = Color(0.4, 0.4, 0.4, 1)
		current_life += 1
		if current_life > MAX_LIVES:
			emit_signal("life_empty")
