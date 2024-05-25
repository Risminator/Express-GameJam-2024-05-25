extends Button

@onready var tile_map: TileMap = get_node("/root/Level/TileMap")
@onready var tile_pos: Vector2i = tile_map.local_to_map(global_position)

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.next_turn.connect(_on_next_turn)
	
func _on_next_turn():
	queue_free()


func _on_pressed():
	var old_state: Vector2i = tile_map.get_cell_atlas_coords(0, tile_pos)
	tile_map.set_cell(0, tile_pos, 2, old_state - Vector2i(1, 0))
	Events.screen_shake.emit(1.5)
	Events.next_turn.emit()
