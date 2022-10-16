extends Node2D

const MAX_SECOND_METEOR_SPAWN = 10
const MIN_METEORS_SPAWNED = 1
const MAX_METEORS_SPAWNED = 3

var bullet_scene = preload("res://challenges/week2/scenes/bullet/bullet.tscn")
var meteor_scene = preload("res://challenges/week2/scenes/meteor/meteor.tscn")


func _ready():
	randomize()
	$diedMessage.hide()

func _on_spaceship_shooted(bullet_position, bullet_direction):
	var new_bullet = bullet_scene.instance()
	new_bullet.position = bullet_position
	new_bullet.direction = bullet_direction
	new_bullet.add_to_group("bullets")
	get_node("shoots").add_child(new_bullet)


func _on_spaceship_died():
	$diedMessage.show()

func _on_meteor_spawn_timeout():
	create_meteors()
	var new_time = randi() % MAX_SECOND_METEOR_SPAWN
	$meteor_field/meteor_spawn.wait_time = new_time
	$meteor_field/meteor_spawn.start()
	
func create_meteors():
	var randomGenerator = RandomNumberGenerator.new()
	randomGenerator.randomize()
	var num_meteors = randomGenerator.randi_range(MIN_METEORS_SPAWNED, MAX_METEORS_SPAWNED)
	
	for i in num_meteors:
		var new_meteor = meteor_scene.instance()
		new_meteor.connect("divided_meteor", self, "_on_divided_meteor")
		$meteor_field.add_child(new_meteor)
		

func _on_divided_meteor(new_meteor_position, new_meteor_direction):
	var new_meteor = meteor_scene.instance()
	new_meteor.connect("divided_meteor", self, "_on_divided_meteor")
	new_meteor.is_final_meteor = true
	new_meteor.global_position = new_meteor_position
	new_meteor.direction = new_meteor_direction
	$meteor_field.add_child(new_meteor)


func _on_Area2D_area_exited(area):
	area.queue_free()
