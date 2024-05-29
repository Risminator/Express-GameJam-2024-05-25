extends Button

@onready var tile_map: TileMap = get_node("/root/Level/TileMap")
@onready var tile_pos: Vector2i = tile_map.local_to_map(global_position)

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.next_turn.connect(_on_next_turn)
	Events.cell_restored.connect(_on_cell_restored)
	
func _on_next_turn(_changed=[]):
	queue_free()

func _on_cell_restored():
	queue_free()

func _on_pressed():
	var old_state: Vector2i = tile_map.get_cell_atlas_coords(0, tile_pos)
	var new_tile_type = old_state - Vector2i(2, 0) if old_state != Global.TILE_ALMOST_GROUND else Global.TILE_LAVA
	tile_map.set_cell(0, tile_pos, 2, new_tile_type)
	Level.update_or_create_restoring_cell(tile_pos, new_tile_type, -1)
	Events.screen_shake.emit(1.5)
	Events.next_turn.emit()
