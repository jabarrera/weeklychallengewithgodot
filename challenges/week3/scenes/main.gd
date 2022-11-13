extends Node

signal guess_in_the_door(door)
signal shoot
signal reload

enum character_type { WOMAN, BANDIT, HATTER }

const MAX_SHOOTS : int = 5

var playing : bool = true

var bandit_pool: Array
var woman_pool: Array
var hatter_pool: Array

var num_shoots : int = 5
var money_earned : int = 0

var woman_scene = preload("res://challenges/week3/scenes/characters/woman/woman.tscn")
var bandit_scene = preload("res://challenges/week3/scenes/characters/bandit/bandit.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if (playing):
		$diedMessage.hide()
		hide_mouse_pointer()
		earn_money(0)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			shoot()
		elif event.button_index == BUTTON_RIGHT and event.pressed:
			reload()
			
	if Input.is_action_pressed("ui_cancel"):
		show_mouse_pointer()
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_mouse_pointer()


func update_mouse_pointer():
	$mouse_pointer.position = get_viewport().get_mouse_position()

func hide_mouse_pointer():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func show_mouse_pointer():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_left_door_waiting_guess():
	prepare_door($characters/left_door, $characters/left_door/left_door_character_position, $doors/left_door)

func _on_center_door_waiting_guess():
	remove_previous_guess($characters/center_door)
	prepare_door($characters/center_door, $characters/center_door/center_door_character_position, $doors/center_door)
		

func _on_right_door_waiting_guess():
	prepare_door($characters/right_door, $characters/right_door/right_door_character_position, $doors/right_door)
	
func prepare_door(character_door, door_position, door):
	remove_previous_guess(character_door)
	var new_character_type = character_type.get(character_type.keys()[randi() % character_type.size()])
	var new_character_instance = get_character_scene(new_character_type)
	
	if (new_character_instance != null):
		new_character_instance.global_position = door_position.global_position
		character_door.add_child(new_character_instance)
		door.filled()

func get_character_scene(new_character_type):
	match new_character_type:
		character_type.WOMAN:
			return get_woman()
		character_type.BANDIT:
			return get_bandit()
		character_type.HATTER:
			return get_woman()
			
func get_woman():
	var woman_instance = woman_pool.pop_back()
	
	if (woman_instance == null):
		woman_instance = woman_scene.instance()
		woman_instance.connect("woman_hit", self, "_innocent_touched")
		$bullets.connect("empty_bullets", woman_instance, "_empty_bullets")
		$bullets.connect("have_bullets", woman_instance, "_have_bullets")

	return woman_instance
	
func get_bandit():
	var bandit_instance = bandit_pool.pop_back()
	
	if (bandit_instance == null):
		bandit_instance = bandit_scene.instance()
		bandit_instance.connect("bandit_died", self, "_bandit_died")
		bandit_instance.connect("bandit_shoot", self, "_bandit_shoot")
		$bullets.connect("empty_bullets", bandit_instance, "_empty_bullets")
		$bullets.connect("have_bullets", bandit_instance, "_have_bullets")

	return bandit_instance
	
func get_hatter():
	return get_woman()

func remove_previous_guess(door : Node):
	for node in door.get_children():
		if (node is Area2D):
			pool_node(node)
			node.get_parent().remove_child(node)

func pool_node(node):
	match (node.type):
		character_type.WOMAN:
			woman_pool.push_back(node)
		character_type.BANDIT:
			node.bandit_init()
			bandit_pool.push_back(node)
		character_type.HATTER:
			hatter_pool.push_back(node)
			
func _innocent_touched():
	game_over()

func _bandit_died():
	pass

func _bandit_shoot():
	game_over()
	
	
func game_over():
	$characters.set_process(false)
	for door in $doors.get_children():
		door.stop()
	playing = false
	$diedMessage.show()

func shoot():
	if num_shoots > 0 and playing:
		num_shoots -= 1
		emit_signal("shoot")
		$sfx/shoot.play()
	
func reload():
	num_shoots = MAX_SHOOTS
	emit_signal("reload")
	$sfx/reload.play()


func _on_left_door_door_open():
	check_is_bandit($characters/left_door)
	
func _on_center_door_door_open():
	check_is_bandit($characters/center_door)

func _on_right_door_door_open():
	check_is_bandit($characters/right_door)


func check_is_bandit(node : Node):
	var character = node.get_node_or_null("bandit")
	if character != null:
		character.start_time_shoot()
	
func check_is_customer(node : Node):
	var character = node.get_node_or_null("woman")
	if character != null:
		earn_money(character.money_deposit)


func _on_left_door_door_closed():
	check_is_customer($characters/left_door)


func _on_center_door_door_closed():
	check_is_customer($characters/center_door)


func _on_right_door_door_closed():
	check_is_customer($characters/right_door)
	
func earn_money(money : int):
	money_earned += money
	$money.text = str(money_earned) + "€"
