extends Node2D
class_name Player

const SMASH_BUTTON = preload("res://scenes/smash_button.tscn")
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var tile_map: TileMap = get_node("/root/Level/TileMap")
var tile_pos: Vector2i = Vector2i.ZERO

func change_tile_position(x: int, y: int):
	var new_pos = tile_pos + Vector2i(x, y)
	var is_hazardous = tile_map.get_cell_tile_data(0, new_pos).get_custom_data('hazardous')
	if !is_hazardous:
		tile_pos = new_pos
		global_position = tile_map.map_to_local(tile_pos)
	Events.next_turn.emit()

func set_smash_positions():
	var smash_positions: Array[Vector2]
	smash_positions.resize(4)
	for axis in [0, 1]:
		for j in [-1, 1]:
			var smash_pos: Vector2i = tile_pos + Vector2i(j*(axis^1), j*axis)
			var tile_type: Vector2i = tile_map.get_cell_atlas_coords(0, smash_pos)
			if tile_type != Global.TILE_LAVA:
				var new_smash_button: Button = SMASH_BUTTON.instantiate()
				new_smash_button.global_position = tile_map.map_to_local(smash_pos) - Vector2(16, 16)
				#print(tile_pos, " ", global_position, " ", smash_pos, " ", new_smash_button.global_position)
				canvas_layer.add_child(new_smash_button)

func rotate_tiles():
	Events.screen_shake.emit(3.0)
	Events.next_turn.emit()

func _ready():
	Events.next_turn.connect(_on_next_turn)
	tile_pos = tile_map.local_to_map(global_position)
	global_position = tile_map.map_to_local(tile_pos)
	set_smash_positions()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("move_up"):
		change_tile_position(0, -1)
	elif Input.is_action_just_pressed("move_left"):
		change_tile_position(-1, 0)
	elif Input.is_action_just_pressed("move_down"):
		change_tile_position(0, 1)
	elif Input.is_action_just_pressed("move_right"):
		change_tile_position(1, 0)
	elif Input.is_action_just_pressed("rotate"):
		rotate_tiles()

func _on_next_turn():
	set_smash_positions()
