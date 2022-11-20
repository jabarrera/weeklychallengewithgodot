extends Node2D

signal killed(iWord)

export var word : String
export var velocity : int
export var destination_point : Vector2
export var movement_type : int = 1

const LETTER_SIZE = 17
var letter_scene = preload("res://challenges/week7/scenes/letter/letter.tscn")

var accent_mark_pressed : bool = false
var letters : Array
var direction : Vector2

var angle : float = 0.0


func _input(event):
	if event is InputEventKey and event.is_pressed():
		play_key_sound()
		var key_pressed = OS.get_scancode_string(event.get_scancode_with_modifiers()).to_lower()
		
		var uppercase : bool = false
		if key_pressed.begins_with("shift+"):
			key_pressed = key_pressed[key_pressed.length() - 1]	
			uppercase = true
		
		if "apostrophe" == key_pressed:
			accent_mark_pressed = true
			return
		
		if "shift" == key_pressed:
			return
			
		if accent_mark_pressed:
			match key_pressed:
				"a": key_pressed = "á"
				"e": key_pressed = "é"
				"i": key_pressed = "í"
				"o": key_pressed = "ó"
				"u": key_pressed = "ú"
			accent_mark_pressed = false
		
		if "space" == key_pressed:
			key_pressed = " "
			
		if uppercase:
			key_pressed = key_pressed.to_upper()
		else:
			key_pressed = key_pressed.to_lower()
			
		check_letter(key_pressed)
		
		#print("Letter: " + key_pressed)

# Called when the node enters the scene tree for the first time.
func _ready():
	create_word()
	direction = position.direction_to(destination_point).normalized()
	add_to_group("words")
	
func _process(delta):
	if movement_type == 1:
		position.x += (direction.x - sin(angle * PI* 0.5) * (velocity / 25))
		position.y += (direction.y + sin(angle * PI * 0.5) * (velocity / 25))
		angle += 0.03
	else:
		position += direction * velocity * delta
func create_word():
	var letter_pos = 0
	for letter in word:
		create_letter(letter, letter_pos)
		letter_pos += 1
		
		
func create_letter(letter : String, letter_pos : int):
	var letter_instance = letter_scene.instance()
	letter_instance.letter = letter
	letter_instance.position.x = letter_instance.position.x + \
		(LETTER_SIZE * letter_pos)
	$letters.add_child(letter_instance)
	letters.append(letter_instance)

func check_letter(letter : String):
	if word[0] == letter:
		word = word.substr(1, word.length())
		remove_letter_pressed()

func remove_letter_pressed():
	letters[0].explode()
	letters.remove(0)
	
	if (letters.size() == 0):
		kill_word()
		
		
func kill_word():
	play_kill_sound()
	set_process(false)
	set_process_input(false)
	emit_signal("killed", self)
	
func stop():
	set_process(false)
	set_process_input(false)
	get_tree().call_group("letters", "monitorable", "false")

func play_key_sound():
	$KeySound.play()

func play_kill_sound():
	$CompleteSound.play()
