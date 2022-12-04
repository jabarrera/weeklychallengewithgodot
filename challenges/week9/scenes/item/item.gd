extends Node2D

export var item_type : int = -1


#Array:
# 0: item type
# 1: item texture
func set_item(i_item : Array):
	item_type = i_item[0]
	$Sprite.texture = i_item[1]
