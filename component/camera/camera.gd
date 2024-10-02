extends Camera2D

@export var game: Game
@export var pan_speed: float = 1.0
@export var can_pan: bool
@export var can_zoom: bool
@export var press_duration: float = .5
@export var zoom_speed: float = 1 

var initial_zoom: Vector2 
var initial_distance: float 
var touch_points: Dictionary = {}
var initial_angle: float 
var current_angle: float
var touch_timer: Timer = Timer.new() 
var is_target_selected: bool = false 
var selected_target_position = null 

func _ready() -> void:
	game.connect("ready", self._initialize_camera) 
	touch_timer.wait_time = press_duration
	touch_timer.one_shot = true
	add_child(touch_timer)

func _initialize_camera() -> void: 
	var viewport_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width") / game.dimension.x, 
		ProjectSettings.get_setting("display/window/size/viewport_height") / game.dimension.y
	)
	var average_zoom: float = (viewport_size.x + viewport_size.y) / 2
	average_zoom = clampf(average_zoom, 0.1, 10)
	zoom = Vector2(average_zoom, average_zoom)
	print_debug("Setting zoom to ", zoom)
	# Center the camera
	position = game.dimension * 0.5

func _input(event):
	if event is InputEventScreenTouch:
		_process_touch(event) 
		_process_touch_pressed(event) 
	elif event is InputEventScreenDrag:
		_process_drag(event) 

func _process_touch(event: InputEventScreenTouch):
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)
		
	if touch_points.size() == 2:
		var touch_positions = touch_points.values()
		initial_distance = touch_positions[0].distance_to(touch_positions[1])
		initial_zoom = zoom
	elif touch_points.size() < 2:
		initial_distance = 0

func _process_drag(event: InputEventScreenDrag):
	touch_points[event.index] = event.position
	
	if touch_points.size() == 1:
		if can_pan:
			offset -= event.relative * pan_speed
			
	elif touch_points.size() == 2:
		var touch_positions = touch_points.values()
		var current_distance = touch_positions[0].distance_to(touch_positions[1])
		var zoom_factor = initial_distance / current_distance
		
		if can_zoom:
			zoom = initial_zoom / zoom_factor
			
		_limit_zoom(zoom)
func _process_touch_pressed(event: InputEventScreenTouch):
	if event.pressed and touch_timer.is_stopped():
		touch_timer.start()
		
	if !event.pressed and !touch_timer.is_stopped():
		var grid_cell_position = game.pos_to_grid_coordinate(get_global_mouse_position())
		var global_cell_position = Vector2(grid_cell_position.x * game.cell_size + game.position.x, grid_cell_position.y * game.cell_size + game.position.y)
		
		if grid_cell_position != Vector2i(-1, -1):
			var unit_at_position : Unit = game.map_unit.get(grid_cell_position)
			
			if unit_at_position && !is_target_selected && !unit_at_position.isMoving:
				is_target_selected = true
				selected_target_position = grid_cell_position
				
			elif !unit_at_position && is_target_selected && selected_target_position:
				var target_unit = game.map_unit.get(selected_target_position)
				game.map_unit[grid_cell_position] = Unit.empty_unit()
				
				var source_pos := Vector2i(selected_target_position)
				var destination_pos := Vector2i(grid_cell_position)
				
				target_unit.animate_to(PackedVector2Array([global_cell_position]), func(): update_map(source_pos, destination_pos))
				
				is_target_selected = false
				selected_target_position = null
				
			elif !unit_at_position:
				var new_unit := Unit.new()
				var radius := game.cell_size / 2
				
				new_unit.setup(radius, 1000 / game.cell_size * 2)
				new_unit.position = global_cell_position
				
				game.map_unit[grid_cell_position] = new_unit
				game.add_child(new_unit)

func _limit_zoom(new_zoom: Vector2): 
	if new_zoom.x < 0.1:
		zoom.x = 0.1
		
	if new_zoom.y < 0.1:
		zoom.y = 0.1
		
	if new_zoom.x > 10:
		zoom.x = 10
		
	if new_zoom.y > 10:
		zoom.y = 10

func update_map(source_pos: Vector2i, target_pos: Vector2i): 
	var unit_to_move = game.map_unit.get(source_pos)
	
	game.map_unit.erase(source_pos)
	game.map_unit[target_pos] = unit_to_move
