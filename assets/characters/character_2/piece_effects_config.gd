extends PieceEffectsConfig

# ============================================================================
# CHARACTER 2 - PIECE EFFECTS CONFIGURATION
# ============================================================================
# This configuration defines the visual effects for Character 2's chess pieces.
# You can customize all effect settings and parameters here.
#
# To adjust effects:
# 1. Enable/disable effects by setting the boolean values (true/false)
# 2. Customize effect parameters (colors, intensities, durations)
# 3. Add custom held piece images in the "held/" folder
# ============================================================================

func _init():
	# Character identification
	character_id = 2
	character_name = "Character 2"

	# ========================================
	# EFFECT TOGGLES
	# ========================================
	# Enable/disable individual effects
	# Character 2 uses a more magical/mystical effect set
	image_swap_enabled = true          # Swap to alternate image when held
	scale_enabled = true               # Scale piece up when held
	rotation_enabled = true            # Gentle rotation animation - ENABLED for Character 2
	glow_enabled = true                # Add glowing outline
	pulse_enabled = true               # Pulsing scale animation - ENABLED for Character 2
	shimmer_enabled = false            # Shimmering light effect
	particle_enabled = false           # Particle effect around piece
	shadow_blur_enabled = true         # Blurred shadow effect
	color_shift_enabled = true         # Shift piece color when held - ENABLED for Character 2
	sparkle_enabled = false            # Occasional sparkle effects
	aura_enabled = false               # Colored aura around piece
	trail_enabled = false              # Motion trail effect

	# ========================================
	# EFFECT PARAMETERS
	# ========================================
	# Customize the appearance of each effect

	# Glow effect - Blue/cyan glow for Character 2
	glow_color = Color(0.3, 0.8, 1.0, 0.8)  # Cool blue glow

	# Scale effect
	scale_factor = 1.35  # 35% larger when held (slightly more than Character 1)

	# Rotation effect
	max_rotation = 15.0  # degrees (more rotation than Character 1)
	rotation_duration = 2.5  # seconds (faster rotation)

	# Pulse effect
	pulse_min_scale = 1.0
	pulse_max_scale = 1.2  # More pronounced pulse
	pulse_duration = 1.2  # seconds (faster pulse)

	# Color shift - Cool blue tint
	color_shift_tint = Color(0.9, 1.0, 1.3)  # Cool blue tint

	# Aura effect - Blue/cyan aura
	aura_color = Color(0.0, 0.5, 1.0, 0.5)

	# ========================================
	# HELD PIECE IMAGE PATHS
	# ========================================
	# Custom held piece images (optional)
	# Leave empty to use default paths
	# Default path: res://assets/characters/character_2/pieces/held/white_[piece].png
	#
	# To use custom images, uncomment and set paths:
	# custom_held_image_king = "res://custom/path/to/held_king.png"
	# custom_held_image_queen = "res://custom/path/to/held_queen.png"
	# custom_held_image_rook = "res://custom/path/to/held_rook.png"
	# custom_held_image_bishop = "res://custom/path/to/held_bishop.png"
	# custom_held_image_knight = "res://custom/path/to/held_knight.png"
	# custom_held_image_pawn = "res://custom/path/to/held_pawn.png"

# ============================================================================
# QUICK PRESET METHODS
# ============================================================================
# Uncomment one of these in _init() to quickly apply a preset configuration

# Minimal effects preset
#func _ready():
#	apply_preset_minimal()

# Moderate effects preset
#func _ready():
#	apply_preset_moderate()

# Maximum effects preset (all effects enabled)
#func _ready():
#	apply_preset_maximum()

# Elegant effects preset
#func _ready():
#	apply_preset_elegant()

# Magical effects preset
#func _ready():
#	apply_preset_magical()
