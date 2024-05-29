extends Node

const SCENES = {
	MAIN = "menus/main",
	LEVEL = "levels/level",
	DEBUG = "_debug/test"
}

const TILE_BOUNDER = Vector2i(5, 0)
const TILE_GROUND = Vector2i(4, 0)
const TILE_ALMOST_GROUND = Vector2i(3, 0)
const TILE_SHATTERED = Vector2i(2, 0)
const TILE_ALMOST_SHATTERED = Vector2i(1, 0)
const TILE_LAVA = Vector2i(0, 0)

var is_lost

var enemies_killed = 0
var max_enemies_killed = 0

class MyCell:
	var tile_type: Vector2i
	var cool_down: int


func set_scene(scene_name: String):
	get_tree().change_scene_to_file("res://scenes/" + scene_name + ".tscn")
