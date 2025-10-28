extends PieceEffectsConfig

# ============================================================================
# CHARACTER 4 - PIECE EFFECTS CONFIGURATION (LIVE2D)
# ============================================================================
# This configuration defines the visual effects for Character 4's chess pieces.
# Character 4 features the Scyka Live2D model with a mystical/magical theme.
#
# To adjust effects:
# 1. Enable/disable effects by setting the boolean values (true/false)
# 2. Customize effect parameters (colors, intensities, durations)
# 3. Add custom held piece images in the "held/" folder
# ============================================================================

func _init():
	# Character identification
	character_id = 4
	character_name = "Character 4 (Scyka)"

	# ========================================
	# EFFECT TOGGLES
	# ========================================
	# Enable/disable individual effects
	image_swap_enabled = true          # Swap to alternate image when held
	scale_enabled = true               # Scale piece up when held
	rotation_enabled = true            # Gentle rotation animation
	glow_enabled = true                # Add glowing outline
	pulse_enabled = true               # Pulsing scale animation
	shimmer_enabled = true             # Shimmering light effect
	particle_enabled = true            # Particle effect around piece
	shadow_blur_enabled = true         # Blurred shadow effect
	color_shift_enabled = true         # Shift piece color when held
	sparkle_enabled = true             # Occasional sparkle effects
	aura_enabled = true                # Colored aura around piece
	trail_enabled = false              # Motion trail effect (disabled for performance)

	# ========================================
	# EFFECT PARAMETERS
	# ========================================
	# Customize the appearance of each effect

	# Glow effect - Purple/violet mystical glow
	glow_color = Color(0.8, 0.4, 1.0, 0.9)  # Vibrant purple

	# Scale effect
	scale_factor = 1.35  # 35% larger when held (slightly more dramatic)

	# Rotation effect
	max_rotation = 15.0  # degrees (more noticeable rotation)
	rotation_duration = 2.5  # seconds (slightly faster)

	# Pulse effect
	pulse_min_scale = 1.0
	pulse_max_scale = 1.2  # More dramatic pulsing
	pulse_duration = 1.2  # seconds (faster pulse)

	# Color shift - Cool purple/blue mystical tint
	color_shift_tint = Color(1.1, 0.95, 1.3)  # Purple-ish tint

	# Aura effect - Mystical purple aura
	aura_color = Color(0.7, 0.3, 1.0, 0.6)  # Deep purple aura

	# ========================================
	# HELD PIECE IMAGE PATHS
	# ========================================
	# Custom held piece images (optional)
	# Leave empty to use default paths
	# Default path: res://assets/characters/character_4/pieces/held/white_[piece].png
	#
	# To use custom images, uncomment and set paths:
	# custom_held_image_king = "res://custom/path/to/held_king.png"
	# custom_held_image_queen = "res://custom/path/to/held_queen.png"
	# custom_held_image_rook = "res://custom/path/to/held_rook.png"
	# custom_held_image_bishop = "res://custom/path/to/held_bishop.png"
	# custom_held_image_knight = "res://custom/path/to/held_knight.png"
	# custom_held_image_pawn = "res://custom/path/to/held_pawn.png"

# ============================================================================
# NOTES
# ============================================================================
# Character 4 (Scyka) uses a more dramatic and magical effect set compared to
# other characters. This reflects the dynamic nature of the Live2D animation
# and creates a unique visual identity for this character.
#
# The purple/mystical theme complements the Live2D character's aesthetic.
# ============================================================================
