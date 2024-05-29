extends Control

@onready var exit_button: Button = $BtnExit

func _ready():
	if OS.has_feature("web"):
		exit_button.disabled = true
		exit_button.visible = false

func _on_btn_start_pressed():
	Global.is_lost = false
	Global.enemies_killed = 0
	Global.set_scene(Global.SCENES.LEVEL)


func _on_btn_exit_pressed():
	quit_game()


func quit_game():
	get_tree().quit()
