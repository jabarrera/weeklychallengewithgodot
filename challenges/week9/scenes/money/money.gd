extends Node2D

export var INITIAL_MONEY : int = 100

var current_cash : int


signal lost_money(amount)
signal win_money(amount)
signal no_money

func _ready():
	current_cash = INITIAL_MONEY
	$Label.text = str(current_cash)
	

func _on_money_lost_money(amount):
	$LostMoneySound.play()
	current_cash -= amount
	
	if current_cash < 0:
		emit_signal("no_money")
	else:
		$Label.text = str(current_cash)


func _on_money_win_money(amount):
	$GetMoneySound.play()
	current_cash += amount
	$Label.text = str(current_cash)
