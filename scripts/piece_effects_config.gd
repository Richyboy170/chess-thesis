extends Resource
class_name PieceEffectsConfig

# ============================================================================
# CHARACTER-SPECIFIC PIECE EFFECTS CONFIGURATION
# ============================================================================
# This resource defines piece effect settings for a single character.
# Each character can have their own unique effects and image swap settings.
#
# USAGE:
# 1. Create an instance of this config for each character
# 2. Customize the effect toggles and held piece image paths
# 3. Load the appropriate config based on the character being used
# ============================================================================

# Character identifier
@export var character_id: int = 1
@export var character_name: String = "Character 1"

# ============================================================================
# EFFECT TOGGLES
# ============================================================================
# Enable/disable specific effects for this character
@export_group("Effect Toggles")
@export var image_swap_enabled: bool = true          # Swap to alternate image when held
@export var scale_enabled: bool = true               # Scale piece up when held
@export var rotation_enabled: bool = false           # Gentle rotation animation
@export var glow_enabled: bool = true                # Add glowing outline
@export var pulse_enabled: bool = false              # Pulsing scale animation
@export var shimmer_enabled: bool = false            # Shimmering light effect
@export var particle_enabled: bool = false           # Particle effect around piece
@export var shadow_blur_enabled: bool = true         # Blurred shadow effect
@export var color_shift_enabled: bool = false        # Shift piece color when held
@export var sparkle_enabled: bool = false            # Occasional sparkle effects
@export var aura_enabled: bool = false               # Colored aura around piece
@export var trail_enabled: bool = false              # Motion trail effect

# ============================================================================
# EFFECT PARAMETERS
# ============================================================================
# Customize the appearance of each effect
@export_group("Effect Parameters")

# Glow effect color
@export var glow_color: Color = Color(1.0, 0.9, 0.3, 0.8)  # Golden glow

# Scale effect magnitude
@export var scale_factor: float = 1.3

# Rotation effect (degrees)
@export var max_rotation: float = 10.0
@export var rotation_duration: float = 3.0

# Pulse effect
@export var pulse_min_scale: float = 1.0
@export var pulse_max_scale: float = 1.15
@export var pulse_duration: float = 1.5

# Color shift tint
@export var color_shift_tint: Color = Color(1.2, 1.1, 0.9)  # Warm golden tint

# Aura effect color
@export var aura_color: Color = Color(1.0, 0.8, 0.0, 0.5)  # Golden aura

# ============================================================================
# HELD PIECE IMAGE PATHS
# ============================================================================
# Define alternate images to use when pieces are held
# These paths are relative to this character's assets folder
@export_group("Image Swap Paths")

# Base path for this character's held images
var held_images_base_path: String:
	get:
		return "res://assets/characters/character_%d/pieces/held/" % character_id

# Specific paths for each piece type
# These will be auto-generated based on the character_id
var held_piece_image_paths: Dictionary:
	get:
		return {
			"king": held_images_base_path + "white_king.png",
			"queen": held_images_base_path + "white_queen.png",
			"rook": held_images_base_path + "white_rook.png",
			"bishop": held_images_base_path + "white_bishop.png",
			"knight": held_images_base_path + "white_knight.png",
			"pawn": held_images_base_path + "white_pawn.png",
		}

# Optional: Override specific piece image paths
@export var custom_held_image_king: String = ""
@export var custom_held_image_queen: String = ""
@export var custom_held_image_rook: String = ""
@export var custom_held_image_bishop: String = ""
@export var custom_held_image_knight: String = ""
@export var custom_held_image_pawn: String = ""

# ============================================================================
# METHODS
# ============================================================================

func get_held_image_path(piece_type: String) -> String:
	"""
	Get the held image path for a specific piece type.
	Checks custom paths first, then falls back to default paths.
	"""
	var custom_path = ""
	match piece_type.to_lower():
		"king":
			custom_path = custom_held_image_king
		"queen":
			custom_path = custom_held_image_queen
		"rook":
			custom_path = custom_held_image_rook
		"bishop":
			custom_path = custom_held_image_bishop
		"knight":
			custom_path = custom_held_image_knight
		"pawn":
			custom_path = custom_held_image_pawn

	# Use custom path if specified, otherwise use default
	if custom_path != "":
		return custom_path
	else:
		return held_piece_image_paths.get(piece_type, "")

func get_config_dict() -> Dictionary:
	"""
	Returns a dictionary of all effect toggle settings.
	Compatible with the original piece_effects.gd config format.
	"""
	return {
		"image_swap_enabled": image_swap_enabled,
		"scale_enabled": scale_enabled,
		"rotation_enabled": rotation_enabled,
		"glow_enabled": glow_enabled,
		"pulse_enabled": pulse_enabled,
		"shimmer_enabled": shimmer_enabled,
		"particle_enabled": particle_enabled,
		"shadow_blur_enabled": shadow_blur_enabled,
		"color_shift_enabled": color_shift_enabled,
		"sparkle_enabled": sparkle_enabled,
		"aura_enabled": aura_enabled,
		"trail_enabled": trail_enabled,
	}

# ============================================================================
# PRESET CONFIGURATIONS
# ============================================================================

func apply_preset_minimal():
	"""Minimal effects - just scale and subtle glow."""
	scale_enabled = true
	glow_enabled = true
	rotation_enabled = false
	pulse_enabled = false
	shimmer_enabled = false
	particle_enabled = false
	shadow_blur_enabled = false
	color_shift_enabled = false
	sparkle_enabled = false
	aura_enabled = false
	trail_enabled = false

func apply_preset_moderate():
	"""Moderate effects - scale, glow, pulse, and shadow."""
	scale_enabled = true
	glow_enabled = true
	pulse_enabled = true
	shadow_blur_enabled = true
	rotation_enabled = false
	shimmer_enabled = false
	particle_enabled = false
	color_shift_enabled = false
	sparkle_enabled = false
	aura_enabled = false
	trail_enabled = false

func apply_preset_maximum():
	"""Maximum effects - ALL effects enabled (may be overwhelming!)."""
	image_swap_enabled = true
	scale_enabled = true
	rotation_enabled = true
	glow_enabled = true
	pulse_enabled = true
	shimmer_enabled = true
	particle_enabled = true
	shadow_blur_enabled = true
	color_shift_enabled = true
	sparkle_enabled = true
	aura_enabled = true
	trail_enabled = true

func apply_preset_elegant():
	"""Elegant effects - glow, shimmer, and subtle pulse."""
	glow_enabled = true
	shimmer_enabled = true
	pulse_enabled = true
	shadow_blur_enabled = true
	particle_enabled = false
	sparkle_enabled = false
	rotation_enabled = false
	scale_enabled = false
	color_shift_enabled = false
	aura_enabled = false
	trail_enabled = false

func apply_preset_magical():
	"""Magical effects - particles, sparkles, and aura."""
	particle_enabled = true
	sparkle_enabled = true
	aura_enabled = true
	glow_enabled = true
	shimmer_enabled = false
	pulse_enabled = false
	scale_enabled = false
	rotation_enabled = false
	shadow_blur_enabled = false
	color_shift_enabled = false
	trail_enabled = false
