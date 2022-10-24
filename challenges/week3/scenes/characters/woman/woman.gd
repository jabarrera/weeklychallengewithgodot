extends Area2D

signal woman_hit

var hurted : bool = false

var money_deposit = 25

var can_be_shooted : bool = true

enum character_type {WOMAN, BANDIT, HATTER}

const type : int = character_type.WOMAN


func _on_woman_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and not hurted and can_be_shooted:
		damaged()

func damaged():
	hurted = true
	$woman_sprite.modulate = Color(1, 0, 0)
	$scream.play()
	emit_signal("woman_hit")

func _empty_bullets():
	can_be_shooted = false
	
func _have_bullets():
	can_be_shooted = true
