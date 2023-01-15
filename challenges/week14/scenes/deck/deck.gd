extends Node2D

const MAX_CARDS_PER_SUIT = 12

var card_scene : PackedScene = preload("res://challenges/week14/scenes/card/card.tscn")
var deck : Array
var card_winner_suit : Node2D
var suit_winner

func _ready():
	load_cards()

func load_cards():
	
	var order = 0
	for suit in PlayingCards.SPANISH_PLAYING_CARDS_SUIT:
		for number in range(1, MAX_CARDS_PER_SUIT + 1):
			if number in [8, 9]:
				continue
				
			var card : Node2D = create_card(suit, number, order)
			order += 1
			deck.append(card)
	

func create_card(suit, number: int, order: int) -> Node2D:
	var texture_card = load("res://common/gfx/spanish_playing_cards/" + suit.to_lower() + "_" + str(number) + ".webp")

	var card_instance = card_scene.instance()
	card_instance.configure(number, suit, texture_card, order, false)
	
	return card_instance
	
func show_cards(i_position : Vector2, space_between_cards : float):
	var increment = 0
	var z_index_cont = 0
	randomize()
	deck.shuffle()
	
	for card in deck:
		card.position.x = i_position.x
		card.position.y = i_position.y + increment
		card.rotation += deg2rad(90)
		card.set_z_index(z_index_cont)
		z_index_cont -= 1
		add_child(card)
		increment += space_between_cards

func choose_winner_suit_card(i_position : Vector2):
	card_winner_suit = deck.pop_back()
	card_winner_suit.position = i_position
	card_winner_suit.rotation += deg2rad(90)
	card_winner_suit.show_card()
	suit_winner = card_winner_suit.suit
	
func give_card() -> Node2D:
	var card
	if not deck.empty():
		card = deck.pop_front()
		remove_child(card)
	else:
		card = give_last_card()
	
	#print("Num cards -> " + str(deck.size()))
	#print("Num child cards: -> " + str(get_child_count()))
	return card
	
func give_last_card() -> Node2D:
	remove_child(card_winner_suit)
	card_winner_suit.rotation -= deg2rad(90)
	
	return card_winner_suit
	
func has_cards() -> bool:
	return get_child_count() > 0
	
