extends Node
class_name TextureEdit

static func padded_ratio_resize_texture(texture: Texture2D, clamp_size: Vector2i):
	var text_size = Vector2i(texture.get_size())
	var img_scale = Vector2(clamp_size) / Vector2(text_size)
	var scale_f = minf(img_scale.x, img_scale.y)
	var new_width = ceil(text_size.x * scale_f)
	var new_height = ceil(text_size.y * scale_f)
	var scaled_img = texture.get_image()
	scaled_img.resize(new_width, new_height)
	var pos_x = (clamp_size.x - new_width) / 2
	var pos_y = (clamp_size.y - new_height) / 2
	
	var new_rect = Rect2i(0,0, new_width, new_height)
	var new_pos = Vector2i(pos_x, pos_y)
	
	scaled_img.convert(Image.FORMAT_RGBA8)
	var img = Image.create(clamp_size.x, clamp_size.y, false,Image.FORMAT_RGBA8)
	img.blit_rect(scaled_img, new_rect, new_pos)
	return ImageTexture.create_from_image(img)
