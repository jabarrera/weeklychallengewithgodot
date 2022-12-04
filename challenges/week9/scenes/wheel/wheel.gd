extends Node2D

signal result(item)

const ESPECIAL_ITEM = 5

export var wheel_number : int = 1

var apple_image = preload("res://challenges/week4/gfx/cards/apple.png")
var orange_image = preload("res://challenges/week4/gfx/cards/orange.png")
var strawberry_image = preload("res://challenges/week4/gfx/cards/strawberry.png")
var pineapple_image = preload("res://challenges/week4/gfx/cards/pineapple.png")
var cherry_image = preload("res://challenges/week4/gfx/cards/cherry.png")
var money_image = preload("res://common/gfx/cards/money.webp")


var items : Array = [cherry_image, pineapple_image, strawberry_image, \
					 orange_image, apple_image, money_image]
					
var wheel_items : Array =   [0, 0, 0, 0, 0, 0, 0, 0, 0, \
							 1, 1, 1, 1, 1, 1, 1, 1, 1, \
							 2, 2, 2, 2, 2, 2, 2, 2, 2, \
							 3, 3, 3, 3, 3, 3, 3, 3, 3, \
							 4, 4, 4, 4, 4, 4, 4, 4, 4, \
							 5, 5, 5, 5, 5]
							
var current_wheel : int = 0

var running : bool = false


func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		current_wheel = get_current_wheel_down(current_wheel + 1)
		fill_items()

	if Input.is_action_just_pressed("ui_up"):
		current_wheel = get_current_wheel_down(current_wheel - 1)
		fill_items()

func _ready():
	seed(wheel_number)
	wheel_items.shuffle()
	fill_items()
	randomize()


func fill_items():
	$items/item_down.set_item(get_item_and_image(get_current_wheel_down(current_wheel)))
	$items/item_middle.set_item(get_item_and_image(get_current_wheel_down(current_wheel + 1)))
	$items/item_up.set_item(get_item_and_image(get_current_wheel_down(current_wheel + 2)))

func get_current_wheel_down(i_current_wheel : int):
	
	if i_current_wheel >= 0 and i_current_wheel < wheel_items.size():
		return i_current_wheel
		
	if i_current_wheel < 0:
		return wheel_items.size() - 1
		
	if i_current_wheel >= wheel_items.size():
		return i_current_wheel - wheel_items.size()


func run():
	$wheel_timer.start(0.8)
	yield(get_tree().create_timer(0.4), "timeout")
	
	$wheel_timer.start(0.4)
	yield(get_tree().create_timer(0.2), "timeout")

	$wheel_timer.start()
	$wheel_timer.start(0.1)
	yield(get_tree().create_timer(rand_range(3, 8)), "timeout")
	
	$wheel_timer.start(0.5)
	yield(get_tree().create_timer(1), "timeout")
	
	$wheel_timer.start(0.8)
	yield(get_tree().create_timer(0.4), "timeout")
	
	$wheel_timer.start(0.4)
	yield(get_tree().create_timer(0.2), "timeout")
	
	$wheel_timer.stop()
		
	emit_signal("result", get_result())


func _on_wheel_timer_timeout():
	$Wheel_turning_audio.play()
	current_wheel = get_current_wheel_down(current_wheel + 1)
	fill_items()

func get_result():
	return $items/item_middle.item_type

#Return array:
#[0]: item type
#[1]: item image
func get_item_and_image(item):
	return [wheel_items[get_current_wheel_down(item)], items[ wheel_items[get_current_wheel_down(item)] ] ]

#Return item middle type
func move_up():
	current_wheel = get_current_wheel_down(current_wheel - 1)
	fill_items()
	return get_result()

#Return item middle type	
func move_down():
	current_wheel = get_current_wheel_down(current_wheel + 1)
	fill_items()
	return get_result()
