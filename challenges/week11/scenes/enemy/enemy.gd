extends Sprite

signal destroyed

enum MOVEMENT {NONE, UP, DOWN, LEFT, RIGHT, LEFT_UP, LEFT_DOWN, RIGHT_UP, \
			  RIGHT_DOWN, STAY}

const DEGREES_RANGE : float = 22.5
const DEGREES_LEFT : int = 0
const DEGREES_RIGHT : int = 180
const DEGREES_UP : int = 90
const DEGREES_DOWN : int = -90
const DEGREES_LEFT_UP : int = 45
const DEGREES_RIGHT_UP : int = 135
const DEGREES_RIGHT_DOWN : int = -135
const DEGREES_LEFT_DOWN : int = -45
			
var sprite_size : int  = 20

var death : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemy")

func move(player_position : Vector2):
	
	if not death:

		match get_next_move(player_position):
			MOVEMENT.UP:
				position.y -= sprite_size
			MOVEMENT.DOWN:
				position.y += sprite_size
			MOVEMENT.LEFT:
				position.x -= sprite_size
			MOVEMENT.RIGHT:
				position.x += sprite_size
			MOVEMENT.LEFT_UP:
				position.x -= sprite_size
				position.y -= sprite_size
			MOVEMENT.LEFT_DOWN:
				position.x -= sprite_size
				position.y += sprite_size
			MOVEMENT.RIGHT_UP:
				position.x += sprite_size
				position.y -= sprite_size
			MOVEMENT.RIGHT_DOWN:
				position.x += sprite_size
				position.y += sprite_size
			
func get_next_move(player_position : Vector2):
	
	var degree = rad2deg(position.angle_to_point(player_position))
	
	if degree >= (DEGREES_LEFT - DEGREES_RANGE) and degree <= (DEGREES_LEFT + DEGREES_RANGE):
		return MOVEMENT.LEFT
	elif degree > (DEGREES_LEFT_UP - DEGREES_RANGE) and degree <= (DEGREES_LEFT_UP + DEGREES_RANGE):
		return MOVEMENT.LEFT_UP
	elif degree > (DEGREES_UP - DEGREES_RANGE) and degree <= (DEGREES_UP + DEGREES_RANGE):
		return MOVEMENT.UP
	elif degree > (DEGREES_RIGHT_UP - DEGREES_RANGE) and degree <= (DEGREES_RIGHT_UP + DEGREES_RANGE):
		return MOVEMENT.RIGHT_UP
	elif degree > (DEGREES_RIGHT - DEGREES_RANGE) or degree <= -(DEGREES_RIGHT - DEGREES_RANGE):
		return MOVEMENT.RIGHT
	elif degree > (DEGREES_RIGHT_DOWN - DEGREES_RANGE) and degree <= (DEGREES_RIGHT_DOWN + DEGREES_RANGE): #  -157.5 and degree <= -112.5:
		return MOVEMENT.RIGHT_DOWN
	elif degree > (DEGREES_DOWN - DEGREES_RANGE) and degree <= (DEGREES_DOWN + DEGREES_RANGE): #   -112.5 and degree <= -67.5: 
		return MOVEMENT.DOWN
	elif degree > (DEGREES_LEFT_DOWN - DEGREES_RANGE) and degree <= (DEGREES_LEFT_DOWN + DEGREES_RANGE): #  -67.5 and degree < -22.5:
		return MOVEMENT.LEFT_DOWN
		
func destroy():
	hide()
	death = true
	emit_signal("destroyed")
	
func flush():
	if death:
		queue_free()
