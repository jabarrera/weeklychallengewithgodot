extends Node2D

signal empty_bullets
signal have_bullets

# Called when the node enters the scene tree for the first time.
func _ready():
	show_all_bullets()

func _on_main_shoot():
	for node in get_children():
		if node.visible:
			node.visible = false
			break
	
	var have_bullets : bool = false
	for node in get_children():
		if node.visible:
			have_bullets = true
			break
	
	if not have_bullets:
		emit_signal("empty_bullets")
	else:
		emit_signal("have_bullets")

func _on_main_reload():
	emit_signal("have_bullets")
	show_all_bullets()

func show_all_bullets():
	for node in get_children():
		node.show()
