extends Node2D

const ORIGIN_SQUARE_MAP : Vector2 = Vector2(0, 0)
const END_SQUARE_MAP : Vector2 = Vector2(900, 600)
const TILE_SIZE_MIDDLE : int = 10

const TILE_SAFE_ZONE = 0
const TILE_RADIOACTIVE_ZONE = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
func get_free_position() -> Vector2:
	var x = rand_range(ORIGIN_SQUARE_MAP.x, END_SQUARE_MAP.x)
	var y = rand_range(ORIGIN_SQUARE_MAP.y, END_SQUARE_MAP.y)
	
	return $TileMap.map_to_world($TileMap.world_to_map(Vector2(x, y))) + \
			 Vector2(TILE_SIZE_MIDDLE, TILE_SIZE_MIDDLE)
			
func set_radioactive_zone(i_position : Vector2):
	$TileMap.set_cellv($TileMap.world_to_map(i_position), TILE_RADIOACTIVE_ZONE)

func is_radioactive_zone(i_position : Vector2) -> bool:
	if $TileMap.get_cellv($TileMap.world_to_map(i_position)) == TILE_RADIOACTIVE_ZONE:
		return true
	else:
		return false
		
func over_map(i_position : Vector2) -> bool:
	if (i_position.x >= ORIGIN_SQUARE_MAP.x) and (i_position.x <= END_SQUARE_MAP.x) and \
	   (i_position.y >= ORIGIN_SQUARE_MAP.y) and (i_position.y <= END_SQUARE_MAP.y):
		return true
	else:
		return false
