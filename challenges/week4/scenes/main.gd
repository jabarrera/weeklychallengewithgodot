extends Node


var cards = [Week4Global.CARD_TYPES.ONE, Week4Global.CARD_TYPES.ONE,
			 Week4Global.CARD_TYPES.TWO,Week4Global.CARD_TYPES.TWO,
			 Week4Global.CARD_TYPES.THREE,Week4Global.CARD_TYPES.THREE,
			 Week4Global.CARD_TYPES.FOUR,Week4Global.CARD_TYPES.FOUR,
			 Week4Global.CARD_TYPES.FIVE, Week4Global.CARD_TYPES.FIVE,
			 Week4Global.CARD_TYPES.SIX,Week4Global.CARD_TYPES.SIX,
			 Week4Global.CARD_TYPES.SEVEN,Week4Global.CARD_TYPES.SEVEN,
			 Week4Global.CARD_TYPES.EIGHT,Week4Global.CARD_TYPES.EIGHT
			]

var first_click_card = null
var second_click_card = null

var num_matches


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func disable_click_mouse():
	$background.mouse_filter = Control.MOUSE_FILTER_STOP
	
func enable_click_mouse():
	$background.mouse_filter = Control.MOUSE_FILTER_IGNORE

func start_game():
	disable_click_mouse()
	
	$finishGame.hide()
	
	num_matches = cards.size() * 0.5
	
	cards.shuffle()
	
	var cardNum = 0
	for card in $cards.get_children():
		card.emit_signal("set_type", cards[cardNum])
		cardNum += 1

	$StartGameTimer.start()

func _on_ShowAllCardsTimer_timeout():
	get_tree().call_group("cards", "emit_signal", "hide_me", false)
	
	#for card in get_tree().get_nodes_in_group("cards"):
	#	card.emit_signal("hide_me", false)

func _on_StartGameTimer_timeout():
	get_tree().call_group("cards", "emit_signal", "show_me", false)
	
	#for card in get_tree().get_nodes_in_group("cards"):
	#	card.emit_signal("show_me", false)
		
	$ShowAllCardsTimer.start()
	enable_click_mouse()


func _on_card_clicked(me):
	disable_click_mouse()
	
	if first_click_card == null:
		first_click_card = me
		enable_click_mouse()	
	else:
		second_click_card = me
		second_click()
	
func second_click():
	if (first_click_card.card_type == second_click_card.card_type):
		matched()
	else:
		not_matched()
		
func matched():
	$MatchSound.play()
	first_click_card.emit_signal("matched")
	second_click_card.emit_signal("matched")
	remove_cards_selection()
	enable_click_mouse()
	
	num_matches -= 1
	if num_matches <= 0:
		win()
	
func not_matched():
	$NotMatchSound.play()
	$AnimationPlayer.play("not_match_shake")
	$SecondClickFail.start()
	

func _on_SecondClickFail_timeout():
	first_click_card.emit_signal("hide_me", true)
	second_click_card.emit_signal("hide_me", true)
	remove_cards_selection()


func remove_cards_selection():
	first_click_card = null
	second_click_card = null
	enable_click_mouse()	

func win():
	$FinishGameSound.play()
	$finishGame.set("You win!", Color(0.3, 0.5, 0, 0.4))
	$finishGame.show()
