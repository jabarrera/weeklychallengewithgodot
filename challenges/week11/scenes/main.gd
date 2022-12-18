extends Node

enum MOVEMENT {NONE, UP, DOWN, LEFT, RIGHT, LEFT_UP, LEFT_DOWN, RIGHT_UP, \
			  RIGHT_DOWN, STAY}
			
const NUM_ENEMIES : int = 100

const DEGREES_RANGE : float = 22.5
const DEGREES_LEFT : int = 0
const DEGREES_RIGHT : int = 180
const DEGREES_UP : int = 90
const DEGREES_DOWN : int = -90
const DEGREES_LEFT_UP : int = 45
const DEGREES_RIGHT_UP : int = 135
const DEGREES_RIGHT_DOWN : int = -135
const DEGREES_LEFT_DOWN : int = -45

const TELEPORT_COOLDOWN_TURNS : int = 2
const TELEPORT_RETRIES : int = 3

var enemy_scene = preload("res://challenges/week11/scenes/enemy/enemy.tscn")

var arrow_up         : Texture = preload("res://common/gfx/mouse/arrow_up.webp")
var arrow_right_up   : Texture = preload("res://common/gfx/mouse/arrow_r_u.webp")
var arrow_right      : Texture = preload("res://common/gfx/mouse/arrow_right.webp")
var arrow_right_down : Texture = preload("res://common/gfx/mouse/arrow_r_d.webp")
var arrow_down       : Texture = preload("res://common/gfx/mouse/arrow_down.webp")
var arrow_left_down  : Texture = preload("res://common/gfx/mouse/arrow_l_d.webp")
var arrow_left       : Texture = preload("res://common/gfx/mouse/arrow_left.webp")
var arrow_left_up    : Texture = preload("res://common/gfx/mouse/arrow_l_u.webp")
var arrow_equal      : Texture = preload("res://common/gfx/mouse/equal.webp")

var current_mouse_action = MOVEMENT.NONE

var dead : bool = false
var won : bool = false

var teleportation_turn_consumed : int = 0
var cooldown_active : bool = false

var num_enemy_destroyed : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$teleport_mark.hide()
	$finishGame.hide()
	Mouse.hide_mouse_pointer()
	put_enemies()
	put_player()

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)
		
	if event is InputEventMouseMotion and not dead and not won:
		update_mouse_pointer()
		
	if Mouse.left_button_clic(event) and current_mouse_action != MOVEMENT.NONE and not dead and not won:
		if $player.move_if_valid($map.ORIGIN_SQUARE_MAP, $map.END_SQUARE_MAP, current_mouse_action):
			$sfx/playerMoveSound.play()
			update_mouse_pointer()
		else:
			$sfx/errorSound.play()
			
func _on_player_moved():
	
	#check player is in safe place or die
	if not safe_place_for_player():
		lost_life()
	
	#move enemies
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "enemy", "move", $player.position)
	check_destruction()
	
	$player.can_move()
	
	#check teleportation cooldown
	if cooldown_active:
		teleportation_turn_consumed += 1
		if (teleportation_turn_consumed >= TELEPORT_COOLDOWN_TURNS):
			cooldown_active = false
			$teleportation_button.disabled = false
			teleportation_turn_consumed = 0

func put_enemies():
	for i in NUM_ENEMIES:
		var enemy_instance = enemy_scene.instance()
		enemy_instance.position = $map.get_free_position()
		enemy_instance.connect("destroyed", self, "_enemy_destroyed")
		$enemies.add_child(enemy_instance)

func check_destruction():
	
	var player_died = false
	var destroy_robot_sound = false
	
	for enemy_index in $enemies.get_child_count():
		var enemy_to_compare = $enemies.get_children()[enemy_index]
		#check player died
		if not enemy_to_compare.death:
			if enemy_to_compare.position == $player.position:
				player_died = true
				$map.set_radioactive_zone(enemy_to_compare.position)
				enemy_to_compare.destroy()
				destroy_robot_sound = true
			else:
				#check radioactive zone
				if $map.is_radioactive_zone(enemy_to_compare.position) and not enemy_to_compare.death:
					$map.set_radioactive_zone(enemy_to_compare.position)
					enemy_to_compare.destroy()
					destroy_robot_sound = true
				else:
					var destroy_robot = false
					for enemy in $enemies.get_children().slice(enemy_index + 1, $enemies.get_children().size()):
						if not enemy.death and enemy_to_compare.position == enemy.position:
							$map.set_radioactive_zone(enemy.position)
							enemy.destroy()
							destroy_robot = true
							destroy_robot_sound = true
					if destroy_robot:
						enemy_to_compare.destroy()
					
	if destroy_robot_sound:
		$sfx/destructionSound.play()
		
	flush_death_enemies()
	
	if player_died:
		lost_life()
		
	check_all_enemies_destroyed()
	
func _on_player_jumping():
	player_blind_jumping()

func update_mouse_pointer():
	set_mouse_icon_from_player()
	$mouse_pointer.position = get_viewport().get_mouse_position()
	
func set_mouse_icon_from_player():
	
	if not $map.over_map($mouse_pointer.position):
		Mouse.show_mouse_pointer()
		$mouse_pointer.hide()
		current_mouse_action = MOVEMENT.NONE
		return
	
	if not dead and not won:
		Mouse.hide_mouse_pointer()
		$mouse_pointer.show()
		
	if $player.over_player($mouse_pointer.position):
		$mouse_pointer.texture = arrow_equal
		current_mouse_action = MOVEMENT.STAY
	else:
		var degree = rad2deg($player.position.angle_to_point($mouse_pointer.position))
		
		if degree >= (DEGREES_LEFT - DEGREES_RANGE) and degree <= (DEGREES_LEFT + DEGREES_RANGE):
			$mouse_pointer.texture = arrow_left
			current_mouse_action = MOVEMENT.LEFT
		elif degree > (DEGREES_LEFT_UP - DEGREES_RANGE) and degree <= (DEGREES_LEFT_UP + DEGREES_RANGE):
			$mouse_pointer.texture = arrow_left_up
			current_mouse_action = MOVEMENT.LEFT_UP
		elif degree > (DEGREES_UP - DEGREES_RANGE) and degree <= (DEGREES_UP + DEGREES_RANGE):
			$mouse_pointer.texture = arrow_up
			current_mouse_action = MOVEMENT.UP
		elif degree > (DEGREES_RIGHT_UP - DEGREES_RANGE) and degree <= (DEGREES_RIGHT_UP + DEGREES_RANGE):
			$mouse_pointer.texture = arrow_right_up
			current_mouse_action = MOVEMENT.RIGHT_UP
		elif degree > (DEGREES_RIGHT - DEGREES_RANGE) or degree <= -(DEGREES_RIGHT - DEGREES_RANGE):
			$mouse_pointer.texture = arrow_right
			current_mouse_action = MOVEMENT.RIGHT
		elif degree > (DEGREES_RIGHT_DOWN - DEGREES_RANGE) and degree <= (DEGREES_RIGHT_DOWN + DEGREES_RANGE): #  -157.5 and degree <= -112.5:
			$mouse_pointer.texture = arrow_right_down
			current_mouse_action = MOVEMENT.RIGHT_DOWN
		elif degree > (DEGREES_DOWN - DEGREES_RANGE) and degree <= (DEGREES_DOWN + DEGREES_RANGE): #   -112.5 and degree <= -67.5: 
			$mouse_pointer.texture = arrow_down
			current_mouse_action = MOVEMENT.DOWN
		elif degree > (DEGREES_LEFT_DOWN - DEGREES_RANGE) and degree <= (DEGREES_LEFT_DOWN + DEGREES_RANGE): #  -67.5 and degree < -22.5:
			$mouse_pointer.texture = arrow_left_down
			current_mouse_action = MOVEMENT.LEFT_DOWN

func lost_life():
	$sfx/LostLifeSound.play()
	$lives.emit_signal("life_lost")

func safe_place_for_player() -> bool:
	for enemy in $enemies.get_children():
		if $player.position == enemy.position:
			$map.set_radioactive_zone(enemy.position)
			enemy.destroy()
			flush_death_enemies()
			return false
			
	if $map.is_radioactive_zone($player.position):
		return false
		
	return true


func _on_lives_life_empty():
	dead = true
	$finishGame.configure("Game over!", Color(0.5, 0, 0, 0.5), \
			"res://challenges/week11/scenes/main.tscn")
			
	$mouse_pointer.hide()
	Mouse.show_mouse_pointer()
	$finishGame.enable_button_timer(0.5)
	$finishGame.show()

func player_blind_jumping():
	var teleport_position : Vector2
	for retry_teleport in TELEPORT_RETRIES:
		teleport_position = $map.get_free_position()
		$sfx/teleportWarningSound.play()
		show_teleport_mark(teleport_position)
		yield(get_tree().create_timer(1.0), "timeout")
	
	$teleport_mark.hide()
	$sfx/teleportMoveSound.play()
	$player.position = teleport_position
	
	#check player is in safe place or die
	if not safe_place_for_player():
		lost_life()
	

func _on_teleportation_button_button_up():
	$teleportation_button.disabled = true
	cooldown_active = true
	player_blind_jumping()

func check_all_enemies_destroyed():
	if num_enemy_destroyed >= NUM_ENEMIES:
		win()
		
func win():
	won = true
	$finishGame.configure("You win!", Color(0, 0.5, 0, 0.5), \
			"res://challenges/week11/scenes/main.tscn")
			
	$mouse_pointer.hide()
	Mouse.show_mouse_pointer()
	$sfx/winSound.play()
	$finishGame.enable_button_timer(0.5)
	$finishGame.show()

func flush_death_enemies():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "enemy", "flush")

func _enemy_destroyed():
	num_enemy_destroyed += 1

func show_teleport_mark(mark_position : Vector2):
	$teleport_mark.position = mark_position
	$teleport_mark.show()
	
func put_player():
	var safe_position : bool = false
	var player_position : Vector2
	
	while (not safe_position):
		var enemy_place : bool = false
		player_position = $map.get_free_position()
		for enemy in $enemies.get_children():
			if enemy.position == player_position:
				enemy_place = true
				break
		
		if not enemy_place:
			safe_position = true
	
	$player.position = player_position
	$player.can_move()
