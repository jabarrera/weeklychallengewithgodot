extends Area2D

signal destination(new_location)
signal destination_reached

const STOP_ENGINE_NOT_MOVING = -5.0
const STOP_ENGINE_MOVING = -20.0
const TANK_VELOCITY : float = 40.0

var im_moving : bool = false
var mouse_under_me : bool = false
var time_get_new_position : int = 5


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and $SelectionMark.visible and not mouse_under_me:
		var original_target = $NavigationAgent2D.get_final_location()
		$NavigationAgent2D.set_target_location(event.global_position)
			
		if (not $NavigationAgent2D.is_target_reachable()):
			$NavigationAgent2D.set_target_location(original_target)
			$Error.play()
		else:
			$SelectionMark.visible = false
			emit_signal("destination", event.global_position)

func _ready():
	$NavigationAgent2D.set_target_location(position)
	rotation = deg2rad(100)
	$WaitTimer.start(randi() % time_get_new_position)
	$SelectionMark.hide()

func _physics_process(delta):
	if !$NavigationAgent2D.is_target_reached() and not $SelectionMark.visible:
		var target = $NavigationAgent2D.get_next_location()
		var direction = global_position.direction_to(target)
		global_rotation = lerp_angle(global_rotation, global_position.angle_to_point(target), 0.1)
		global_position += direction.normalized() * TANK_VELOCITY * delta
		if not $TankMoving.playing:
			$TankStop.volume_db = STOP_ENGINE_MOVING
			$TankMoving.play()
	else:
		if $TankMoving.playing:
			$TankMoving.stop()
		else:
			$TankStop.volume_db = STOP_ENGINE_NOT_MOVING
		
		if not $TankStop.playing:
			$TankStop.play()
		
		
func random_target_position():
	var new_location : Vector2
	while true:
		new_location.x = rand_range(0, get_viewport().size.x)
		new_location.y = rand_range(0, get_viewport().size.y)
		$NavigationAgent2D.set_target_location(new_location)
		if $NavigationAgent2D.is_target_reachable():
			emit_signal("destination", new_location)
			break


func _on_WaitTimer_timeout():
	random_target_position()

func _on_NavigationAgent2D_target_reached():
	$WaitTimer.start(randi() % time_get_new_position)
	emit_signal("destination_reached")


func _on_character_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		$SelectionMark.visible = not $SelectionMark.visible
		if ($SelectionMark.is_visible()):
			$WaitTimer.stop()

func _on_character_mouse_entered():
	mouse_under_me = true


func _on_character_mouse_exited():
	mouse_under_me = false
