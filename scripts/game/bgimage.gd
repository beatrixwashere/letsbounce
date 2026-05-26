extends Sprite2D

var img: Image


func load_buffer(b: PackedByteArray) -> void:
	img = Image.new()
	img.load_png_from_buffer(b)
	texture = ImageTexture.create_from_image(img)
	var sc: float = 1920.0 / texture.get_width()
	scale = Vector2(sc, sc)


func load_image(path: String) -> void:
	img = Image.load_from_file(path)
	texture = ImageTexture.create_from_image(img)
	var sc: float = 1920.0 / texture.get_width()
	scale = Vector2(sc, sc)
