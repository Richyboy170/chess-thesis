extends Node

## ThemeManager - Centralized font and theme management
## Provides easy-to-adjust font sizes throughout the application

# Font resource
var anime_font: FontFile = null

# Font size presets - adjust these to change sizes globally
var font_sizes = {
	"title": 96,           # Main titles (e.g., "SELECT CHARACTERS", "CHESSBOARD")
	"heading": 64,         # Section headings
	"subheading": 48,      # Player names, subsections
	"body": 40,            # Character names, regular text
	"timer": 56,           # Timer display
	"piece": 112,          # Chess pieces
	"captured": 40,        # Captured pieces display
	"dialog_title": 56,    # Dialog titles
	"dialog_text": 36,     # Dialog content
	"button": 40           # Button text
}

func _ready():
	load_fonts()
	print("ThemeManager initialized with anime font")

func load_fonts():
	"""Load the anime-style font from assets"""
	var font_path = "res://assets/fonts/Bangers-Regular.ttf"
	if FileAccess.file_exists(font_path):
		anime_font = load(font_path)
		print("Anime font loaded: ", font_path)
	else:
		push_error("Failed to load anime font: ", font_path)

func get_font() -> FontFile:
	"""Returns the anime font resource"""
	return anime_font

func get_font_size(size_name: String) -> int:
	"""
	Get a font size by preset name.
	Args:
		size_name: Name of the size preset (e.g., "title", "body", "timer")
	Returns:
		Font size in pixels
	"""
	if size_name in font_sizes:
		return font_sizes[size_name]
	push_warning("Font size '", size_name, "' not found, returning default")
	return 20  # Default fallback size

func set_font_size(size_name: String, new_size: int):
	"""
	Update a font size preset.
	Args:
		size_name: Name of the size preset to update
		new_size: New size in pixels
	"""
	if size_name in font_sizes:
		font_sizes[size_name] = new_size
		print("Updated font size '", size_name, "' to ", new_size)
	else:
		push_warning("Cannot set font size '", size_name, "' - preset doesn't exist")

func apply_font_to_label(label: Label, size_name: String = "body"):
	"""
	Applies the anime font and size to a Label node.
	Args:
		label: The Label node to style
		size_name: Font size preset to use
	"""
	if label and anime_font:
		label.add_theme_font_override("font", anime_font)
		label.add_theme_font_size_override("font_size", get_font_size(size_name))

func apply_font_to_button(button: Button, size_name: String = "button"):
	"""
	Applies the anime font and size to a Button node.
	Args:
		button: The Button node to style
		size_name: Font size preset to use
	"""
	if button and anime_font:
		button.add_theme_font_override("font", anime_font)
		button.add_theme_font_size_override("font_size", get_font_size(size_name))

func apply_theme_to_container(container: Node, recursive: bool = true):
	"""
	Applies the anime font theme to all Label and Button children in a container.
	Args:
		container: The parent node to process
		recursive: If true, processes all descendants
	"""
	if not anime_font:
		return

	for child in container.get_children():
		if child is Label:
			# Apply font based on context
			var size_preset = "body"
			if "Title" in child.name or "TITLE" in child.text:
				size_preset = "title"
			elif "Heading" in child.name:
				size_preset = "heading"
			elif "Player" in child.name and "Name" in child.name:
				size_preset = "subheading"
			elif "Timer" in child.name:
				size_preset = "timer"
			elif "Character" in child.name:
				size_preset = "body"

			apply_font_to_label(child, size_preset)

		elif child is Button:
			apply_font_to_button(child, "button")

		# Recursively apply to children
		if recursive and child.get_child_count() > 0:
			apply_theme_to_container(child, true)
