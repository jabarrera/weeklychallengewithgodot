extends Node2D

signal mouse_over(card)
signal mouse_left(card)
signal selected

const CARD_SELECTED_MOVE = 50

var texture_hide : Texture = preload("res://common/gfx/spanish_playing_cards/back.webp")
var texture_show : Texture
var suit
var value : int
var hidden : bool
var marked : bool = false
var order

func _ready():
	scale = Vector2(0.7, 0.7)
	is_pickable(false)

func configure(i_value : int, i_suit, i_texture : Texture, i_order: int, i_show_card : bool):
	suit = i_suit
	value = i_value
	texture_show = i_texture
	order = i_order

	if i_show_card:
		show_card()
	else:
		hide_card()

func hide_card():
	hidden = true
	$Sprite.texture = texture_hide
	
func show_card():
	hidden = false
	$Sprite.texture = texture_show


func _on_card_area_mouse_entered():
	emit_signal("mouse_over", self)


func _on_card_area_mouse_exited():
	emit_signal("mouse_left", self)


func _on_card_area_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseMotion):
		emit_signal("mouse_over", self)
		
	if (event is InputEventMouseButton and event.is_pressed()):
		emit_signal("selected")

func is_pickable(i_pickable : bool):
	$card_area.input_pickable = i_pickable


func set_level(i_level : int):
	z_index = i_level
	
func mouse_over():
	if not marked:
		global_position.y -= CARD_SELECTED_MOVE
		marked = true

func mouse_left():
	if marked:
		global_position.y += CARD_SELECTED_MOVE
		marked = false
