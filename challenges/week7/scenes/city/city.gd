extends Node2D

signal died

const MIN_TIME_EXPLOSION_SFX = 0.1
const MAX_TIME_EXPLOSION_SFX = 2

onready var alive : bool = true

func _ready():
	randomize()
	$AnimationPlayer.play("city_floating")
	$CPUParticles2D.emitting = false

func _on_city_area_entered(area):
	if area.is_in_group("letters") and alive:
		alive = false
		$city.monitoring = false
		$CPUParticles2D.emitting = true
		play_explosion()
		$FinalExplosionsTimer.start()
		emit_signal("died")


func _on_FinalExplosionsTimer_timeout():
	play_explosion()
	$FinalExplosionsTimer.wait_time = rand_range(MIN_TIME_EXPLOSION_SFX, MAX_TIME_EXPLOSION_SFX)
	$FinalExplosionsTimer.start()

func play_explosion():
	$ExplosionStreamPlayer.play()
