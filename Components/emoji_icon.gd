extends Node
class_name EmojiIcon

static var cached_icon: Dictionary[String,WeakRef] = {}

static func get_img_texture(emoji: String, font: Font, font_size: int, font_color: Color = Color.BLACK):
	# Clear unreferenced objects
	for key in cached_icon:
			if not cached_icon.get(key).get_ref():
				cached_icon.erase(key)

	var cache_key = str(font_size)+ str(emoji) + str(font) + str(font_color)
	var cached_img_ref = cached_icon.get(cache_key)
	
	# Check cache, return texture if cached
	if cached_img_ref:
		# Must assign to check value
		var cached_img = cached_img_ref.get_ref()
		if cached_img:
			return cached_img
	
	
	
	# Create new texture and add it to cache
	var img_array = TextRenderer.batch_text_to_image([emoji], font, font_size, font_color)
	if img_array:
		var texture = ImageTexture.create_from_image(img_array[0])
		img_array[0] = null
		cached_icon.set(cache_key, weakref(texture))
		return texture
	
	return Image.create_empty(font_size, font_size, false,Image.FORMAT_RGBA8)

# Returns array of [font, font size, font color] of type [Font, int, Color]
static func get_font_font_size_font_color_for_emojifont(caller=null) -> Array:
	var font
	var font_color
	var font_size
	var found_theme: Theme
	if caller:
		if caller.theme and caller.theme.get_font("font", "EmojiFont"):
			found_theme = caller.theme
		elif caller.get_window() and caller.get_window().theme:
			found_theme = caller.get_window().theme
		elif caller.is_inside_tree() and caller.get_tree().root.theme and caller.get_tree().root.theme.get_font("font", "EmojiFont"):
			found_theme = caller.get_tree().root.theme
		
	
	# Succesfully found a theme with "EmojiFont" object unique to this project!
	if found_theme:
		font = found_theme.get_font("font", "EmojiFont")
		font_size = found_theme.get_font_size("font_size", "EmojiFont")
		font_color = found_theme.get_color("font_color", "EmojiFont")
	
	if not font: # DEFAULT
		# Default to font with known emojis if none other found
		font = preload("uid://0h6c0qjdknr1")
		font_size = 16
		font_color = Color.WHITE
		
	return [font, font_size, font_color]
