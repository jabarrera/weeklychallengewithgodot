extends KinematicBody2D

var right = Vector2(1, 0)
var left = Vector2(-1, 0)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var stop = Vector2(0, 0)

var direction = stop
var velocity = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	position = get_viewport_rect().get_center()


func _input(event):
	if (Input.is_action_just_pressed("ui_down")):
		direction = down
		$Sprite.play("down")
	elif (Input.is_action_just_pressed("ui_up")):
		direction = up
		$Sprite.play("up")
	elif (Input.is_action_just_pressed("ui_left")):
		direction = left
		$Sprite.play("left")
	elif (Input.is_action_just_pressed("ui_right")):
		direction = right
		$Sprite.play("right")
		
	if (Input.is_action_just_released("ui_down") or
		Input.is_action_just_released("ui_up") or
		Input.is_action_just_released("ui_left") or
		Input.is_action_just_released("ui_right")):
			direction = stop
			$Sprite.play("idle")
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement = direction * velocity * delta
	
	move_and_collide(movement)
	
