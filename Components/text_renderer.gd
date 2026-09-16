extends Control
class_name TextRenderer

static func batch_text_to_image(text_array: Array, font: Font, font_size: int = 16, text_color: Color = Color.WHITE) -> Array[Image]:
	var created_rids = [] # Used to track resources to clear later
	var views = [] # Used to get final images
	for text in text_array:
		# Empty image on empty string
		#if text.is_empty():
			#image_array.append(Image.create(1, 1, false, Image.FORMAT_RGBA8))
			#continue
		
		# Create canvas/viewport to render off screen
		var canvas = RenderingServer.canvas_create()
		var view = RenderingServer.viewport_create()
		var item = RenderingServer.canvas_item_create()
		created_rids.append(canvas)
		created_rids.append(view)
		created_rids.append(item)
		views.append(view)
		RenderingServer.viewport_set_transparent_background(view, true)
		RenderingServer.viewport_set_active(view, true)
		RenderingServer.viewport_attach_canvas(view, canvas)
		RenderingServer.canvas_item_set_parent(item, canvas)
		RenderingServer.viewport_set_update_mode(view, RenderingServer.VIEWPORT_UPDATE_ONCE)
		 
		# Apply text with given font
		var string_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var width = ceil(string_size.x)
		var ascent = font.get_ascent(font_size)
		var descent = font.get_descent(font_size)
		var height = ascent + descent
		RenderingServer.viewport_set_size(view, width, height)
		
		font.draw_string(item, Vector2(0, ascent), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)
		
	
	# Force all fonts to render
	RenderingServer.force_draw(false)
	# Get newly rendered frames from views
	var image_array = views.map(func(view)->Image: return RenderingServer.texture_2d_get(RenderingServer.viewport_get_texture(view))) 
	# clean up memory used
	for rid in created_rids:
		RenderingServer.free_rid(rid)
	
	return image_array as Array[Image]
