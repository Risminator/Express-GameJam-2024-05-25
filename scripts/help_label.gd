extends Label

var swaps = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	text = "ЛКМ на клетку - сломать клетку (нужно 2 удара)\nПКМ - перемешать клетки вокруг по часовой стрелке (3x3)\nE - поменяться местами с противником на курсоре (x" + str(swaps) + ")"
	Events.swapped.connect(_on_swapped)



func _on_swapped(_enemy):
	swaps -= 1
	text = "ЛКМ на клетку - сломать клетку (нужно 2 удара)\nПКМ - перемешать клетки вокруг по часовой стрелке (3x3)\nE - поменяться местами с противником на курсоре (x" + str(swaps) + ")"
