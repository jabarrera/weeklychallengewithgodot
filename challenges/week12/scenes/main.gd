extends Node

const VELOCITY : int = 400
const SCREEN_X_SIZE : int = 1024

var cities : Dictionary = {
	"1" : {
		"name":"Seville",
		"latitude":37.39,
		"longitude":-5.99,
		"image":"seville.webp"
	},
	"2": {
		"name":"Paris",
		"latitude":48.85,
		"longitude":2.35,
		"image":"paris.webp"
	},
	"3" : {
		"name":"Rome",
		"latitude":41.89,
		"longitude":12.48,
		"image":"rome.webp"
	},
	"4" : {
		"name":"Copenhagen",
		"latitude":55.6761,
		"longitude":12.5689,
		"image":"copenhagen.webp"
	},
	"5" : {
		"name":"Berlin",
		"latitude":52.5167,
		"longitude":13.3833,
		"image":"berlin.webp"
	},
	"6" : {
		"name":"Budapest",
		"latitude":52.5167,
		"longitude":13.3833,
		"image":"budapest.webp"
	},
	"7" : {
		"name":"Athens",
		"latitude":37.9842,
		"longitude":23.7281,
		"image":"athens.webp"
	},
	"8" : {
		"name":"Moscow",
		"latitude":55.7558,
		"longitude":37.6178,
		"image":"moscow.webp"
	},
	"9" : {
		"name":"Beijing",
		"latitude":39.9050,
		"longitude":116.3914,
		"image":"beijing.webp"
	},
	"10" : {
		"name":"Tokyo",
		"latitude":35.6897,
		"longitude":139.6922,
		"image":"tokyo.webp"
	},
	"11" : {
		"name":"Lisbon",
		"latitude":38.7452,
		"longitude":-9.1604,
		"image":"lisbon.webp"
	}
}

var cities_instances : Dictionary = {}

var scene_void = preload("res://challenges/week12/scenes/block/block.tscn")

var move_left : bool = false
var move_right : bool = false

var map : Array = ["0", "1", 
				"0", "2", 
				"0", "0", "0", "3", 
				"0", "0", "0", "4", 
				"0", "0", "5", 
				"0", "0", "6", 
				"0", "7", 
				"0", "0", "0", "0", "8",
				"0", "0", "0", "0", "9", 
				"0", "0", "0", "10",
				"0", "0", "0", "0", "0", "0", "11"
				]
				
var current_position : int = 1

var movement : float = 0.0

var no_city : Array

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)
		
	if Input.is_action_just_pressed("ui_left"):
		move_left = true
		move_right = false
		
	if Input.is_action_just_pressed("ui_right"):
		move_left = false
		move_right = true
		
	if Input.is_action_just_released("ui_left"):
		move_left = false
		
	if Input.is_action_just_released("ui_right"):
		move_right = false


func _ready():
	fill_scenes()


func _process(delta):
	if move_left:
		$carrusel.position.x += VELOCITY * delta
		movement += VELOCITY * delta
		$minimap.update_green_dot(-VELOCITY * delta)
		if movement >= SCREEN_X_SIZE:
			movement = 0
			current_position -= 1
			fill_scenes()
		
	if move_right:
		$carrusel.position.x -= VELOCITY * delta
		movement -= VELOCITY * delta
		$minimap.update_green_dot(VELOCITY * delta)
		if movement <= -SCREEN_X_SIZE:
			movement = 0
			current_position += 1
			fill_scenes()
	
func fill_scenes():
	current_position = normalize_map_index(current_position)
	
	var right_position = normalize_map_index(current_position - 1)
	var left_position =  normalize_map_index(current_position + 1)
	
	var central_scene = get_scene(current_position, 0)
	var right_scene = get_scene(right_position, 1)
	var left_scene = get_scene(left_position, -1)
	
	if $carrusel/right.get_child(0) != null and $carrusel/right.get_child(0).city_name.empty():
		no_city.push_back($carrusel/right.get_child(0))
		
	if $carrusel/center.get_child(0) != null and $carrusel/center.get_child(0).city_name.empty():
		no_city.push_back($carrusel/center.get_child(0))
		
	if $carrusel/left.get_child(0) != null and $carrusel/left.get_child(0).city_name.empty():
		no_city.push_back($carrusel/left.get_child(0))
		
	$carrusel/right.remove_child($carrusel/right.get_child(0))
	$carrusel/center.remove_child($carrusel/center.get_child(0))
	$carrusel/left.remove_child($carrusel/left.get_child(0))
	
	$carrusel/right.add_child(right_scene)
	$carrusel/center.add_child(central_scene)
	$carrusel/left.add_child(left_scene)
	
	$carrusel.position.x = 0
	
func get_scene(scene, position_scene) -> Node2D:

	var scene_created
	
	if map[scene] != "0":
		scene_created = cities_instances.get(map[scene])
	else:
		scene_created = no_city.pop_back()
	
	if scene_created == null:
		scene_created = scene_void.instance()
	
	if map[scene] != "0":
		if scene_created.http_request == null:
			var http_request : HTTPRequest = HTTPRequest.new()
			add_child(http_request)
			scene_created.http_request = http_request
		
		scene_created.get_weather_info(cities.get(str(map[scene])).get("latitude"), \
			cities.get(str(map[scene])).get("longitude"))

		scene_created.city_name = cities.get(str(map[scene])).get("name")
		scene_created.set_city_image(cities.get(str(map[scene])).get("image"))
		cities_instances.newKey = map[scene]
		cities_instances[map[scene]] = scene_created
		
	return scene_created


func normalize_map_index(index : int) -> int:
	if index < 0:
		return map.size() - 1
		
	if index >= map.size():
		return index - map.size()
		
	return index
