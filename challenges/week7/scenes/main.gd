extends Node

const MAX_WORDS_CREATED = 3
const MAX_TIME_NEXT_WORDS_CREATION = 5
const MIN_WORD_VELOCITY = 5
const MAX_WORD_VELOCITY = 50

var language : String
var dictionary_words : Dictionary
var words_pool : Array

var word_scene = preload("res://challenges/week7/scenes/word/word.tscn")


func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)


func _ready():
	randomize()
	$language.show_on_top
	$diedMessage.hide()


func start_game():
	$createWordTimer.start()


func _on_language_language_selected(iLanguage):
	language = iLanguage
	load_words()
	$language.hide()
	start_game()

func load_words():
	var content_file = load_file()
	var json_parser = JSON.parse(content_file)
	dictionary_words = json_parser.result
	
func load_file() -> String:
	var file : File = File.new()
	file.open("res://challenges/week7/scenes/words_" + language + ".dic", File.READ)
	var content_file = file.get_as_text()
	file.close()
	return content_file


func _on_createWordTimer_timeout():
	var num_words = (randi() % MAX_WORDS_CREATED) + 1
	
	for i in num_words:
		create_word()

	$createWordTimer.wait_time = rand_range(0.1, MAX_TIME_NEXT_WORDS_CREATION)
	$createWordTimer.start()
	
func create_word():
	var new_word = words_pool.pop_back()
	var pooled = true
		
	if new_word == null:
		new_word = word_scene.instance()
		new_word.connect("killed", self, "_on_killed_word")
		pooled = false
		
	var next_key_word = dictionary_words.keys()[randi() % dictionary_words.size()]
	new_word.word = dictionary_words.get(next_key_word)
	new_word.velocity = rand_range(MIN_WORD_VELOCITY, MAX_WORD_VELOCITY)
	new_word.destination_point = $city.position
	new_word.movement_type = randi() % 2
	
	$SpawnZone/SpawnPoints.offset = randi()
	new_word.position = $SpawnZone/SpawnPoints.position

	if not pooled:
		$words.add_child(new_word)

func _on_killed_word(iWord):
	words_pool.push_back(iWord)


func _on_city_died():
	$diedMessage.show()
	$createWordTimer.stop()
	get_tree().call_group("words", "stop")
