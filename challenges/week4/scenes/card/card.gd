extends Area2D

signal set_type(new_card_type)
signal show_me(clicked)
signal hide_me(clicked)
signal clicked(me)
signal matched()

export(Week4Global.CARD_TYPES) var card_type

var one : Texture = preload("res://challenges/week4/gfx/cards/apple.png")
var two : Texture = preload("res://challenges/week4/gfx/cards/pearl.png")
var three : Texture = preload("res://challenges/week4/gfx/cards/pineapple.png")
var four : Texture = preload("res://challenges/week4/gfx/cards/orange.png")
var five : Texture = preload("res://challenges/week4/gfx/cards/kiwi.png")
var six : Texture = preload("res://challenges/week4/gfx/cards/banana.png")
var seven : Texture = preload("res://challenges/week4/gfx/cards/strawberry.png")
var eight : Texture = preload("res://challenges/week4/gfx/cards/cherry.png")

var exposed : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	set_image_card()
	cover(false)
	exposed = false
	

func set_image_card():
	match card_type:
		Week4Global.CARD_TYPES.ONE:
			$front.texture = one
		Week4Global.CARD_TYPES.TWO:
			$front.texture = two
		Week4Global.CARD_TYPES.THREE:
			$front.texture = three
		Week4Global.CARD_TYPES.FOUR:
			$front.texture = four
		Week4Global.CARD_TYPES.FIVE:
			$front.texture = five
		Week4Global.CARD_TYPES.SIX:
			$front.texture = six
		Week4Global.CARD_TYPES.SEVEN:
			$front.texture = seven
		Week4Global.CARD_TYPES.EIGHT:
			$front.texture = eight

func cover(clicked):
	$front.hide()
	$back.show()
	exposed = false
	if (clicked):
		$HideCardSound.play()

func expose(clicked):
	$front.show()
	$back.hide()
	exposed = true
	if (clicked):
		$ShowCardSound.play()
		emit_signal("clicked", self)

func _on_card_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and not exposed:
		expose(true)
		

func _on_card_set_type(new_card_type):
	card_type = new_card_type
	set_image_card()


func _on_card_hide_me(clicked):
	cover(clicked)
	
func _on_card_show_me(clicked):
	expose(clicked)


func _on_card_matched():
	$MatchParticles.restart()
