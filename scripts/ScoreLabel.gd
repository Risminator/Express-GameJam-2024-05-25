extends Label

var enemies_killed = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed():
	enemies_killed += 1
	text = "Score: " + str(enemies_killed)
