extends Node

const SCENES = {
	MAIN = "menus/main",
	LEVEL = "levels/level",
	DEBUG = "_debug/test"
}

const TILE_GROUND = Vector2i(2, 0)
const TILE_SHATTERED = Vector2i(1, 0)
const TILE_LAVA = Vector2i(0, 0)

var is_lost

func set_scene(scene_name: String):
	get_tree().change_scene_to_file("res://scenes/" + scene_name + ".tscn")

"""func _process(delta):
	if Input.is_action_just_pressed("restart"):
		set_scene(SCENES.LEVEL)
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()"""
