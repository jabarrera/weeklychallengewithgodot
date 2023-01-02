extends Node

const ATTRIBUTE_RANKING_NAME = "leaderBoard"
const MAX_RANKING_ITEMS = 10

export var leader_board_file_name : String
export var leader_board_text : String
var leader_board : Dictionary


func start():
	$VBoxContainer/leader_board_label.text = leader_board_text
	load_ranking()
	
func load_ranking():
	leader_board = SaveGame.load_save_game(leader_board_file_name)
	if not leader_board.empty() and leader_board.get(ATTRIBUTE_RANKING_NAME) != null:
		fill_ranking(-1)
	else:
		leader_board = {ATTRIBUTE_RANKING_NAME : []}

#Return true if the rank is a new record
func check_ranking(rank) -> bool:
	var get_record_position = check_record_position(rank)
	
	if get_record_position >= 0 and get_record_position <= 9:
		var array_ranking : Array = leader_board.get(ATTRIBUTE_RANKING_NAME)
		array_ranking.insert(get_record_position, get_rank(rank))
		if array_ranking.size() > 9:
			array_ranking.remove(10)
		fill_ranking(get_record_position + 1)
		save_ranking()
		return true
	else:
		return false
		

func fill_ranking(item_mark : int):
	var ranking_array = leader_board.get(ATTRIBUTE_RANKING_NAME)
	
	var rank_pos = 1
	for rank in ranking_array:
		$VBoxContainer/ranking.get_node("rank" + str(rank_pos)).text = get_rank_text(rank, rank_pos)
		if rank_pos == item_mark:
			$VBoxContainer/ranking.get_node("rank" + str(rank_pos)).add_color_override("font_color", Color(1,0,0,1))
		rank_pos += 1

func check_record_position(new_rank):
	if leader_board.get(ATTRIBUTE_RANKING_NAME).empty():
		return 0
	
	var rank_pos = 0
	for rank in leader_board.get(ATTRIBUTE_RANKING_NAME):
		if new_rank < rank.get("points"):
			return rank_pos
		rank_pos += 1
	
	if rank_pos < MAX_RANKING_ITEMS:
		return rank_pos
	else:
		return MAX_RANKING_ITEMS

func save_ranking():
	SaveGame.save_save_game(leader_board_file_name, leader_board)

func get_rank_text(rank, rank_pos):
	return "%02d : %s : %s" % [rank_pos, rank.get("date"), rank.get("points")]

func get_rank(rank) -> Dictionary:
	return {
		"date":Time.get_date_string_from_system(),
		"points":rank
	}
