extends Area2D


signal bandit_died
signal bandit_shoot

var hurted : bool = false
var can_be_shooted : bool =  true

enum character_type {WOMAN, BANDIT, HATTER}

const type : int = character_type.BANDIT

func _ready():
	bandit_init()

func _on_bandit_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and not hurted and can_be_shooted:
		damaged()

func damaged():
	$shoot_timer.stop()
	hurted = true
	$bandit_sprite.modulate = Color(0, 1, 0)
	emit_signal("bandit_died")
	
func start_time_shoot():
	$shoot_timer.start()


func _on_shoot_timer_timeout():
	$shoots.show()
	$shoot.play()
	emit_signal("bandit_shoot")
	
func bandit_init():
	hurted = false
	$bandit_sprite.modulate = Color(1, 1, 1, 1)
	$shoots.hide()
	
func _empty_bullets():
	can_be_shooted = false
	
func _have_bullets():
	can_be_shooted = true
