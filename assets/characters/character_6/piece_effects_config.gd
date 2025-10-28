extends PieceEffectsConfig

# ============================================================================
# CHARACTER 6 - PIECE EFFECTS CONFIGURATION (MARK - LIVE2D)
# ============================================================================
# This configuration defines the visual effects for Character 6's chess pieces.
# Character 6 features the Mark Live2D model with a cool, professional theme.
#
# To adjust effects:
# 1. Enable/disable effects by setting the boolean values (true/false)
# 2. Customize effect parameters (colors, intensities, durations)
# 3. Add custom held piece images in the "held/" folder
# ============================================================================

func _init():
	# Character identification
	character_id = 6
	character_name = "Character 6 (Mark)"

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

	# Glow effect - Cool cyan/blue professional glow
	glow_color = Color(0.4, 0.8, 1.0, 0.85)  # Bright cyan

	# Scale effect
	scale_factor = 1.32  # 32% larger when held

	# Rotation effect
	max_rotation = 10.0  # degrees (subtle rotation)
	rotation_duration = 2.5  # seconds (steady)

	# Pulse effect
	pulse_min_scale = 1.0
	pulse_max_scale = 1.18  # Moderate pulsing
	pulse_duration = 1.3  # seconds (crisp pulse)

	# Color shift - Cool blue tint
	color_shift_tint = Color(0.95, 1.05, 1.2)  # Cool blue tint

	# Aura effect - Cyan aura
	aura_color = Color(0.3, 0.7, 1.0, 0.55)  # Bright cyan aura

	# ========================================
	# HELD PIECE IMAGE PATHS
	# ========================================
	# Custom held piece images (optional)
	# Leave empty to use default paths
	# Default path: res://assets/characters/character_6/pieces/held/white_[piece].png

# ============================================================================
# NOTES
# ============================================================================
# Character 6 (Mark) uses a cool, professional theme with cyan/blue colors
# that complement the character's composed appearance.
# ============================================================================
