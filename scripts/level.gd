extends Control

class_name Level

const max_enemies: int = 4
const spawn_rate: int = 3
const restore_cooldown: int = 3
@onready var tile_map: TileMap = $TileMap
@onready var player: Player = $Player

const ENEMY = preload("res://scenes/enemy.tscn")

var turns_taken = 0

static var restoring_shattered: Dictionary

static func get_restoring_cells():
	return restoring_shattered
	
static func get_cell_cooldown(key: Vector2i):
	if restoring_shattered.has(key):
		return restoring_shattered[key].cool_down
	else:
		return 0
	
static func update_or_create_restoring_cell(pos: Vector2i, tile_type: Vector2i, cool_down: int):
	if restoring_shattered.has(pos):
		restoring_shattered[pos].tile_type = tile_type
		restoring_shattered[pos].cool_down = cool_down
	else:
		var new_restoring = Global.MyCell.new()
		new_restoring.tile_type = tile_type
		new_restoring.cool_down = cool_down
		restoring_shattered[pos] = new_restoring

static func delete_restoring_cell(pos: Vector2i):
	restoring_shattered.erase(pos)

static func print_restoring():
	var keys = restoring_shattered.keys()
	for key in keys:
		print(key, ": ", "TileType: ", restoring_shattered[key].tile_type, ", CoolDown: ", restoring_shattered[key].cool_down)

func _process(_delta):
	if Input.is_action_just_pressed("skip_turn"):
		Events.next_turn.emit()

func _ready():
	Global.is_lost = false
	Events.next_turn.connect(_on_next_turn)
	Events.game_lost.connect(_on_game_lost)
	Events.enemy_killed.connect(_on_enemy_killed)
	player_take_turn()

func _on_enemy_killed():
	Global.enemies_killed += 1


func _on_game_lost():
	Global.is_lost = true
	
func _on_next_turn():
	update_tiles()
	#print_restoring()
	turns_taken += 1
	if turns_taken % spawn_rate == 0 and get_tree().get_nodes_in_group("enemies").size() < max_enemies:
		spawn_enemy()

func spawn_enemy():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var new_position
	while true:
		var x_pos = rng.randi_range(1, 8)
		var y_pos =rng.randi_range(1, 8)
		if x_pos > y_pos:
			y_pos = 1
		elif x_pos < y_pos:
			x_pos = 1
		new_position = Vector2i(x_pos, y_pos)
		var distance = abs(new_position - player.tile_pos)
		if distance.x + distance.y > 4:
			break
	var new_enemy = ENEMY.instantiate()
	new_enemy.tile_pos = new_position
	add_child(new_enemy)
	
	

func player_take_turn():
	player.take_turn()
	
func update_tiles():
	var destroyed_tiles: Array[Vector2i] = tile_map.get_used_cells_by_id(0, 2, Global.TILE_SHATTERED)
	destroyed_tiles +=tile_map.get_used_cells_by_id(0, 2, Global.TILE_ALMOST_GROUND)
	destroyed_tiles += tile_map.get_used_cells_by_id(0, 2, Global.TILE_LAVA)
	destroyed_tiles +=tile_map.get_used_cells_by_id(0, 2, Global.TILE_ALMOST_SHATTERED)
	for tile: Vector2i in destroyed_tiles:
		if restoring_shattered.has(tile):
			restoring_shattered[tile].cool_down += 1
			if restoring_shattered[tile].cool_down == restore_cooldown:
				var old_tile_type = tile_map.get_cell_atlas_coords(0, tile)
				match old_tile_type:
					Global.TILE_LAVA, Global.TILE_ALMOST_SHATTERED:
						tile_map.set_cell(0, tile, 2, Global.TILE_GROUND)
						Level.delete_restoring_cell(tile)
					Global.TILE_SHATTERED, Global.TILE_ALMOST_GROUND:
						tile_map.set_cell(0, tile, 2, Global.TILE_GROUND)
						Level.delete_restoring_cell(tile)
				restoring_shattered.erase(tile)
				Events.cell_restored.emit()
			elif restoring_shattered[tile].cool_down == restore_cooldown - 1:
				var new_tile_type = tile_map.get_cell_atlas_coords(0, tile) + Vector2i(1, 0)
				tile_map.set_cell(0, tile, 2, new_tile_type)
				Level.update_or_create_restoring_cell(tile, new_tile_type, Level.get_cell_cooldown(tile))
		else:
			Level.update_or_create_restoring_cell(tile, tile_map.get_cell_atlas_coords(0, tile), 0)
	enemies_take_turn()

func enemies_take_turn():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.take_turn()
	player_take_turn()
