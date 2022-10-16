extends Area2D

var velocity : int = 300
var direction : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.play()


func _process(delta):
	position += direction * velocity * delta


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
