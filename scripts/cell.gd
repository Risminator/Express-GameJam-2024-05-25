extends Area2D
class_name cell

const max_states: int = 2
@export var health: int

@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.frame = health
