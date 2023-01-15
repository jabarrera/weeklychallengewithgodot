extends Node

signal ready_to_start

const NUM_CARDS_GIVEN : int = 5
const TIME_GIVE_CARD : float = 0.2
const THROW_ZONE : float = 100.0
const TIME_CLEAN_HAND : float = 2.0

const COLOR_NAME_WAITING : Color = Color("aaaaaa")
const COLOR_NAME_PLAYING : Color = Color("fffb00")

var player_scene : PackedScene = preload("res://challenges/week14/scenes/player/player.tscn")
var num_npc_players : int = 3

onready var player_position : Array = [$PlayerUpPosition, $PlayerRightPosition, $PlayerLeftPosition]
var players : Array
var current_player : int = 0
var hand_cards : Array
var hand_players : Array


func _ready():
	randomize()
	$PickUp_button.disabled = true
	$Pass_turn_button.disabled = true
	$select_num_players.show()
	$finishGame.hide()

	
func start_game():
	prepare_hand()
	prepare_deck()
	prepare_players()
	give_first_cards()
	player_order(players[rand_range(0, players.size())])
	
func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene(Launcher.LAUNCHER_MAIN_SCENE_PATH)

func prepare_players():
	prepare_human_player()
	for player in range(0, num_npc_players):
		create_npc_player(player)
		
	for player in players:
		player.connect("threw_card", self, "_on_card_threw")
		player.connect("pass_turn", self, "_on_pass_turn")

func prepare_human_player():
	$players/table_clip_mask/human_player.global_position = $PlayerDownPosition.global_position
	$players/table_clip_mask/human_player.look_at($CenterTablePosition.position)
	players.append($players/table_clip_mask/human_player)
	$players/table_clip_mask/human_player.inform_winner_suit($deck.card_winner_suit.suit)

func prepare_deck():
	$deck.show_cards($DeckPosition.position, 1)
	$deck.choose_winner_suit_card($WinnerSuitCardPosition.position)

func create_npc_player(num_player : int):
	var player_instance = player_scene.instance()
	player_instance.type = Enums.PLAYER_TYPE_ENUM.NPC
	$players/table_clip_mask.add_child(player_instance)
	player_instance.global_position = player_position[num_player].global_position
	player_instance.name = player_position[num_player].name
	player_instance.look_at($CenterTablePosition.position)
	player_instance.inform_winner_suit($deck.card_winner_suit.suit)
	players.append(player_instance)

func give_first_cards():
	var random_player = $players/table_clip_mask.get_children()
	random_player.shuffle()
	
	for num_card in range(0, NUM_CARDS_GIVEN):
		for player in random_player:
			if $deck.has_cards():
				player.get_card($deck.give_card())
				yield(get_tree().create_timer(TIME_GIVE_CARD), "timeout")
	
	emit_signal("ready_to_start")

func player_order(i_player):
	i_player.order = 1
	
	if i_player.name == "human_player":
		if num_npc_players == 3:
			get_node("players/table_clip_mask/PlayerLeftPosition").order = 2
			get_node("players/table_clip_mask/PlayerUpPosition").order = 3
			get_node("players/table_clip_mask/PlayerRightPosition").order = 4
			
		if num_npc_players == 2:
			get_node("players/table_clip_mask/PlayerRightPosition").order = 3
			
		if num_npc_players == 1 or num_npc_players == 2:
			get_node("players/table_clip_mask/PlayerUpPosition").order = 2
			
	if i_player.name == "PlayerLeftPosition":
		if num_npc_players == 3:
			get_node("players/table_clip_mask/PlayerUpPosition").order = 2
			get_node("players/table_clip_mask/PlayerRightPosition").order = 3
			get_node("players/table_clip_mask/human_player").order = 4
			
			
	if i_player.name == "PlayerRightPosition":
		if num_npc_players == 3:
			get_node("players/table_clip_mask/human_player").order = 2
			get_node("players/table_clip_mask/PlayerLeftPosition").order = 3
			get_node("players/table_clip_mask/PlayerUpPosition").order = 4
			
			
		if num_npc_players == 2:
			get_node("players/table_clip_mask/human_player").order = 2
			get_node("players/table_clip_mask/PlayerUpPosition").order = 3
	
	if i_player.name == "PlayerUpPosition":
		if num_npc_players == 3:
			get_node("players/table_clip_mask/PlayerRightPosition").order = 2
			get_node("players/table_clip_mask/human_player").order = 3
			get_node("players/table_clip_mask/PlayerLeftPosition").order = 4
			
		if num_npc_players == 2:
			get_node("players/table_clip_mask/PlayerRightPosition").order = 2
			get_node("players/table_clip_mask/human_player").order = 3
			
		if num_npc_players == 1:
			get_node("players/table_clip_mask/human_player").order = 2

	players.sort_custom(self, "sort_player_order")

func sort_player_order(a, b) -> bool:
	if a.order < b.order:
		return true
	else:
		return false

func start_hand():
	show_turn(players[current_player])
	players[current_player].turn(hand_cards, $deck)

func _on_card_threw(i_player, i_card):
	$sfx/SelectCardSound.play()
	if (i_card != null):
		#print ("Player + " + i_player.name + " threw card " + i_card.suit + " " + str(i_card.value))
		
		$hand.add_child(i_card)
		i_card.global_position = get_throw_cards_zone()
		i_card.rotation = rand_range(0, deg2rad(360))
		i_card.is_pickable(false)
		i_card.show_card()
		i_card.z_index = 0
		hand_cards.append(i_card)
		hand_players.append(i_player)
		
		next_player()
	else:
		#This shouldn't be happen...
		#Received card null from player
		next_player()

func _on_pass_turn():
	next_player()

func next_player():
	current_player += 1
	if current_player <= num_npc_players:
		show_turn(players[current_player])
		players[current_player].turn(hand_cards, $deck)
	else:
		end_hand()

func prepare_hand():
	$hand.position = $CenterTablePosition.position
	
func end_hand():
	check_win_game()
	
func check_win_game():
	var human_win : bool = false
	var draw : bool = false
	var npc_win : bool = false
	var message
	var color
	
	for player in players:
		if player.no_cards():
			if player.name == "human_player":
				if npc_win:
					draw = true
				else:
					human_win = true
			else:
				if human_win:
					draw = true
				else:
					npc_win = true
					
	var audio : AudioStreamPlayer
	if draw:
		message = "You draw!"
		color = Color(1, 1, 0, 0.5)
		audio = $sfx/DrawSound
	elif human_win:
		message = "You win!"
		color = Color(0, 1, 0, 0.5)
		audio = $sfx/WinSound
	elif npc_win:
		message = "You lost!"
		color = Color(1, 0, 0, 0.5)
		audio = $sfx/LoseSound

	
	if human_win or npc_win or draw:
		$finishGame.configure(message, color, "res://challenges/week14/scenes/main.tscn")
		$finishGame.show()
		audio.play()
	else:
		clean_cards_hand()
		
func _on_main_ready_to_start():
	start_hand()

func get_throw_cards_zone() -> Vector2:
	var x = rand_range($CenterTablePosition.global_position.x - THROW_ZONE, $CenterTablePosition.global_position.x + THROW_ZONE)
	var y = rand_range($CenterTablePosition.global_position.y - THROW_ZONE, $CenterTablePosition.global_position.y + THROW_ZONE)
	
	return Vector2(x, y)

func clean_cards_hand():
	yield(get_tree().create_timer(TIME_CLEAN_HAND), "timeout")
	$sfx/FinishHandSound.play()
	current_player = get_hand_winner_player()
	
	hand_cards = []
	hand_players = []
	for card in $hand.get_children():
		$hand.remove_child(card)
	
	start_hand()
	
func get_hand_winner_player() -> int:
	#Get player winner in hand and set new order
	var suit_hand = hand_cards[0].suit
	
	var suit_hand_card_winner
	var suit_hand_winner_suit_card
	
	var suit_hand_card_winner_pos : int = -1
	var suit_hand_winner_suit_card_pos : int = -1
	
	var element_position : int = 0
	
	for card in hand_cards:
		if card.suit == suit_hand and (suit_hand_card_winner_pos == -1 or \
				(card.value > suit_hand_card_winner.value)):
			suit_hand_card_winner_pos = element_position
			suit_hand_card_winner = card
			
		if card.suit == $deck.suit_winner and (suit_hand_winner_suit_card_pos == -1 or \
				(card.value > suit_hand_winner_suit_card.value)):
			suit_hand_winner_suit_card_pos = element_position
			suit_hand_winner_suit_card = card
		
		element_position += 1
	
	var winner_player_position
	
	if suit_hand_winner_suit_card_pos != -1:
		winner_player_position = suit_hand_winner_suit_card_pos
	elif suit_hand_card_winner_pos != -1:
		winner_player_position = suit_hand_card_winner_pos
	else:
		#This shouldn't never happend...
		pass
	
	player_order(hand_players[winner_player_position])
	
	#Order player list
	players.sort_custom(self, "sort_player_order")
	
	#Return first player to put card. Always is the first player.
	return 0


func _on_Robar_pressed():
	var picked_card = $deck.give_card()
	check_picked_card(picked_card)
	$players/table_clip_mask/human_player.get_card(picked_card)

func show_turn(i_player):
	$players_name/human_player.add_color_override("font_color", COLOR_NAME_WAITING)
	$players_name/player_right.add_color_override("font_color", COLOR_NAME_WAITING)
	$players_name/player_up.add_color_override("font_color", COLOR_NAME_WAITING)
	$players_name/player_left.add_color_override("font_color", COLOR_NAME_WAITING)
	
	if i_player.name == "human_player":
		$players_name/human_player.add_color_override("font_color", COLOR_NAME_PLAYING)
	elif i_player.name == "PlayerUpPosition":
		$players_name/player_up.add_color_override("font_color", COLOR_NAME_PLAYING)
	elif i_player.name == "PlayerLeftPosition":
		$players_name/player_left.add_color_override("font_color", COLOR_NAME_PLAYING)
	elif i_player.name == "PlayerRightPosition":
		$players_name/player_right.add_color_override("font_color", COLOR_NAME_PLAYING)


func _on_select_num_players_num_players_selected(num_players):
	#Remove human player
	num_npc_players = num_players - 1

	$select_num_players.hide()
	$select_num_players.queue_free()
	
	start_game()


func _on_human_player_picked_up_card():
	if $deck.has_cards():
		$PickUp_button.disabled = false
	else:
		$PickUp_button.disabled = true
		$Pass_turn_button.disabled = false
	
func check_picked_card(i_card):
	#Check if the card can be used or player need to still picking
	
	#First player
	#This shouldn't happen. Just for testing purpose
	if hand_cards == null or hand_cards.empty():
		return
		
	if i_card.suit == $deck.suit_winner or (i_card.suit == hand_cards[0].suit):
		$PickUp_button.disabled = true
	else:
		$PickUp_button.disabled = false

func _on_Pass_turn_button_pressed():
	$Pass_turn_button.disabled = true
	$players/table_clip_mask/human_player.my_turn = false
	next_player()
