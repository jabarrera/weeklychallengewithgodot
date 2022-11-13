extends Area2D


var up : bool = false
var down : bool = false
var left : bool = false
var right : bool = false

var direction : Vector2 = Vector2(0, 0)

var velocity : int = 200

var picked_object : Area2D = null

var direction_flip : bool = false


func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		up = true
	
	if Input.is_action_just_pressed("ui_down"):
		down = true
	
	if Input.is_action_just_pressed("ui_left"):
		left = true
		direction_flip = false
	
	if Input.is_action_just_pressed("ui_right"):
		right = true
		direction_flip = true
		
	if Input.is_action_just_released("ui_up"):
		up = false
	
	if Input.is_action_just_released("ui_down"):
		down = false
	
	if Input.is_action_just_released("ui_left"):
		left = false
	
	if Input.is_action_just_released("ui_right"):
		right = false
		
	if (Input.is_key_pressed(KEY_SPACE)):
		if picked_object == null:
			pick_object()
		else:
			leave_object()
			


func _physics_process(delta):
	update_direction()
	update_picked_object()
	
	var new_position = position + direction * velocity * delta
	if can_move(new_position):
		position = new_position


func can_move(new_position) -> bool:
	if new_position.x >= 0 and new_position.x <= get_viewport_rect().size.x and new_position.y >= 0 and new_position.y <= get_viewport_rect().size.y:
		return true
	else:
		$ForbiddenStreamPlayer.play()
		return false
	
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
		$Sprite.flip_h = direction_flip
		if picked_object != null:
			$Sprite.play("full_walking")
		else:
			$Sprite.play("empty_walking")
	else:
		if picked_object != null:
			$Sprite.play("full_stop")
		else:
			$Sprite.play("empty_stop")
		

func pick_object():
	var areas = get_overlapping_areas()
	if picked_object == null and areas != null:
		$PickStreamPlayer.play()
		picked_object = areas[0]

func leave_object():
	$LeaveStreamPlayer.play()
	picked_object.global_position = $leftObjectPosition.global_position
	picked_object = null


func update_picked_object():
	if picked_object != null:
		picked_object.global_position = $PickedObjectPosition.global_position
