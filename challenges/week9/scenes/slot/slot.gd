extends Node2D

signal bankrupt
signal running(b_running)

const NO_RESULT = -1

const RUN_COST = 5
const DOUBLE_PRIZE = 10
const DOUBLE_PRIZE_MESSAGE = "YOU WIN DOUBLE!"
const TRIPLE_PRIZE = 30
const TRIPLE_PRIZE_MESSAGE = "YOU WIN TRIPLE!"
const BIG_PRIZE = 1000
const BIG_PRIZE_MESSAGE = "€ BIG PRIZE €"
const NO_PRIZE_MESSAGE = "NO PRIZE"

const LOSES_TO_GET_MOVEMENT = 5

var running : bool = false

var wheel_1_result : int = NO_RESULT
var wheel_2_result : int = NO_RESULT
var wheel_3_result : int = NO_RESULT

var loses : int = 0
var free_movements : int = 0

var double_win_obtained = false

func _input(event):
	if Input.is_action_just_pressed("ui_left"):
		run()

# Called when the node enters the scene tree for the first time.
func _ready():
	update_message_movements()
	deactivate_movement_buttons()


func run():
	double_win_obtained = false
	reset_wheels_results()
	deactivate_movement_buttons()
	set_message_prize("")
	$money.emit_signal("lost_money", RUN_COST)
	running = true
	emit_signal("running", true)
	$wheels/wheel_1.run()
	$wheels/wheel_2.run()
	$wheels/wheel_3.run()


func _on_wheel_1_result(item):
	wheel_1_result = item
	check_end_all_wheels()


func _on_wheel_2_result(item):
	wheel_2_result = item
	check_end_all_wheels()

func _on_wheel_3_result(item):
	wheel_3_result = item
	check_end_all_wheels()
	
func check_end_all_wheels():
	if wheel_1_result != -1 and wheel_2_result != -1 and wheel_3_result != -1:
		if check_prize():
			reset_loses_counter()
		else:
			lose_run()
			
		run_finish()
		
#Return if got prized or not	
func check_prize() -> bool:
	
	if wheel_1_result == wheel_2_result and wheel_1_result == wheel_3_result:
		if wheel_1_result == $wheels/wheel_1.ESPECIAL_ITEM:
			$money.emit_signal("win_money", BIG_PRIZE)
			set_message_prize(BIG_PRIZE_MESSAGE)
		else:
			$money.emit_signal("win_money", TRIPLE_PRIZE)
			set_message_prize(TRIPLE_PRIZE_MESSAGE)
		
		return true
	elif not double_win_obtained and (wheel_1_result == wheel_2_result or wheel_2_result == wheel_3_result):
		$money.emit_signal("win_money", DOUBLE_PRIZE)
		set_message_prize(DOUBLE_PRIZE_MESSAGE)
		double_win_obtained = true
		
		return true
	else:
		$LoseSound.play()
		return false
		
		
func run_finish():
	activate_movement_buttons()
	running = false
	emit_signal("running", false)
	check_bankrupt()
	
		
func check_bankrupt():
	if $money.current_cash < RUN_COST:
		emit_signal("bankrupt")

func reset_wheels_results():
	wheel_1_result = -1
	wheel_2_result = -1
	wheel_3_result = -1


func _on_pull_pulled():
	if not running:
		run()

func lose_run():
	set_message_prize(NO_PRIZE_MESSAGE)
	loses += 1
	if loses == LOSES_TO_GET_MOVEMENT:
		get_one_movement()
		activate_movement_buttons()
		
func reset_loses_counter():
	loses = 0

func set_message_prize(message):
	$message/message.text = message
	
func update_message_movements():
	if free_movements == 0:
		deactivate_movement_buttons()
		
	$message/free_movements.text = str(free_movements)

func deactivate_movement_buttons():
	$buttons/avoid_buttons.show()
	
func activate_movement_buttons():
	if free_movements > 0:
		$buttons/avoid_buttons.hide()

func use_one_movement():
	free_movements -= 1
	update_message_movements()
	
func get_one_movement():
	loses = 0
	free_movements += 1
	update_message_movements()
	

func _on_wheel_1_up_button_button_pressed():
	if free_movements > 0:
		use_one_movement()
		wheel_1_result = $wheels/wheel_1.move_up()
		
		if check_prize():
			deactivate_movement_buttons()


func _on_wheel_1_down_button_button_pressed():
	if free_movements > 0:
		use_one_movement()
		wheel_1_result = $wheels/wheel_1.move_down()
		
		if check_prize():
			deactivate_movement_buttons()


func _on_wheel_2_up_button_button_pressed():
	if free_movements > 0:
		use_one_movement()
		wheel_2_result = $wheels/wheel_2.move_up()
		
		if check_prize():
			deactivate_movement_buttons()


func _on_wheel_2_down_button_button_pressed():
	if free_movements > 0:
		use_one_movement()
		wheel_2_result = $wheels/wheel_2.move_down()
		
		if check_prize():
			deactivate_movement_buttons()


func _on_wheel_3_up_button_button_pressed():
	if free_movements > 0:
		use_one_movement()
		wheel_3_result = $wheels/wheel_3.move_up()
		
		if check_prize():
			deactivate_movement_buttons()


func _on_wheel_3_down_button_button_pressed():
	if free_movements > 0:
		use_one_movement()
		wheel_3_result = $wheels/wheel_3.move_down()
		
		if check_prize():
			deactivate_movement_buttons()
