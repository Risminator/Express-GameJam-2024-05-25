extends Control

@export var restore_cooldown:int = 2
@onready var tile_map: TileMap = $TileMap

var restoring_shattered: Dictionary
var restoring_lava: Dictionary

func _ready():
	Global.is_lost = false
	Events.next_turn.connect(_on_next_turn)
	Events.game_lost.connect(_on_game_lost)

func _process(delta):
	if Input.is_action_just_pressed("skip_turn"):
		Events.next_turn.emit()

func _on_next_turn():
	var shattered_tiles = tile_map.get_used_cells_by_id(0, 2, Global.TILE_SHATTERED)
	for tile: Vector2i in shattered_tiles:
		if tile in restoring_shattered:
			restoring_shattered[tile] += 1
			if restoring_shattered[tile] == restore_cooldown:
				tile_map.set_cell(0, tile, 2, Global.TILE_GROUND)
				restoring_shattered.erase(tile)
		else:
			restoring_shattered[tile] = 0
	var lava_tiles = tile_map.get_used_cells_by_id(0, 2, Global.TILE_LAVA)
	for tile: Vector2i in lava_tiles:
		if tile in restoring_lava:
			restoring_lava[tile] += 1
			if restoring_lava[tile] == restore_cooldown:
				tile_map.set_cell(0, tile, 2, Global.TILE_SHATTERED)
				restoring_lava.erase(tile)
		else:
			restoring_lava[tile] = 0
			
func _on_game_lost():
	Global.is_lost = true
