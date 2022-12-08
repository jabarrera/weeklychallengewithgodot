extends Node

const BEST_TIMES_FILENAME = "best_times_week10.sav"
const ATTRIBUTE_TIMES_NAME = "bestTimes"

var best_times : Dictionary


func _ready():
	load_best_times()


func load_best_times():
	best_times = SaveGame.load_save_game(BEST_TIMES_FILENAME)
	if not best_times.empty() and best_times.get(ATTRIBUTE_TIMES_NAME) != null:
		fill_best_times(-1)
	else:
		best_times = {ATTRIBUTE_TIMES_NAME : []}

#Return true if the time is a new record
func check_best_times(time : float) -> bool:
	var get_record_position = check_record_position(time)
	
	if get_record_position >= 0 and get_record_position <= 9:
		var array_times : Array = best_times.get(ATTRIBUTE_TIMES_NAME)
		array_times.insert(get_record_position, time)
		if array_times.size() > 9:
			array_times.remove(10)
		fill_best_times(get_record_position + 1)
		save_best_times()
		return true
	else:
		return false
		

func fill_best_times(item_mark : int):
	var times_array = best_times.get(ATTRIBUTE_TIMES_NAME)
	
	var time_pos = 1
	for time in times_array:
		$VBoxContainer/times.get_node("time" + str(time_pos)).text = TimeConverter.human_time(time)
		if time_pos == item_mark:
			$VBoxContainer/times.get_node("time" + str(time_pos)).add_color_override("font_color", Color(1,0,0,1))
		time_pos += 1

func check_record_position(new_time : float):
	if best_times.get(ATTRIBUTE_TIMES_NAME).empty():
		return 0
	
	var time_pos = 0
	for time in best_times.get(ATTRIBUTE_TIMES_NAME):
		if new_time < time:
			return time_pos
		time_pos += 1
	
	if time_pos <= 9:
		return time_pos
	else:
		return 10

func save_best_times():
	SaveGame.save_save_game(BEST_TIMES_FILENAME, best_times)
