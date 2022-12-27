extends CanvasLayer

const position_vector : Vector2 = Vector2(-10, 35)
const middle_canvas : float = 440.0

var red_dot : Texture = preload("res://common/gfx/circles/red_dot.webp")

var mini_cities : Array = [["Lisbon", 53.75],
						   ["Seville", 96.75],
						   ["Paris", 139.75],
						   ["Rome", 225.75],
						   ["Copenhagen", 311.75],
						   ["Berlin", 376.25],
						   ["Budapest", 440.75],
						   ["Athens", 483.75],
						   ["Moscow", 591.25],
						   ["Beijing", 698.75],
						   ["Tokyo", 784.75]
						  ]


func _ready():
	randomize()
	$green_dot.position.x = mini_cities[1][1] - middle_canvas
	for city in mini_cities:
		create_city_in_minimap(city[0], city[1])

func create_city_in_minimap(city_name : String, city_position_x : float):
	var red_dot_node = Sprite.new()
	red_dot_node.texture = red_dot
	
	var new_position = Vector2(city_position_x - middle_canvas, rand_range(position_vector.x, position_vector.y))
	red_dot_node.global_position = new_position	
	get_node("Node2D/map").add_child(red_dot_node)
	
	var label = Label.new()
	label.text = city_name
	label.add_color_override("font_color_shadow", Color(0, 0, 0, 1))
	label.add_constant_override("shadow_as_outline", true)
	var pixel_word = label.text.length() * 2
	label.set_position(Vector2(new_position.x - pixel_word, new_position.y - 25))
	
	get_node("Node2D/map").add_child(label)
	
func update_green_dot(tour : float):
	var mini_tour = tour / 48
	
	if $green_dot.position.x > 440:
		$green_dot.position.x = -440
	if $green_dot.position.x < -440:
		$green_dot.position.x = 440
	
	$green_dot.position.x += mini_tour
	
	
	
	
	
	
	
	
