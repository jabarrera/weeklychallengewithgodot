extends Node

var num_hits : int = 0

var map0 : PackedScene = preload("res://challenges/week13/scenes/maps/map0/map0.tscn")
var map1 : PackedScene = preload("res://challenges/week13/scenes/maps/map1/map1.tscn")
var map2 : PackedScene = preload("res://challenges/week13/scenes/maps/map2/map2.tscn")

var maps : Array = [map0, map1, map2]

var current_map : int = 0


func _ready():
	start_leader_board()
	$leader_board.hide()
	$finishGame.hide()
	start_new_map()
	update_ball_hits()

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)

func _on_hole_in_hole():
	$hole.monitoring = false
	$hole.playing = false
	$ball.playing = false
	$ball.in_hole()
	$ball.start_position(Vector2(-1000,-1000))
	current_map += 1
	if current_map > maps.size() -1:
		finish_game()
	else:
		start_new_map()


func _on_ball_hit():
	num_hits += 1
	update_ball_hits()

func update_ball_hits():
	$counter_hits/num_hits_label.text = str(num_hits)

func init_map_elements(map : Node2D):
	$ball.start_position(map.ball_position())
	$hole.position = map.hole_position()
	$ball.playing = true
	$hole.playing = true
	show_hole_and_ball()

func start_new_map():
	hide_hole_and_ball()
	var map_instance = maps[current_map].instance()
	map_instance.connect("entering_finish", self, "_map_entering_finished")
	map_instance.connect("exiting_finish", self, "_map_exiting_finished")
	$maps.add_child(map_instance)
	map_instance.enter_scene()
	$sfx/MovingMapsSound.play()
	if ($maps.get_child_count() >= 2):
		$maps.get_child(0).exit_scene()
	$hole.monitoring = true
	$hole.connect("in_hole", self, "_on_hole_in_hole")
	
func finish_game():
	var new_record : bool = $leader_board.check_ranking(num_hits)
	$leader_board.show()
	
	if new_record:
		$sfx/NewRecordSound.play()
		$finishGame.configure("You got a new record!", Color(0, 0.9, 0, 0.5), \
			"res://challenges/week13/scenes/main.tscn")
	else:
		$finishGame.configure("Try again", Color(0.9, 0, 0, 0.5), \
			"res://challenges/week13/scenes/main.tscn")

	$finishGame.show()

func _map_entering_finished(i_map : Node2D):
	init_map_elements(i_map)
	
func _map_exiting_finished(i_map : Node2D):
	i_map.queue_free()

func hide_hole_and_ball():
	$hole.hide()
	$ball.hide()
	
func show_hole_and_ball():
	$hole.show()
	$ball.show()

func start_leader_board():
	$leader_board.leader_board_file_name = "ranking_week13.sav"
	$leader_board.leader_board_text = "Leader board"
	$leader_board.start()
