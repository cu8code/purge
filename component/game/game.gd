extends Node2D
class_name Game

@export var max_player: int
@export var number_of_row: int
@export var number_of_col: int
@export var cell_size: int
@export var color: Color

var noise_texture: NoiseTexture2D
var dimension: Vector2
var map_unit : Dictionary = {}

func _ready() -> void:
	cell_size = ((ProjectSettings.get_setting("display/window/size/viewport_width") / number_of_col) + (ProjectSettings.get_setting("display/window/size/viewport_height") / number_of_row))/2
	
	dimension = Vector2(
		cell_size * number_of_col,  # Corrected to use number_of_col for width
		cell_size * number_of_row   # Corrected to use number_of_row for height
	)
	
	noise_texture = NoiseTexture2D.new()
	noise_texture.color_ramp = preload("res://data/gradient.tres")
	noise_texture.width = number_of_col  # Corrected width
	noise_texture.height = number_of_row  # Corrected height
	
	var noise := FastNoiseLite.new()
	noise.set_seed(randi_range(0, 1000))
	noise_texture.set_noise(noise)
	
	await noise_texture.changed
	queue_redraw()

func _draw():
	if noise_texture:
		var val := noise_texture.get_image()
		if val:
			for x in range(0, number_of_col):
				for y in range(0, number_of_row):
					draw_rect(
						Rect2i(Vector2i(x * cell_size, y * cell_size), Vector2(cell_size, cell_size)),
						val.get_pixel(x, y)
					)
			for x in range(0, val.get_width()):
				draw_line(
					Vector2i(x * cell_size, 0),
					Vector2i(x * cell_size, dimension.y),
					color
				)
			for y in range(0, val.get_height()):
				draw_line(
					Vector2i(0, y * cell_size),
					Vector2i(dimension.x, y * cell_size),
					color
				)
func _is_in(pos: Vector2) -> bool:
	var origin := position
	var x_in_range := pos.x >= origin.x and pos.x <= origin.x + dimension.x
	var y_in_range := pos.y >= origin.y and pos.y <= origin.y + dimension.y
	return x_in_range and y_in_range

func pos_to_grid_coordinate(pos: Vector2) -> Vector2i:
	if _is_in(pos):
		return Vector2i(
			int((pos.x - position.x) / cell_size),
			int((pos.y - position.y) / cell_size)
		)
	return Vector2i(-1, -1)

# Define heuristic function (Manhattan distance)
func heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func _get_path(pos: Vector2i, final: Vector2i) -> Array:
	return []
