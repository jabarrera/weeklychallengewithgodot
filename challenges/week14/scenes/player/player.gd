extends Node2D

signal threw_card(player, card)
signal pass_turn
signal picked_up_card

const CARD_SEPARATION : int = 30
const TIME_PICK_UP_CARD_FROM_DECK : float = 0.5
const CARD_POSITION_RECTIFICACION : float = 10.0
const TIME_PLAYER_METITATION : float = 2.0

var my_cards : Array
export(Enums.PLAYER_TYPE_ENUM) var type

var my_turn : bool = false
var order : int

var last_hand_cards
var winner_suit
var deck


func get_card(i_card : Node2D):
	$GetCardSound.play()
	if type == Enums.PLAYER_TYPE_ENUM.HUMAN:
		i_card.show_card()
		i_card.is_pickable(true)
		i_card.connect("mouse_over", self, "_on_mouse_over_card")
		i_card.connect("mouse_left", self, "_on_mouse_left_card")
		i_card.connect("selected", self, "_on_selected_card")
	else:
		#i_card.show_card()
		i_card.hide_card()
		i_card.is_pickable(false)
		
	my_cards.append(i_card)
	$cards.add_child(i_card)
	i_card.position = $CardsPosition.position + Vector2(0, (my_cards.size() * CARD_SEPARATION))
	i_card.z_index = 0
	sort_cards()
	adjust_cards_position()

func card_sort(a, b) -> bool:
	if a.order < b.order:
		return true
	else:
		return false

func sort_cards():
	my_cards.sort_custom(self, "card_sort")
	
	var card_number = 0
	for card in my_cards:
		var card_node = $cards.get_node(card.name)
		card_node.position = Vector2(0, card_number * CARD_SEPARATION)
		card_node.set_level(card_number)
		card_number += 1

func _on_mouse_over_card(card : Node2D):
	if my_turn:
		var current_selectec_card = get_current_selected_card()
		
		if current_selectec_card == null:
			card.mouse_over()
			return
		
		if current_selectec_card.z_index < card.z_index:
			current_selectec_card.mouse_left()
			card.mouse_over()


func _on_mouse_left_card(card : Node2D):
	if my_turn:
		card.mouse_left()

func _on_selected_card():
	if my_turn:
		var current_card = get_current_selected_card()
		if valid_card(current_card):
			my_turn = false
			emit_signal("threw_card", self, threw_card(current_card))
		else:
			$ErrorSound.play()

func valid_card(i_current_card):
	if is_a_card_selected(i_current_card) and \
			(first_hand() or \
			(card_is_same_suit_hand_or_winner_suit(i_current_card))):
		return true
	else:
		return false
	
func is_a_card_selected(i_current_card) -> bool:
	return i_current_card != null
	
func first_hand() -> bool:
	return last_hand_cards.size() == 0

func card_is_same_suit_hand_or_winner_suit(i_current_card):
	#If player have a card from normal suit, he can't select a winner suit
	return (last_hand_cards[0].suit == i_current_card.suit or \
				is_valid_winner_suit(i_current_card, last_hand_cards[0].suit))

func is_valid_winner_suit(i_current_card, normal_suit) -> bool:
	for card in my_cards:
		if card.suit == normal_suit:
			return false
	
	return winner_suit == i_current_card.suit


func get_current_selected_card():
	for card in my_cards:
		if card.marked:
			return card
	
	return null

func turn(cards_hand : Array, i_deck : Node2D):
	if type == Enums.PLAYER_TYPE_ENUM.NPC:
		var npc_card = select_card(cards_hand)
		
		if npc_card == null:
			if i_deck.has_cards():
				yield(get_tree().create_timer(TIME_PICK_UP_CARD_FROM_DECK), "timeout")
				pick_up_card_from_deck(i_deck)
				turn(cards_hand, i_deck)
			else:
				emit_signal("pass_turn")
		
		if npc_card != null:
			yield(get_tree().create_timer(TIME_PLAYER_METITATION), "timeout")
			emit_signal("threw_card", self, threw_card(npc_card))
	else:
		last_hand_cards = cards_hand
		deck = i_deck
		my_turn = true
		check_pick_up_need()

func random_card():
	var selected_card_position = rand_range(0, my_cards.size())
	var selected_card = my_cards[selected_card_position]
	my_cards.remove(selected_card_position)
	$cards.remove_child(selected_card)
	
	sort_cards()
	return selected_card

func threw_card(i_card):
	var selected_card_position : int = my_cards.find(i_card)
	my_cards.remove(selected_card_position)
	$cards.remove_child(i_card)
	
	sort_cards()
	adjust_cards_position()
	return i_card

func select_card(cards_hand : Array) -> Node2D:
	if cards_hand.empty():
		return random_card()
		
	var suit_value : Array = get_suit_from_cards(cards_hand)
	
	var card_selected = card_winner_for(suit_value)
	
	
	return card_selected
	
	
func get_suit_from_cards(cards_hand):
	var suit = cards_hand[0].suit
	var value = cards_hand[0].value
	
	for card in cards_hand:
		if suit == card.suit:
			if value < card.value:
				value = card.value
			
	return [suit, value]
	
func card_winner_for(suit_value):
	var suit = suit_value[0]
	var value : int = suit_value[1]
	
	var card_selected
	var card_winner_suit_selected
	
	for card in my_cards:
		if is_card_same_norma_suit_and_greater(card, card_selected, suit):
			card_selected = card
		
		if is_card_same_norma_suit_and_greater(card, card_winner_suit_selected, winner_suit):
			card_winner_suit_selected = card
	
	if card_selected != null:
		return card_selected
	else:
		return card_winner_suit_selected
	

func is_card_same_norma_suit_and_greater(i_card, i_current_card, suit) -> bool:
	return i_card.suit == suit and (i_current_card == null or i_current_card.value < i_card.value)	


func pick_up_card_from_deck(deck):
	get_card(deck.give_card())
	

func adjust_cards_position():
	$cards.position.y = -(my_cards.size() * CARD_POSITION_RECTIFICACION)
	if my_cards.size() > 15:
		$cards.scale.y = 0.8
		$cards.scale.x = 0.8
	else:
		$cards.scale.y = 1.0
		$cards.scale.x = 1.0
	
func inform_winner_suit(i_suit):
	winner_suit = i_suit

func no_cards() -> bool:
	return my_cards.empty()

func check_pick_up_need():
	#Check if player can throw a card
	var i_need_to_pick_up : bool = true
	
	#First player
	if last_hand_cards == null or last_hand_cards.empty():
		return
	
	for card in my_cards:
		if card.suit == deck.suit_winner or (card.suit == last_hand_cards[0].suit):
			i_need_to_pick_up = false
			break
			
	if i_need_to_pick_up:
		emit_signal("picked_up_card")
