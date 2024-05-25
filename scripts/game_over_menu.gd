extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var btn_restart: Button = $PanelContainer/VBoxContainer/BtnRestart
@onready var btn_main: Button = $PanelContainer/VBoxContainer/BtnMain

func _ready():
	Events.game_lost.connect(_on_game_lost)
	animation_player.play("RESET")

func resume():
	get_tree().paused = false
	deactivate_buttons()
	animation_player.play_backwards("blur")

func restart():
	resume()
	Global.is_lost = false
	get_tree().reload_current_scene()

func pause():
	get_tree().paused = true
	activate_buttons()
	animation_player.play("blur")


func activate_buttons():
	btn_restart.disabled = false
	btn_main.disabled = false

func deactivate_buttons():
	btn_restart.disabled = true
	btn_main.disabled = true


func _on_btn_restart_pressed():
	restart()

func _on_btn_main_pressed():
	resume()
	Global.is_lost = false
	Global.set_scene(Global.SCENES.MAIN)

func _on_game_lost():
	Global.is_lost = true
	pause()
