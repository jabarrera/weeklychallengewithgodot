extends Node

func hide_mouse_pointer():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func show_mouse_pointer():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func left_button_clic(event : InputEventMouseButton) -> bool:
	return event is InputEventMouseButton and event.is_pressed() and \
			event.get_button_index() == BUTTON_LEFT
