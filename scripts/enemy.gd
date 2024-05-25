extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var player: Player = get_node("/root/Level/Player")
@onready var tile_map: TileMap = get_node("/root/Level/TileMap")
var tile_pos: Vector2i = Vector2i.ZERO
var direction
var current_path: Array[Vector2i]

"""func move():
	var distance: Vector2i = player.tile_pos - tile_pos
	print("Distance: ", distance, "\n")
	var dir_x: int = sign(distance.x)
	var dir_y: int = sign(distance.y)
	
	var best_dir = Vector2i(dir_x, 0) if abs(distance.x) > abs(distance.y) else Vector2i(0, dir_y)
	var alt_dir = Vector2i(0, dir_y) if abs(distance.x) > abs(distance.y) else Vector2i(dir_x, 0)
	print("Best direction: ", best_dir, "Alt direction: ", alt_dir)
	var best_pos = tile_pos + best_dir
	var alt_pos = tile_pos + alt_dir
	print("Best position: ", best_pos, "Alt position: ", alt_pos)
	var tile_type = tile_map.get_cell_atlas_coords(0, best_pos)
	print("Tile:", tile_type)
	if tile_type != Global.TILE_LAVA:
		tile_pos = best_pos
	else:
		tile_pos = alt_pos
	global_position = tile_map.map_to_local(tile_pos)"""

func check_if_screwed():
	var is_screwed = tile_map.get_cell_tile_data(0, tile_pos).get_custom_data('hazardous')
	if is_screwed:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "scale", Vector2.ZERO, 0.5)
		tween.tween_callback(queue_free)
	return is_screwed

func move():
	if check_if_screwed():
		return
	var player_pos = player.tile_pos
	current_path = tile_map.astar.get_id_path(tile_pos, player_pos).slice(1)
	if !current_path.is_empty():
		tile_pos = current_path.front()
		global_position = tile_map.map_to_local(tile_pos)
		check_if_screwed()
	if check_if_screwed():
		return
	if player_pos == tile_pos:
		player.queue_free()
		Events.game_lost.emit()

func _ready():
	tile_pos = tile_map.local_to_map(global_position)
	global_position = tile_map.map_to_local(tile_pos)
	Events.next_turn.connect(_on_next_turn)

func _on_next_turn():
	move()
