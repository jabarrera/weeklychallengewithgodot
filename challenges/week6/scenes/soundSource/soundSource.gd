extends Area2D

export(AudioStream) var audio

const MIN_AUDIBLE_DECIBELS : int = -60
onready var MAX_SAFE_AUDIO_DECIBELS = $AudioStreamPlayer.volume_db

var sound_area_radius : float
var listener : Area2D


func _ready():
	calculate_sound_area_radio()
	$AudioStreamPlayer.stream = audio
	$AudioStreamPlayer.volume_db = -100
	$AudioStreamPlayer.stop()
	$music.emitting = false

func _process(delta):
	if listener != null:
		calculate_volumen()

func calculate_volumen():	
	var distance = listener.position.distance_to(position)
	var distance_percentage = (distance * 100) / sound_area_radius
	var new_volume = lerp(MAX_SAFE_AUDIO_DECIBELS, MIN_AUDIBLE_DECIBELS, distance_percentage / 100)
	$AudioStreamPlayer.volume_db = clamp(new_volume, MIN_AUDIBLE_DECIBELS, MAX_SAFE_AUDIO_DECIBELS)

func calculate_sound_area_radio():
	if $soundArea/CollisionShape2D.shape is CircleShape2D:
		sound_area_radius = $soundArea/CollisionShape2D.shape.get_radius()

func _on_soundArea_area_entered(area):
	if area.name == "character":
		listener = area
		$AudioStreamPlayer.volume_db = 0
		$AudioStreamPlayer.play()
		$music.emitting = true


func _on_soundArea_area_exited(area):
	if area.name == "character":
		listener = null
		$AudioStreamPlayer.stop()
		$AudioStreamPlayer.volume_db = -100
		$music.emitting = false
