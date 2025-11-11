extends Node
class_name BoardThemeLoader

## BoardThemeLoader
## Handles loading of chessboard themes for characters
## Supports both image-based and color-based theming

## Theme data structure returned by load_theme()
class ThemeData:
	var has_image: bool = false
	var image_texture: Texture2D = null
	var light_color: Color = Color.WHITE
	var dark_color: Color = Color.BLACK
	var square_opacity: float = 0.7  # Used when no image present
	var image_mode_square_opacity: float = 0.0  # Used when image is present

	func _init(p_has_image: bool = false, p_texture: Texture2D = null,
			   p_light: Color = Color.WHITE, p_dark: Color = Color.BLACK,
			   p_opacity: float = 0.7, p_image_opacity: float = 0.0):
		has_image = p_has_image
		image_texture = p_texture
		light_color = p_light
		dark_color = p_dark
		square_opacity = p_opacity
		image_mode_square_opacity = p_image_opacity

## Load theme for a specific character
## Returns ThemeData with image and/or color information
static func load_theme(character_id: int) -> ThemeData:
	print("BoardThemeLoader: Loading theme for character ", character_id)

	var char_path = "res://assets/characters/character_" + str(character_id + 1) + "/"
	var chessboard_path = char_path + "chessboard/"

	# Try to load theme configuration file (for colors)
	var theme_config = load_theme_config(character_id)
	var light_color = Color.WHITE
	var dark_color = Color.BLACK
	var use_image = true
	var image_mode_opacity = 0.0

	if theme_config != null:
		light_color = theme_config.get_light_color()
		dark_color = theme_config.get_dark_color()
		use_image = theme_config.should_use_image()
		image_mode_opacity = theme_config.get_square_opacity_for_image_mode()
		print("BoardThemeLoader: Loaded color config - Light: ", light_color, ", Dark: ", dark_color)
	else:
		# Fallback to GameState colors if no config file exists
		var colors = GameState.get_character_board_colors(character_id)
		light_color = colors["light"]
		dark_color = colors["dark"]
		print("BoardThemeLoader: Using fallback colors from GameState")

	# Try to load background image if enabled
	var image_texture: Texture2D = null
	if use_image:
		image_texture = load_theme_image(chessboard_path)

	if image_texture != null:
		print("BoardThemeLoader: Theme image loaded successfully")
		return ThemeData.new(true, image_texture, light_color, dark_color, 0.7, image_mode_opacity)
	else:
		print("BoardThemeLoader: No theme image found, using color-based theme")
		return ThemeData.new(false, null, light_color, dark_color, 0.7, image_mode_opacity)

## Load theme configuration script for a character
static func load_theme_config(character_id: int):
	var config_path = "res://assets/characters/character_" + str(character_id + 1) + "/chessboard/board_theme_config.gd"

	# Check if config file exists
	if not ResourceLoader.exists(config_path):
		print("BoardThemeLoader: No theme config found at ", config_path)
		return null

	# Load and instantiate the config script
	var config_script = load(config_path)
	if config_script == null:
		print("BoardThemeLoader: Failed to load config script at ", config_path)
		return null

	var config_instance = config_script.new()
	print("BoardThemeLoader: Theme config loaded from ", config_path)
	return config_instance

## Load theme background image for a character
## Searches for board_theme.png or board_theme.jpg in the chessboard directory
static func load_theme_image(chessboard_path: String) -> Texture2D:
	var image_extensions = [".png", ".jpg", ".jpeg"]

	for ext in image_extensions:
		var image_path = chessboard_path + "board_theme" + ext

		if ResourceLoader.exists(image_path):
			var texture = load(image_path)
			if texture != null:
				print("BoardThemeLoader: Loaded theme image from ", image_path)
				return texture
			else:
				print("BoardThemeLoader: Failed to load image at ", image_path)

	print("BoardThemeLoader: No theme image found in ", chessboard_path)
	return null

## Check if a character has a custom theme (image or config)
static func has_custom_theme(character_id: int) -> bool:
	var char_path = "res://assets/characters/character_" + str(character_id + 1) + "/"
	var chessboard_path = char_path + "chessboard/"

	# Check for image
	var image_extensions = [".png", ".jpg", ".jpeg"]
	for ext in image_extensions:
		var image_path = chessboard_path + "board_theme" + ext
		if ResourceLoader.exists(image_path):
			return true

	# Check for config file
	var config_path = chessboard_path + "board_theme_config.gd"
	if ResourceLoader.exists(config_path):
		return true

	return false

## Get theme summary for debugging
static func get_theme_summary(character_id: int) -> String:
	var theme = load_theme(character_id)
	var summary = "Theme Summary for Character " + str(character_id) + ":\n"
	summary += "  Has Image: " + str(theme.has_image) + "\n"
	summary += "  Light Color: " + str(theme.light_color) + "\n"
	summary += "  Dark Color: " + str(theme.dark_color) + "\n"
	summary += "  Square Opacity: " + str(theme.square_opacity) + "\n"
	if theme.has_image:
		summary += "  Image Mode Square Opacity: " + str(theme.image_mode_square_opacity) + "\n"
	return summary
