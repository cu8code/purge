extends Node2D
class_name Unit

@export var radius: int = 1
@export var speed: float = 1000

var texture: Texture2D
var isMoving: bool = false
var empty: bool = false

static func empty_unit() -> Unit:
	var u := Unit.new()
	u.empty = true
	return u

func animate_to(position: Array[Vector2], callback: Callable) -> void:
	if !isMoving and !empty:
		var tween := get_tree().create_tween()
		isMoving = true
		var finalPos: Vector2
		for x in position:
			var duration:= global_position.distance_to(x) / speed
			tween.tween_property(self,"global_position",x,duration)
			await tween.finished
		callback.call()
		isMoving = false

func setup(radius: int, speed) -> void:
	if speed:
		print(speed)
		self.speed = speed
	self.radius = radius
	var img := Utils.create_solid_circle_image(Color.GREEN, radius)
	var sprite := Sprite2D.new()
	sprite.position.x += radius
	sprite.position.y += radius
	sprite.texture = ImageTexture.create_from_image(img)
	add_child(sprite)
