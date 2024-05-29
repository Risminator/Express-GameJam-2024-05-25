extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var btn_resume: Button = $PanelContainer/VBoxContainer/BtnResume
@onready var btn_restart: Button = $PanelContainer/VBoxContainer/BtnRestart
@onready var btn_main: Button = $PanelContainer/VBoxContainer/BtnMain
@onready var label_score: Label = $PanelContainer/VBoxContainer/LabelScore

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
	Global.enemies_killed = 0
	Level.restoring_shattered.clear()
	get_tree().reload_current_scene()

func pause():
	get_tree().paused = true
	activate_buttons()
	animation_player.play("blur")

func testEsc():
	if Input.is_action_just_pressed("Pause") and !get_tree().paused and !Global.is_lost:
		label_score.visible = false
		pause()
	elif Input.is_action_just_pressed("Pause") and get_tree().paused and !Global.is_lost:
		resume()

func activate_buttons():
	btn_resume.disabled = false
	btn_restart.disabled = false
	btn_main.disabled = false

func deactivate_buttons():
	btn_resume.disabled = true
	btn_restart.disabled = true
	btn_main.disabled = true

func _on_btn_resume_pressed():
	resume()

func _on_btn_restart_pressed():
	restart()

func _on_btn_main_pressed():
	resume()
	Global.set_scene(Global.SCENES.MAIN)

func _process(_delta):
	testEsc()

func _on_game_lost():
	Global.is_lost = true
	if Global.max_enemies_killed < Global.enemies_killed:
		Global.max_enemies_killed = Global.enemies_killed
	label_score.text = "Your Score: " + str(Global.enemies_killed) + "\nHigh Score: " + str(Global.max_enemies_killed)
	btn_resume.disabled = true
	btn_resume.visible = false
	label_score.visible = true
	pause()
