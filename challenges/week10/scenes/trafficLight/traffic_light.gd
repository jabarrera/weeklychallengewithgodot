extends Node2D

signal started

enum TYPE_LIGHT {OFF, RED, GREEN}

const RED_LIGHT = Color(1, 0, 0, 1)
const GREEN_LIGHT = Color(0, 1, 0, 1)

const TEXT_WAITING = "Get ready!"
const TEXT_READY = "Run!"

var left_light = TYPE_LIGHT.OFF
var center_light = TYPE_LIGHT.OFF
var right_light = TYPE_LIGHT.OFF


func _ready():
	start_time()

func start_time():
	$Label.text = TEXT_WAITING
	$traffic_light_timer.start()


func _on_traffic_light_timer_timeout():
	
	if center_light == TYPE_LIGHT.RED and right_light != TYPE_LIGHT.RED:
		right_light = check_light(right_light, $lights/light_right)
	
	if left_light == TYPE_LIGHT.RED and center_light != TYPE_LIGHT.RED:
		center_light = check_light(center_light, $lights/light_center)
		
	if left_light != TYPE_LIGHT.GREEN:
		left_light = check_light(left_light, $lights/light_left)
		
	if all_lights_ready():
		yield(get_tree().create_timer(1), "timeout")
		all_lights_green()
		emit_signal("started")
	else:
		$traffic_light_timer.start(1)
	
	
func check_light(light, object : Polygon2D) -> int:
	
	match(light):
		TYPE_LIGHT.OFF:
			sound()
			object.color = RED_LIGHT
			light = TYPE_LIGHT.RED
	
	return light
		
			
func all_lights_ready():
	return left_light == TYPE_LIGHT.RED and \
			center_light == TYPE_LIGHT.RED and \
			right_light == TYPE_LIGHT.RED
			
func all_lights_green():
	sound()
	$lights/light_left.color = GREEN_LIGHT
	left_light = TYPE_LIGHT.GREEN
	$lights/light_center.color = GREEN_LIGHT
	center_light = TYPE_LIGHT.GREEN
	$lights/light_right.color = GREEN_LIGHT
	right_light = TYPE_LIGHT.GREEN

	$Label.text = TEXT_READY

func sound():
	$BeepSound.play()
