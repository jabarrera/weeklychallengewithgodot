extends KinematicBody2D

var up : bool = false
var down : bool = false
var left : bool = false
var right : bool = false
var attacking : bool = false

var direction : Vector2 = Vector2(0, 0)
var velocity : int = 100
var direction_flip : bool = false

var key : bool = false

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		up = true
	
	if Input.is_action_just_pressed("ui_down"):
		down = true
	
	if Input.is_action_just_pressed("ui_left"):
		left = true
		direction_flip = true
	
	if Input.is_action_just_pressed("ui_right"):
		right = true
		direction_flip = false
		
	if Input.is_action_just_released("ui_up"):
		up = false
	
	if Input.is_action_just_released("ui_down"):
		down = false
	
	if Input.is_action_just_released("ui_left"):
		left = false
	
	if Input.is_action_just_released("ui_right"):
		right = false
		
	if (Input.is_key_pressed(KEY_SPACE)):
		attack()
			


func _physics_process(delta):
	if not attacking:
		update_direction()
		move_and_collide(direction * velocity * delta)

func update_direction():
	if up:
		direction.y = -1
	elif down:	
		direction.y = 1
	else:
		direction.y = 0
		
	if left:
		direction.x = -1
	elif right:
		direction.x = 1
	else:
		direction.x = 0
	

	if direction != Vector2(0, 0):
		$AnimatedSprite.flip_h = direction_flip
		if (direction_flip):
			$CollisionShape2D.position = $PositionFlip.position
		else:
			$CollisionShape2D.position = $PositionNotFlip.position
			
		$AnimatedSprite.play("walking")
	else:
		$AnimatedSprite.play("idle")
		
func can_move(new_position) -> bool:
	if new_position.x >= 0 and new_position.x <= get_viewport_rect().size.x \
			and new_position.y >= 0 and new_position.y <= get_viewport_rect().size.y:
		return true
	else:
		return false

func attack():
	$AttackSound.play()
	attacking = true
	$AnimatedSprite.play("attack")
	check_hit_bush()


func _on_AnimatedSprite_animation_finished():
	if attacking:
		attacking = false

func check_hit_bush():
	for area in $attack_Area2D.get_overlapping_areas():
		if area.is_in_group("bushes"):
			area.destroy()

func has_key():
	return key
	
func _key_captured():
	key = true	
