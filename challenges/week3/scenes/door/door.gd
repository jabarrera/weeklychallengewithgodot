extends Node2D


const MIN_OPENING_TIME = 2
const MAX_OPENING_TIME = 10

const CLOSE_DOOR_TIME = 2

var opening_time : float
var playing : bool = true

signal waiting_guess
signal door_open
signal door_closed


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_random_opening()
	$closing_timer.wait_time = CLOSE_DOOR_TIME
	$shield_shoot.mouse_filter = Control.MOUSE_FILTER_STOP

func set_random_opening():
	$opening_timer.wait_time = rand_range(MIN_OPENING_TIME, MAX_OPENING_TIME)
	emit_signal("waiting_guess")

func _on_opening_timer_timeout():
	$door_animated_sprite.play("abrir")

func _on_closing_timer_timeout():
	$door_animated_sprite.play("cerrar")
	

func _on_door_animated_sprite_animation_finished():
	if $door_animated_sprite.animation == "cerrar":
		emit_signal("door_closed")
		set_random_opening()
	elif $door_animated_sprite.animation == "abrir":
		$shield_shoot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		emit_signal("door_open")
		$closing_timer.start()

func filled():
	if (playing):
		$shield_shoot.mouse_filter = Control.MOUSE_FILTER_STOP
		$opening_timer.start()
	
func stop():
	playing = false
	$opening_timer.stop()
	$closing_timer.stop()
