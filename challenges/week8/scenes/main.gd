extends Node

signal damaged_by_lava(amount)

const MAX_NUM_BUSHES = 15
const MAX_PLAYMAP_SIZE_X = 780
const MAX_PLAYMAP_SIZE_Y = 600
const MIN_PLAYMAP_SIZE_Y = 20
const NUM_SECONDS_TO_FINISH = 60

#Lava const
const MAX_TIME_SHOW_LAVA = 15
const MIN_TIME_SHOW_LAVA = 5
const MAX_TIME_LAVA_LIFE = 10
const MIN_TIME_LAVA_LIFE = 5
const MAX_NUM_LAVA_ZONES = 150
const LIFE_LOST_BY_LAVA = 5

var bushes_scene : PackedScene = preload("res://challenges/week8/scenes/bush/bush.tscn")
var key_scene : PackedScene = preload("res://challenges/week8/scenes/key/key.tscn") 

var key_found : bool = false
var key_created : bool = false
var percentage_found_key = 10

var time_seconds : int = 60
var time_h_seconds : int = 99

var time : float = 60000
var new_time : float = time

var running_timer : bool = true

var bushes_alive : int = MAX_NUM_BUSHES


func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)
		
func _ready():
	randomize()
	random_character_position()
	$finishGame.hide()
	$sfx/Music.play()
	init_bushes()
	start_lava()
	
func _physics_process(delta):
	if running_timer:
		time -= delta
		
		time_h_seconds = fmod(time, 1) * 100
		time_seconds = fmod(time, NUM_SECONDS_TO_FINISH)
		$timer/h_seconds.text = "." + str(time_h_seconds)
		$timer/seconds.text = str(time_seconds)
		
		if (time_seconds <= 0.0 and time_h_seconds <= 10):
			running_timer = false
			$timer/h_seconds.text = "." + str(00)
			$timer/seconds.text = str(0)
			lose()
		

func init_bushes():
	for i in MAX_NUM_BUSHES:
		var bush = bushes_scene.instance()
		bush.position.x = rand_range(0, MAX_PLAYMAP_SIZE_X)
		bush.position.y = rand_range(MIN_PLAYMAP_SIZE_Y, MAX_PLAYMAP_SIZE_Y)
		bush.connect("bush_destroyed", self, "_bush_destroyed")
		$bushes.add_child(bush)

func _bush_destroyed(i_position):
	bushes_alive -= 1
	if not key_created:
		var number = (randi() % 99) + 1
		if (number >= 1 and number <= percentage_found_key) or bushes_alive == 0:
			create_key(i_position)	
		
func create_key(i_position):
	key_created = true
	var key = key_scene.instance()
	key.position = i_position
	key.connect("key_captured", self, "_key_captured")
	key.connect("key_captured", $character, "_key_captured")
	add_child(key)

func _key_captured():
	$sfx/GetKeySound.play()
	key_found = true
	get_node("key").position = $Key_captured_position.position
	
func lose():
	$sfx/BurningSound.stop()
	$sfx/Music.stop()
	$sfx/GameOverSound.play()
	stop_all_timers()
	$character.velocity = 0
	running_timer = false
	$finishGame.configure("Game over!", Color(0.3, 0.0, 0, 0.4), "res://challenges/week8/scenes/main.tscn")
	$finishGame.show()
	
func win():
	$sfx/Music.stop()
	$sfx/WinSound.play()
	stop_all_timers()
	$character.velocity = 0
	running_timer = false
	$finishGame.configure("You win!", Color(0.3, 0.5, 0, 0.4), "res://challenges/week8/scenes/main.tscn")
	$finishGame.show()
	

func _on_winning_zone_timer_timeout():
	win()


func _on_winning_zone_body_entered(body):
	$winning_zone/winning_zone_timer.start()
	
func get_new_lava_show_time():
	return rand_range(MIN_TIME_SHOW_LAVA, MAX_TIME_SHOW_LAVA)

func start_lava():
	$lava_timers/lava_time_timer.wait_time = get_new_lava_show_time()
	$lava_timers/lava_time_timer.start()
	
func _on_lava_time_timer_timeout():
	$map.show_lava()
	$lava_timers/lava_life_timer.wait_time = rand_range(MIN_TIME_LAVA_LIFE, MAX_TIME_LAVA_LIFE)
	$lava_timers/lava_life_timer.start()
	$lava_timers/check_is_lava_timer.start()

func _on_lava_life_timer_timeout():
	$sfx/BurningSound.stop()
	$lava_timers/check_is_lava_timer.stop()
	$map.hide_lava()
	$map.random_lava(MAX_NUM_LAVA_ZONES)
	start_lava()
		
func _on_check_is_lava_timer_timeout():
	if $map.is_lava($character.global_position):
		if !$sfx/BurningSound.playing:
			$sfx/BurningSound.play()
		emit_signal("damaged_by_lava", LIFE_LOST_BY_LAVA)
	else:
		$sfx/BurningSound.stop()
		
func _on_life_empty_life():
	lose()

func stop_all_timers():
	$lava_timers/lava_time_timer.stop()
	$lava_timers/lava_life_timer.stop()
	$lava_timers/check_is_lava_timer.stop()

func random_character_position():
	var random_x = (randi() % 780) + 20
	var random_y = (randi() % 540) + 20
	$character.position = Vector2(random_x, random_y)
