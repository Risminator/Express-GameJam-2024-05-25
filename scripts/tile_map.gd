extends TileMap

var astar: AStarGrid2D = AStarGrid2D.new()
var tilemap_size = get_used_rect().end - get_used_rect().position
# Called when the node enters the scene tree for the first time.
func _ready():
	Events.next_turn.connect(_on_next_turn)
	
	var map_rect = Rect2i(Vector2i.ZERO, tilemap_size)
	astar.region = map_rect
	astar.cell_size = get_tileset().tile_size
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			var coords = Vector2i(i, j)
			var tile_data = get_cell_tile_data(0, coords)
			if tile_data and tile_data.get_custom_data('hazardous') == true:
				astar.set_point_solid(coords)

func _on_next_turn():
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			var coords = Vector2i(i, j)
			var tile_data = get_cell_tile_data(0, coords)
			if tile_data and tile_data.get_custom_data('hazardous') == true:
				astar.set_point_solid(coords)
