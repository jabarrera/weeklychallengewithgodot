extends Node2D

const LAVA : int = 0
const NUM_X_LAVA_TILES = 13
const NUM_Y_LAVA_TILES = 13

func _ready():
	hide_lava()
	random_lava(100)

func random_lava(num_lava_tiles : int):
	clean_previous_lava()
	for num_tile in num_lava_tiles:
		var cell_x = randi() % 13
		var cell_y = randi() % 13
		$lava.set_cell(cell_x, cell_y, LAVA)
		
func is_lava(worl_position : Vector2):
	var tile_from_world = $lava.world_to_map(worl_position)
	if $lava.get_cellv(tile_from_world) == LAVA:
		return true
	else:
		return false

func hide_lava():
	$lava.hide()
	
func show_lava():
	$lava.show()

func clean_previous_lava():
	for x in NUM_X_LAVA_TILES:
		for y in NUM_Y_LAVA_TILES:
			$lava.set_cell(x, y, -1)
