extends RigidBody2D

signal hit

const MAX_IMPULSE = 1500
const IMPULSE_RATIO = 5

var dragged : bool = false
var reset_position : bool = true
var reach_hole : bool = true
var start_position : Vector2
var playing : bool = false

func _ready():
	$direction.hide()

func _input(event):
	if event is InputEventMouseButton and not event.is_pressed() and dragged:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var mouse_position = event.position
		var direction = mouse_position.direction_to(position).normalized()
		var velocity_by_length = mouse_position.distance_to(position) * IMPULSE_RATIO
		var velocity = clamp(velocity_by_length, velocity_by_length, MAX_IMPULSE)
		apply_central_impulse(direction * velocity)
		dragged = false
		$direction.hide()
		emit_signal("hit")


func _physics_process(delta):
	if dragged:
		update_direction_arrow()

func _on_ball_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and ball_is_stopped() and event.is_pressed():
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		dragged = true
		$direction.show()

func in_hole():
	hide()
	input_pickable = false
	$InHoleSound.play()
	contact_monitor = false
	sleeping = true
	reach_hole = true


func _integrate_forces(state):
	if reset_position:
		state.transform.origin = start_position
		contact_monitor = true
		reset_position = false
		input_pickable = true
	
	if reach_hole:
		state.transform.origin = Vector2(0,0)
		reach_hole = false
		
func ball_is_stopped() -> bool:
	return sleeping

func update_direction_arrow():
	$direction.rotation = get_viewport().get_mouse_position().angle_to_point(position) + deg2rad(-90)
	
func start_position(i_position : Vector2):
	reset_position = true
	start_position = i_position


func _on_ball_body_entered(body):
	if body.name == "StaticBody2D" and playing:
		$WallSound.play()
