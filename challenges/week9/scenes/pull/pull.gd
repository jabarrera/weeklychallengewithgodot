extends Node2D

signal pulled

var running : bool = false
var hand_visible : bool = false

func _ready():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	$mouse_pointer.hide()
	$AnimatedSprite.play("default")
	
func _process(delta):
	if check_mouse_inside_area():
		show_hand_pointer()
	else:
		hide_hand_pointer()
		
	update_mouse_pointer()

func _on_Area2D_input_event(viewport, event, shape_idx):
	if left_button_clic(event) and not running:
		pull()
		

func left_button_clic(event : InputEventMouseButton) -> bool:
	return event is InputEventMouseButton and event.is_pressed() and \
			event.get_button_index() == BUTTON_LEFT

func pull():
	$PullSound.play()
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("pulling")
	emit_signal("pulled")


func _on_slot_running(b_running):
	running = b_running


func update_mouse_pointer():
	$mouse_pointer.global_position = get_viewport().get_mouse_position()

func check_mouse_inside_area():
	if not running:
		var collideds = $mouse_pointer/Area2D.get_overlapping_areas()
		for collided in collideds:
			if collided.name == "pull_sphere":
				return true
			
	return false
	
func show_hand_pointer():
	if not hand_visible:
		hand_visible = true
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func hide_hand_pointer():
	if hand_visible:
		hand_visible = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
