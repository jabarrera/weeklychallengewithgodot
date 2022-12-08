extends Node

func load_save_game(save_file_name : String) -> Dictionary:
	var file_uri = "user://" + save_file_name
	var save_game_file : File  = File.new()
	
	if not save_game_file.file_exists(file_uri):
		return {}
		
	save_game_file.open(file_uri, File.READ)
	var save_game_dic = parse_json(save_game_file.get_as_text())
	
	save_game_file.close()
	return save_game_dic
	
func save_save_game(save_file_name : String, game_data : Dictionary):
	var file_uri = "user://" + save_file_name
	var save_game_file : File  = File.new()
	
	save_game_file.open(file_uri, File.WRITE)
	save_game_file.store_string(to_json(game_data))
	
	save_game_file.close()
