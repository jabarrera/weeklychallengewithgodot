extends Sprite

signal moved
signal jumping

enum MOVEMENT {NONE, UP, DOWN, LEFT, RIGHT, LEFT_UP, LEFT_DOWN, RIGHT_UP, \
			  RIGHT_DOWN, STAY}

const SPRITE_SIZE : int  = 20
const SPRITE_SIZE_MIDDLE : float = SPRITE_SIZE * 0.5

var move = MOVEMENT.NONE
var moving : bool = false


func move_if_valid(origin_map : Vector2, end_map : Vector2, action) -> bool:
	var final_position : Vector2 = position
	
	match action:
		MOVEMENT.UP:
			final_position.y = position.y - SPRITE_SIZE
		MOVEMENT.DOWN:
			final_position.y = position.y + SPRITE_SIZE
		MOVEMENT.LEFT:
			final_position.x = position.x - SPRITE_SIZE
		MOVEMENT.RIGHT:
			final_position.x = position.x + SPRITE_SIZE
		MOVEMENT.LEFT_UP:
			final_position.x = position.x - SPRITE_SIZE
			final_position.y = position.y - SPRITE_SIZE
		MOVEMENT.LEFT_DOWN:
			final_position.x = position.x - SPRITE_SIZE
			final_position.y = position.y + SPRITE_SIZE
		MOVEMENT.RIGHT_UP:
			final_position.x = position.x + SPRITE_SIZE
			final_position.y = position.y - SPRITE_SIZE
		MOVEMENT.RIGHT_DOWN:
			final_position.x = position.x + SPRITE_SIZE
			final_position.y = position.y + SPRITE_SIZE
			
	if valid_movement(origin_map, end_map, final_position):
		moving = false
		position = final_position
		emit_signal("moved")
		return true
	else:
		return false
	
	
func can_move():
	moving = true
	
func over_player(i_position : Vector2) -> bool:
	if (i_position.x >= position.x - SPRITE_SIZE_MIDDLE) and \
	   (i_position.x <= position.x + SPRITE_SIZE_MIDDLE) and \
	   (i_position.y >= position.y - SPRITE_SIZE_MIDDLE) and \
	   (i_position.y <= position.y + SPRITE_SIZE_MIDDLE):
		return true
	else:
		return false

func valid_movement(origin_map : Vector2, end_map: Vector2, i_position : Vector2) -> bool:
	if (i_position.x >= origin_map.x) and (i_position.x <= end_map.x) and \
	   (i_position.y >= origin_map.y) and (i_position.y <= end_map.y):
		return true
	else:
		return false
