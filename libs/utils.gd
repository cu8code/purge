extends Node
class_name Utils

static func create_solid_rect_image(color: Color, size: Vector2) -> Image:
	var res := Image.create_empty(size.x,size.y,false, Image.FORMAT_ASTC_4x4)
	if res.is_compressed():
		res.decompress()
	for x in range(0, size.x):
		for y in range(0, size.y):
			res.set_pixel(x,y,color)
	return res

static func create_solid_circle_image(color: Color, radius: int) -> Image:
	var size := Vector2(radius * 2, radius * 2)
	var res := Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	if res.is_compressed():
		res.decompress()
	for x in range(size.x):
		for y in range(size.y):
			if (x - radius) * (x - radius) + (y - radius) * (y - radius) <= radius * radius:
				res.set_pixel(x, y, color)
			else:
				res.set_pixel(x,y, Color(Color.WHITE, 0))
	return res
