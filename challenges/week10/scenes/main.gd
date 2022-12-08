extends Node

const MAX_PATH_LENGHT = 7400
const MIN_PATH_LENGHT = 300
const NUM_OBSTACLES = 20
const FLOOR_OBSTACLE = 420
const MAX_RETRIES_TO_CALCULATE_OBSTACLE_POSITION = 1000
const MIN_DISTANCE_BETWEEN_OBSTACLES = 200

var obstacles_scene = preload("res://challenges/week10/scenes/obstacle/obstacle.tscn")

var obstacles_y_positions : Array

var race_finished : bool = false

var playing : bool = false

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)

func _ready():
	playing = false
	add_to_group("obstacle")
	randomize()
	put_obstacles()
	$best_times.hide()
	$finishGame.hide()

func put_obstacles():
	for obstacle in NUM_OBSTACLES:
		var new_position : Vector2 = Vector2(rand_range(MIN_PATH_LENGHT, MAX_PATH_LENGHT), FLOOR_OBSTACLE)
		var retries = 0
		
		while not is_valid_obstacle_position(new_position) and retries <= MAX_RETRIES_TO_CALCULATE_OBSTACLE_POSITION:
			retries += 1
			new_position = Vector2(rand_range(MIN_PATH_LENGHT, MAX_PATH_LENGHT), FLOOR_OBSTACLE)
			
		create_obstacle(new_position)

func create_obstacle(i_position : Vector2):
	var obstacle_instance = obstacles_scene.instance()
	obstacle_instance.position = i_position
	obstacles_y_positions.append(i_position)
	
	#Connect obstacle with player character
	obstacle_instance.connect("area_entered", $character, "_obstacle_entered")
	obstacle_instance.connect("area_exited", $character, "_obstacle_exited")
	$obstacles.add_child(obstacle_instance)

func is_valid_obstacle_position(i_position : Vector2):
	if obstacles_y_positions.empty():
		return true
		
	for o_positions in obstacles_y_positions:
		if abs(i_position.x - o_positions.x) <= MIN_DISTANCE_BETWEEN_OBSTACLES:
			return false
			
	return true


func _on_character_race_finished():
	var race_time = $timer.stop_timer()
	race_finished = true
	$RaceFinishedSound.play()
	$character.not_playing()
	
	yield(get_tree().create_timer(1), "timeout")
	
	var new_record = $best_times.check_best_times(race_time)
	$best_times.show()
	
	if new_record:
		$NewRecordSound.play()
		$finishGame.configure("You got a new record!", Color(0, 0.9, 0, 0.5), \
			"res://challenges/week10/scenes/main.tscn")
	else:
		$finishGame.configure("Race finished", Color(0.9, 0, 0, 0.5), \
			"res://challenges/week10/scenes/main.tscn")

	$finishGame.show()


func _on_traffic_light_started():
	$timer.start_timer()
	$character.playing()


func _on_character_first_pressed():
	$traffic_light.hide()
