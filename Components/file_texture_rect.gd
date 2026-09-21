extends TextureRect
class_name FileTextureRect

var _image_path: String
var image_path: String:
	set(value): set_image(value)
	get: return _image_path
var is_image_set: bool:
	get: return not not image_path
var external_thread_queue: ThreadQueue
var _queue_number: int
var true_image_size: Vector2
var place_holder_texture: Texture2D
const MAX_EMOJI_SIZE = 2048  #~24MiB per unique emoji

var _emoji_icon = ""
var emoji_icon: String:
	get: return _emoji_icon
	set(value): set_emoji_icon(value)
var emoji_font_size: int = 16


func set_emoji_icon(emoji: String):
	_emoji_icon = emoji
	var font_details = EmojiIcon.get_font_font_size_font_color_for_emojifont(self)
	texture = EmojiIcon.get_img_texture(emoji, font_details[0], emoji_font_size, font_details[2])
	place_holder_texture = texture


func set_image(file_path):
	_image_path = file_path
	if not size:
		return
	if not $VisibleOnScreenNotifier2D.is_on_screen() and texture.get_height() < size.y:
		var call_again = set_image.bind(file_path)
		if not $VisibleOnScreenNotifier2D.screen_entered.is_connected(call_again):
			$VisibleOnScreenNotifier2D.screen_entered.connect(call_again, CONNECT_ONE_SHOT)
		return
	
	if _queue_number:
		external_thread_queue.remove(_queue_number)
	_queue_number = external_thread_queue.enqueue(image_2_texture.bind(file_path, size.y), set_texture)

func image_2_texture(file_path, height):
	if not height or not file_path:
		return
	var img = Image.load_from_file(file_path)
	height = height if height < img.get_height() else img.get_height()
	var img_scale = height / img.get_height() if height < img.get_height() else 1
	
	img.resize(img.get_width() * img_scale, height)
	var img_texture = ImageTexture.create_from_image(img)
	img = null
	return img_texture


func _on_resized() -> void:
	# Extra space gives extra notification time before visible on screen on scroll
	$VisibleOnScreenNotifier2D.rect = get_rect().grow(size.y)
	# Fix loading all textures that on not yet visible on screen
	await RenderingServer.frame_post_draw
	if image_path:
		if texture:
			if texture.get_size().y < size.y or texture.get_size().y > size.y * 1.2:
					image_path = image_path
	else:
		if emoji_font_size < size.y:
			emoji_font_size = min(int(size.y * 1.2), MAX_EMOJI_SIZE)
			emoji_icon = emoji_icon
		elif emoji_font_size > ceil(size.y*2):
			emoji_font_size = min(int(size.y * 1.2), MAX_EMOJI_SIZE)
			emoji_icon = emoji_icon


func _on_off_screen_delete_timer_timeout() -> void:
	if image_path and not $VisibleOnScreenNotifier2D.is_on_screen():
		texture = place_holder_texture
	

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if image_path and texture == place_holder_texture:
		image_path = image_path


func _on_tree_exiting() -> void:
	texture = null
	place_holder_texture = null
	external_thread_queue.remove(_queue_number)
