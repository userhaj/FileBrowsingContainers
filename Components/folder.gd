extends TextureButton
class_name FolderLargeIconButton

signal double_clicked

var path: String
var is_selected: bool = false
var hover_label: Label
var set_image_thread: Thread
var is_image_set: bool = false
var image_path: String
var _thread_queue: ThreadQueue
var icons : Dictionary = {"dll": "📚", "txt": "🗒️", "exe": "🚀", "conf": "⚙️",\
 "ini": "⚙️", "py": "🐍", "pyw": "🐍", "url": "🕸️", "htm": "🕸️", "html": "🕸️",\
"lnk": "🔗", "ods": "📊", "xls": "📊", "xlsx": "📊", "json": "📔", "jar": "☕",\
"properties": "⚙️", "mkv": "🎞️", "webm": "🎞️", "flv": "🎞️", "3g2": "🎞️", \
"3gp": "🎞️", "amv": "🎞️", "asf": "🎞️", "avi": "🎞️", "gifv": "🎞️", "m4v": "🎞️",\
 "mov": "🎞️", "qt": "🎞️", "mpg": "🎞️", "mpeg": "🎞️", "mts": "🎞️", "m2ts": "🎞️",\
 "ts": "🎞️", "ogv": "🎞️", "rmvb": "🎞️", "wmv": "🎞️", "mp4": "🎞️", "mp3": "🎵",\
"wav": "🎵", "jpg": "🖼️", "png": "🖼️", "gif": "🖼️", "zip": "🗜️", "rar": "🗜️", \
"x86_64": "🚀", "pdf": "🖨️", "ogg": "🎵", "c": "🌊", "cpp": "🌊", "sh": "🐚", \
"desktop": "🖥️", "h": "🗣️", "so": "🎁", "md": "🗒️", "drawio": "📝", "bin": "💿",\
"iso": "💿", "stl": "🧵", "gcode": "🧵", "arm64": "🦾", "svg": "🖼️",\
 "hpp": "🗣️", "cfg": "⚙️", "apk": "🤖", "docx": "🗒️", "ppt": "📽️"}

var icon: String = "📄"
var clicked: bool = false

#var icon: String:
	#get: return $VBoxContainer/ImageLabel.text

func _ready() -> void:
	# Custom object theme must be applied
	#_copy_root_theme()
	#get_tree().root.theme_changed.connect(_copy_root_theme)
	_on_resized()

#func _copy_root_theme():
	#var theme_resource: Theme = get_tree().root.get_theme()
	#if theme_resource:
		#set_theme(theme_resource)
		#$VBoxContainer/ImageLabel.label_settings.font = theme_resource.get_font("font", "EmojiFont")
		#$VBoxContainer/ImageLabel.label_settings.font_size = theme_resource.get_font_size("font_size", "EmojiFont")
		#$VBoxContainer/ImageLabel.label_settings.font_color = theme_resource.get_color("font_color", "EmojiFont")

# Optional work queue
func set_thread_queue(thread_queue: ThreadQueue):
	self._thread_queue = thread_queue
	$VBoxContainer/FileTextureRect.external_thread_queue = thread_queue



static func is_image_extension(extension: String):
	return extension.to_lower() in ["png", "svg", "bmp", "jpg", "ktx", "tga", "webp"]

func set_image(full_path: String):
	$VBoxContainer/FileTextureRect.visible = true
	$VBoxContainer/FileTextureRect.image_path = full_path


func select():
	self.is_selected = true
	$SelectColorRect.show()

func deselect():
	self.is_selected = false
	$SelectColorRect.hide()

func _on_resized():
	$VisibleOnScreenNotifier2D.rect = get_rect()
	$VBoxContainer/FileTextureRect.custom_maximum_size = Vector2(-1, size.y - $VBoxContainer/NameLabel.size.y)

func set_path(abs_path: String, text_icon: String = ""):
	# Sanitize path
	self.path = abs_path.simplify_path()
	var last_index = self.path.get_slice_count("/") - 1
	# Update folder name
	$VBoxContainer/NameLabel.text = self.path.get_slice("/", last_index)
	$VBoxContainer/NameLabel.tooltip_text = $VBoxContainer/NameLabel.text
	tooltip_text = $VBoxContainer/NameLabel.text

	var ext = self.path.get_extension()
	# Use custom icon if requested, else find icon or default emoji
	icon = icons.get(ext, "📄") if text_icon == "" else text_icon

	$VBoxContainer/FileTextureRect.emoji_icon = icon

	
		
func get_abs_path():
	return self.path


func _on_double_click_timer_timeout() -> void:
	clicked = false

func start_rename():
	$NameLineEdit.text =  path.get_file()
	$NameLineEdit.show()
	$NameLineEdit.grab_focus()

# Rename rejected
func _on_name_line_edit_plus_text_change_rejected(_rejected_substring: String) -> void:
	$NameLineEdit.text = ""
	$NameLineEdit.hide()

# Rename rejected
func _on_name_line_edit_plus_focus_exited() -> void:
	_on_name_line_edit_plus_text_change_rejected("")

# Rename Submitted
func _on_name_line_edit_plus_text_submitted(new_filename: String) -> void:
	var folder = path.get_base_dir()
	var new_path = folder.path_join(new_filename)
	var rename_attempt = DirAccess.rename_absolute(path, new_path)
	$NameLineEdit.hide()
	if rename_attempt == OK:
		set_path(new_path)


func _on_button_down() -> void:
	if clicked:
		double_clicked.emit()
		clicked = false
	else:
		clicked = true
		$DoubleClickTimer.start(0.5)
