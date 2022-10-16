extends KinematicBody2D

var max_turn_velocity : int = 5
var turn_velocity : float = 0

var turn_left : bool = false
var turn_right : bool = false
var engine_on : bool = false

var direction : Vector2 = Vector2(0, 0)
var max_velocity : float = 2
var velocity : float = 0
var acceleration : float = 0.1
var friction : float = 0.01

var dead : bool = false

signal shooted(bullet_position, bullet_direction)
signal died

# Called when the node enters the scene tree for the first time.
func _ready():
	restart_parameters()
	engine_off()


func _input(_event):
	if (not dead):
		if (Input.is_action_just_pressed("ui_left")):
			turn_left = true
		elif (Input.is_action_just_pressed("ui_right")):
			turn_right = true
		
		if (Input.is_action_just_pressed("ui_up")):
			engine_on = true
			
		if (Input.is_action_just_pressed("shoot")):
			shoot()
		
		if (Input.is_action_just_released("ui_left")):
			turn_left = false
		
		if (Input.is_action_just_released("ui_right")):
			turn_right = false
			
		if (Input.is_action_just_released("ui_up")):
			engine_on = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	check_rotation(delta)
	check_motion()
	
	var spaceship_collisions = move_and_collide( direction * velocity)
	
	check_collisions(spaceship_collisions)
	
	
func check_rotation(delta):
	if (turn_left):
		rotate(-max_turn_velocity * delta)
	elif (turn_right):
		rotate(max_turn_velocity * delta)

func check_motion():
	if (engine_on):
		engine_on()
		if velocity <= max_velocity:
			velocity += acceleration
		
		direction = Vector2(cos(rotation - 1.5708), sin(rotation - 1.5708))
	else:
		if (velocity >= 0):
			velocity -= friction
		engine_off()
		
func engine_on():
	$ship/engine.show()
	if !$engineSound.playing:
		$engineSound.play()

func engine_off():
	engine_on = false
	if $engineSound.playing:
		$engineSound.stop()
	$ship/engine.hide()
	
func shoot():
	var bullet_position = $ship/cannon.global_position
	var bullet_direction = Vector2(cos(rotation - 1.5708), sin(rotation - 1.5708)).normalized()
	emit_signal("shooted", bullet_position, bullet_direction)

func check_collisions(spaceship_collisions):
	if spaceship_collisions:
		if (collided_with_enemy(spaceship_collisions)):
			killed()
	

func restart_parameters():
	dead = false
	$CollisionShape2D.disabled = false
	position = get_viewport_rect().get_center()

func collided_with_enemy(spaceship_collisions):
	match spaceship_collisions.collider.name:
		"TileMap":
			return true
		_:
			return false

func killed():
	if (! dead):
		dead = true
		engine_off()
		$CollisionShape2D.set_deferred("disabled", true)
		$explosionSound.play()
		
		$ship.hide()
		$shipAnimations.play("explosion")
		emit_signal("died")
