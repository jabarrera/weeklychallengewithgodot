extends Area2D

signal race_finished
signal first_pressed

const VECTOR_RIGHT = Vector2(1, 0)
const VECTOR_UP = Vector2(1, -1)
const VECTOR_DOWN = Vector2(1, 1)
const MAX_VELOCITY = 500
const MAX_VELOCITY_UP = 500
const VELOCITY_STUCKED = 10

var base_floor : float = 450.0

var velocity : float = 0.0

var left_tap = 0
var right_tap = 0

var previous_taps = -1
var current_taps = -1

var direction : Vector2 = VECTOR_RIGHT

var left_pressed : bool = false
var right_pressed : bool = false

var step_1 : bool = false
var step_2 : bool = false

var jump : bool = false
var velocity_up : float = 2500

var stuck_in_obstacle : bool = false

var race_finished : bool = false

var playing : bool = false

#func _input(event):
#	if Input.is_action_just_pressed("ui_down"):
#		velocity = 2500

func _ready():
	playing = false
	base_floor = base_floor - $AnimatedSprite.frames.get_frame("default", 0).get_size().y * 0.5


func _process(delta):
	if not race_finished and playing:
		if Input.is_action_just_pressed("ui_left"):
			emit_signal("first_pressed")
			left_tap = OS.get_ticks_msec()
			left_pressed = true
			
		if Input.is_action_just_pressed("ui_right") and left_pressed:
			left_pressed = false
			right_tap = OS.get_ticks_msec()
			var ticks = right_tap - left_tap
			
			if (not step_1):
				previous_taps = ticks
			else:
				step_1 = false
				current_taps = ticks
		
		if Input.is_action_just_pressed("shoot") and on_floor() and not stuck_in_obstacle:
			$JumpSound.play()
			direction = VECTOR_UP
			jump = true
	
	if not stuck_in_obstacle:
		if (increase_velocity()):
			velocity += MAX_VELOCITY
			previous_taps = -1
			current_taps = -1
		else:
			velocity -= 0.5
			velocity = clamp(velocity, 0, 100)
	else:
		if playing:
			velocity = clamp(velocity, VELOCITY_STUCKED, VELOCITY_STUCKED)
		else:
			velocity = 0
	
	if jump:
		direction = VECTOR_UP
		velocity_up -= 15
		velocity_up = clamp(velocity_up, 0, MAX_VELOCITY_UP)
		if (velocity_up <= 0):
			direction = VECTOR_DOWN
			jump = false
	else:
		velocity_up += 9.8
		velocity_up = clamp(velocity_up, 0, MAX_VELOCITY_UP)
		
	position.x += direction.x * velocity * delta
	
	if (position.y < base_floor or jump):
		position.y += direction.y * velocity_up * delta
	else:
		position.y = base_floor

func increase_velocity() -> bool:
	return current_taps < previous_taps

func on_floor():
	return position.y == base_floor
	
func _obstacle_entered(i_area : Area2D):
	if not $ObstacleSound.playing:
		$ObstacleSound.play()
	stuck_in_obstacle = true
	
func _obstacle_exited(i_area : Area2D):
	$ObstacleSound.stop()
	stuck_in_obstacle = false

func _on_finish_area_entered(area):
	if area.name == "character":
		emit_signal("race_finished")
		race_finished = true

func not_playing():
	playing = false
	
func playing():
	playing = true
