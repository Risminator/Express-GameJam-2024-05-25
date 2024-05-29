extends Node2D
class_name Player

const SMASH_BUTTON = preload("res://scenes/smash_button.tscn")
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var tile_map: TileMap = get_node("/root/Level/TileMap")
var tile_pos: Vector2i = Vector2i.ZERO
var is_players_turn = false
var swaps = 1

func change_tile_position(x: int, y: int):
	var new_pos = tile_pos + Vector2i(x, y)
	var is_hazardous = tile_map.get_cell_tile_data(0, new_pos).get_custom_data('hazardous')
	if !is_hazardous:
		tile_pos = new_pos
		global_position = tile_map.map_to_local(tile_pos)
	Events.next_turn.emit()

func set_smash_positions():
	var neighbor_tiles = tile_map.get_surrounding_cells(tile_pos)
	for tile in neighbor_tiles:
		var tile_type: Vector2i = tile_map.get_cell_atlas_coords(0, tile)
		if tile_type not in [Global.TILE_LAVA, Global.TILE_ALMOST_SHATTERED, Global.TILE_BOUNDER]:
			var new_smash_button: Button = SMASH_BUTTON.instantiate()
			new_smash_button.global_position = tile_map.map_to_local(tile) - Vector2(16, 16)
			#print(tile_pos, " ", global_position, " ", smash_pos, " ", new_smash_button.global_position)
			canvas_layer.add_child(new_smash_button)

func swap_positions():
	if swaps <= 0:
		is_players_turn = true
		return
	var mouse_position = tile_map.local_to_map(get_global_mouse_position())
	#print("Mouse: ", mouse_position)
	var enemies = get_tree().get_nodes_in_group("enemies")
	var swap_enemy = null
	#print("Enemies: ")
	for enemy in enemies:
		#print(enemy.tile_pos)
		if enemy.tile_pos == mouse_position:
			swap_enemy = enemy
	#print("--------")
	if swap_enemy == null:
		#print("Failed")
		is_players_turn = true
		return
	var temp = tile_pos
	tile_pos = swap_enemy.tile_pos
	swap_enemy.tile_pos = temp
	global_position = tile_map.map_to_local(tile_pos)
	swap_enemy.global_position = tile_map.map_to_local(swap_enemy.tile_pos)
	swaps -= 1
	Events.swapped.emit(swap_enemy)
	Events.next_turn.emit()
	

func rotate_tiles():
	if tile_pos.x not in [1, 8] and tile_pos.y not in [1, 8]:
		print(tile_pos)
		var sur_tiles = [Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0)]
		sur_tiles = sur_tiles.map(func(vector): return vector + tile_pos)
		var last_atlas_tile: Vector2i = tile_map.get_cell_atlas_coords(0, sur_tiles[7])
		for i in range(7, 0, -1):
			var new_tile_type = tile_map.get_cell_atlas_coords(0, sur_tiles[i-1])
			tile_map.set_cell(0, sur_tiles[i], 2, new_tile_type)
			modify_restoring_cell(sur_tiles[i], new_tile_type, Level.get_cell_cooldown(sur_tiles[i-1]))
		tile_map.set_cell(0, sur_tiles[0], 2, last_atlas_tile)
		modify_restoring_cell(sur_tiles[0], last_atlas_tile, Level.get_cell_cooldown(sur_tiles[7]))
		Events.screen_shake.emit(3.0)
		Events.player_turn_taken.emit()
		Events.next_turn.emit()
	else:
		is_players_turn = true

func modify_restoring_cell(pos: Vector2i, new_tile_type: Vector2i, cool_down: int):
	match new_tile_type:
		Global.TILE_GROUND:
			Level.delete_restoring_cell(pos)
		Global.TILE_SHATTERED, Global.TILE_ALMOST_SHATTERED, Global.TILE_ALMOST_GROUND, Global.TILE_LAVA:
			Level.update_or_create_restoring_cell(pos, new_tile_type, cool_down)

func _ready():
	#Events.next_turn.connect(_on_next_turn)
	#Events.cell_restored.connect(_on_cell_restored)
	tile_pos = tile_map.local_to_map(global_position)
	global_position = tile_map.map_to_local(tile_pos)
	#set_smash_positions()

func take_turn():
	is_players_turn = true
	set_smash_positions()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_players_turn:
		get_input()

func get_input():
	if Input.is_action_just_pressed("move_up"):
		is_players_turn = false
		change_tile_position(0, -1)
	elif Input.is_action_just_pressed("move_left"):
		is_players_turn = false
		change_tile_position(-1, 0)
	elif Input.is_action_just_pressed("move_down"):
		is_players_turn = false
		change_tile_position(0, 1)
	elif Input.is_action_just_pressed("move_right"):
		is_players_turn = false
		change_tile_position(1, 0)
	elif Input.is_action_just_pressed("rotate"):
		is_players_turn = false
		rotate_tiles()
	elif Input.is_action_just_pressed("swap_positions"):
		is_players_turn = false
		swap_positions()


#func _on_next_turn():
	#set_smash_positions()

#func _on_cell_restored():
	#set_smash_positions()
