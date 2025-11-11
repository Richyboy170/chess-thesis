extends Node
class_name Character4BoardThemeConfig

## Character 4 (Scyka) Board Theme Configuration
## This file allows programmers to customize the chessboard colors for Character 4
## without using an image. Edit the color values below to change the board appearance.

# ============================================================================
# CONFIGURATION - EDIT THESE VALUES
# ============================================================================

## Light square color (RGBA format)
## Format: Color(red, green, blue, alpha) where values are 0.0 to 1.0
## Default: Light purple/lavender with slight transparency
var light_color: Color = Color(0.75, 0.65, 0.85, 0.7)

## Dark square color (RGBA format)
## Format: Color(red, green, blue, alpha) where values are 0.0 to 1.0
## Default: Dark purple with slight transparency
var dark_color: Color = Color(0.45, 0.35, 0.55, 0.7)

## Enable image theming (if false, always use colors even if image exists)
## Set to false to force color mode and ignore any background images
var use_image_if_available: bool = true

## Board overlay opacity when using image mode (0.0 = fully transparent, 1.0 = fully opaque)
## This controls how much of the background image shows through
## 0.0 = Image fully visible (recommended)
## 0.3 = Image mostly visible with slight checkerboard overlay
## 0.5 = Equal blend of image and checkerboard
var image_mode_square_opacity: float = 0.0

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

func get_light_color() -> Color:
	"""Returns the light square color."""
	return light_color

func get_dark_color() -> Color:
	"""Returns the dark square color."""
	return dark_color

func get_board_colors() -> Dictionary:
	"""
	Returns both board colors as a dictionary.

	Returns:
		Dictionary with "light" and "dark" Color keys
	"""
	return {
		"light": light_color,
		"dark": dark_color
	}

func should_use_image() -> bool:
	"""Returns whether to use image theming if an image is available."""
	return use_image_if_available

func get_square_opacity_for_image_mode() -> float:
	"""Returns the opacity value for board squares when in image mode."""
	return image_mode_square_opacity

# ============================================================================
# COLOR PRESETS (OPTIONAL)
# ============================================================================
# Uncomment and call these functions to quickly apply preset color schemes

func apply_mystic_purple_theme():
	"""Mystical purple theme (default for Character 4)"""
	light_color = Color(0.75, 0.65, 0.85, 0.7)
	dark_color = Color(0.45, 0.35, 0.55, 0.7)

func apply_ghost_blue_theme():
	"""Ghostly blue theme"""
	light_color = Color(0.7, 0.8, 0.95, 0.7)
	dark_color = Color(0.3, 0.4, 0.65, 0.7)

func apply_spectral_green_theme():
	"""Spectral green theme"""
	light_color = Color(0.7, 0.9, 0.75, 0.7)
	dark_color = Color(0.3, 0.5, 0.35, 0.7)

func apply_ethereal_pink_theme():
	"""Ethereal pink theme"""
	light_color = Color(0.95, 0.75, 0.85, 0.7)
	dark_color = Color(0.7, 0.4, 0.6, 0.7)

func apply_dark_mystic_theme():
	"""Dark mystical theme with high contrast"""
	light_color = Color(0.6, 0.5, 0.7, 0.8)
	dark_color = Color(0.2, 0.15, 0.3, 0.8)

# ============================================================================
# USAGE EXAMPLE
# ============================================================================
# To apply a preset theme, uncomment one of these lines in _ready():
#
# func _ready():
#     apply_ghost_blue_theme()
#     # or
#     apply_dark_mystic_theme()
#     # etc.
