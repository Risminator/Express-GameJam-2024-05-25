extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var player: Player = get_node("/root/Level/Player")
@onready var tile_map: TileMap = get_node("/root/Level/TileMap")
var tile_pos: Vector2i = Vector2i.ZERO
var direction
@export var can_move = true
var stun_time = 0
var current_path: Array[Vector2i]
var grouped

func check_if_screwed():
	var is_screwed = tile_map.get_cell_tile_data(0, tile_pos).get_custom_data('hazardous')
	if is_screwed:
		can_move = false
		Events.enemy_killed.emit()
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
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
	elif player != null and tile_pos != player.tile_pos:
		alt_move()
	if check_if_screwed():
		return
	if player_pos == tile_pos:
		player.queue_free()
		Events.game_lost.emit()
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.tile_pos == tile_pos and enemy != self:
			grouped = true
	if grouped:
		sprite.frame = 1
	else:
		sprite.frame = 0

func alt_move():
	var distance = player.tile_pos - tile_pos
	var dir_x: int = sign(distance.x)
	var dir_y: int = sign(distance.y)
	var best_dir = Vector2i(dir_x, 0) if abs(distance.x) > abs(distance.y) else Vector2i(0, dir_y)
	var alt_dir = Vector2i(0, dir_y) if abs(distance.x) > abs(distance.y) else Vector2i(dir_x, 0)
	var best_pos = tile_pos + best_dir
	var alt_pos = tile_pos + alt_dir
	var tile_type = tile_map.get_cell_atlas_coords(0, best_pos)
	
	#print("--------")
	#print("Distance: ", distance)
	if tile_type != Global.TILE_LAVA and tile_type != Global.TILE_ALMOST_SHATTERED:
		#print("BEST ALT MOVE! ", best_dir, " ", alt_dir, "Chose ", best_dir)
		tile_pos = best_pos
	else:
		#print("ALT MOVE! ", best_dir, " ", alt_dir, "Chose ", alt_dir)
		tile_pos = alt_pos
	#print("--------")
	global_position = tile_map.map_to_local(tile_pos)
	check_if_screwed()

func _ready():
	add_to_group("enemies")
	if tile_pos == Vector2i.ZERO:
		tile_pos = tile_map.local_to_map(global_position)
	global_position = tile_map.map_to_local(tile_pos)
	Events.swapped.connect(_on_swapped)
	Events.player_turn_taken.connect(_on_player_turn_taken)

func take_turn():
	if grouped:
		sprite.frame = 1
	else:
		sprite.frame = 0
	if can_move and stun_time <= 0:
		move()

func _on_swapped(swap_enemy):
	if self == swap_enemy:
		stun_time = 1
		Events.next_turn.connect(_on_next_turn)
	
func _on_next_turn():
	stun_time -= 1
	if stun_time == 0:
		Events.next_turn.disconnect(_on_next_turn)

func _on_player_turn_taken():
	check_if_screwed()
