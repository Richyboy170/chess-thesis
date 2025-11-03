extends PieceEffectsConfig

# ============================================================================
# CHARACTER 1 - PIECE EFFECTS CONFIGURATION
# ============================================================================
# This configuration defines the visual effects for Character 1's chess pieces.
# You can customize all effect settings and parameters here.
#
# To adjust effects:
# 1. Enable/disable effects by setting the boolean values (true/false)
# 2. Customize effect parameters (colors, intensities, durations)
# 3. Add custom held piece images in the "held/" folder
# ============================================================================

func _init():
	# Character identification
	character_id = 1
	character_name = "Character 1"

	# ========================================
	# EFFECT TOGGLES
	# ========================================
	# Enable/disable individual effects
	image_swap_enabled = true          # Swap to alternate image when held
	scale_enabled = true               # Scale piece up when held
	rotation_enabled = false           # Gentle rotation animation
	glow_enabled = true                # Add glowing outline
	pulse_enabled = false              # Pulsing scale animation
	shimmer_enabled = false            # Shimmering light effect
	particle_enabled = false           # Particle effect around piece
	shadow_blur_enabled = true         # Blurred shadow effect
	color_shift_enabled = false        # Shift piece color when held
	sparkle_enabled = false            # Occasional sparkle effects
	aura_enabled = false               # Colored aura around piece
	trail_enabled = false              # Motion trail effect

	# ========================================
	# EFFECT PARAMETERS
	# ========================================
	# Customize the appearance of each effect

	# Glow effect - Golden/yellow glow for Character 1
	glow_color = Color(1.0, 0.9, 0.3, 0.8)

	# Scale effect
	scale_factor = 1.3  # 30% larger when held

	# Rotation effect
	max_rotation = 10.0  # degrees
	rotation_duration = 3.0  # seconds

	# Pulse effect
	pulse_min_scale = 1.0
	pulse_max_scale = 1.15
	pulse_duration = 1.5  # seconds

	# Color shift - Warm golden tint
	color_shift_tint = Color(1.2, 1.1, 0.9)

	# Aura effect - Golden aura
	aura_color = Color(1.0, 0.8, 0.0, 0.5)

	# ========================================
	# HELD PIECE IMAGE PATHS
	# ========================================
	# Custom held piece images (optional)
	# Leave empty to use default paths
	# Default path: res://assets/characters/character_1/pieces/held/white_[piece].png
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
