extends Node2D

var screen_margin_horizontal = 100
var screen_margin_vertical = 90
var seconds_hide_speak = 1

export(Texture) var npc_texture
export(Array, String) var npc_greetings
export(Array, String) var npc_farewells

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	position.x = rand_range(screen_margin_horizontal, get_viewport_rect().size.x - screen_margin_horizontal)
	position.y = rand_range(screen_margin_vertical, get_viewport_rect().size.y - screen_margin_vertical)
		
	$StaticBody2D/Sprite.texture = npc_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_sight_line_body_entered(body):
	if (body.name == "player"):
		$speak/speakTimer.stop()
		$speak.text = npc_greetings[rand_range(0, npc_greetings.size())]


func _on_sight_line_body_exited(body):
	if (body.name == "player"):
		$speak.text = npc_farewells[rand_range(0, npc_farewells.size())]
		$speak/speakTimer.start(seconds_hide_speak)


func _on_speakTimer_timeout():
	$speak.text = ""
