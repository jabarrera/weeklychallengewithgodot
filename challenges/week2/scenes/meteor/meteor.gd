extends Area2D

const MIN_VELOCITY = 50
const MAX_VELOCITY = 150

const MIN_SCALE = 0.3
const MAX_SCALE = 0.5

const MIN_FINAL_METEOR_SCALE = 0.09
const MAX_FINAL_METEOR_SCALE = 0.2

var RADIO_METEOR_CIRCLE
const RADIO_METEOR = 100

var is_final_meteor : bool = false
var fired : bool = false
var finish_animation : bool = false
var finish_sound : bool = false
var velocity : float
var direction : Vector2

var finish_point : Vector2

signal killed_spaceship
signal divided_meteor(new_meteor_position, new_meteor_direction)

func _ready():
	RADIO_METEOR_CIRCLE = get_viewport_rect().size.x * 0.5
	randomize()
	if (not is_final_meteor):
		global_position = random_meteor_position()
		finish_point = random_meteor_complementary_position()
		direction = global_position.direction_to(finish_point)
	velocity = random_velocity()
	scale = random_scale()

func _physics_process(delta):
	global_position += direction * velocity * delta
		
	if (finish_sound and (finish_animation or not is_final_meteor)):
		queue_free()
		
func _on_meteor_body_entered(body):
	if (not fired and body.name == "spaceship"):
		body.killed()


func _on_meteor_area_entered(area):
	if (area.is_in_group("bullets")):
		if (not fired):
			area.queue_free()
			fired = true
			$Sprite.hide()
			#$CollisionShape2D.set_deferred("disabled", true)
			monitorable = false
			monitoring = false
			if (not is_final_meteor):
				divide_meteor()
			else:
				$MeteoriteAnimation.play("explosion")
				
			$explosion.play()
			
			
func divide_meteor():
	var random_generator = RandomNumberGenerator.new()
	random_generator.randomize()
	var num_pieces = random_generator.randi_range(1, 3)
	
	for i in num_pieces:
		emit_signal("divided_meteor", position, random_direction())
		
func random_direction():
	randomize()
	var random_rad = rand_range(0, 5.6548667764616)
	return Vector2(cos(random_rad) * RADIO_METEOR + position.x, sin(random_rad) * RADIO_METEOR + position.y).normalized()
	
func random_velocity():
	return rand_range(MIN_VELOCITY, MAX_VELOCITY)
	
func random_meteor_position():
	var random_rad = rand_range(0, 5.6548667764616)
	var x = cos(random_rad) * RADIO_METEOR_CIRCLE + get_viewport_rect().get_center().x
	var y = sin(random_rad) * RADIO_METEOR_CIRCLE + get_viewport_rect().get_center().y

	return Vector2(x, y)

func random_scale():
	var new_min_scale : float
	var new_max_scale : float
	
	if (not is_final_meteor):
		new_min_scale = MIN_SCALE
		new_max_scale = MAX_SCALE
	else:
		new_min_scale = MIN_FINAL_METEOR_SCALE
		new_max_scale = MAX_FINAL_METEOR_SCALE
	
	var new_scale : float = rand_range(new_min_scale, new_max_scale)
		
	return Vector2(new_scale, new_scale)

func random_meteor_complementary_position():
	
	var random_angle = get_viewport_rect().get_center().angle_to_point(global_position)
	
	random_angle += rand_range(0, 0.7068583470577) - rand_range(0, 0.7068583470577)
	
	var finish_x = cos(random_angle) * RADIO_METEOR_CIRCLE + global_position.x
	var finish_y = sin(random_angle) * RADIO_METEOR_CIRCLE + global_position.y
	
	var new_direction = Vector2(finish_x, finish_y)
	
	return Vector2(finish_x, finish_y)


func _on_MeteoriteAnimation_animation_finished():
	finish_animation = true



func _on_explosion_finished():
	finish_sound = true
