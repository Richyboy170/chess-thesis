extends PieceEffectsConfig

# ============================================================================
# CHARACTER 5 - PIECE EFFECTS CONFIGURATION (HIYORI - LIVE2D)
# ============================================================================
# This configuration defines the visual effects for Character 5's chess pieces.
# Character 5 features the Hiyori Live2D model with a light, elegant theme.
#
# To adjust effects:
# 1. Enable/disable effects by setting the boolean values (true/false)
# 2. Customize effect parameters (colors, intensities, durations)
# 3. Add custom held piece images in the "held/" folder
# ============================================================================

func _init():
	# Character identification
	character_id = 5
	character_name = "Character 5 (Hiyori)"

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

	# Glow effect - Soft pink/light elegant glow
	glow_color = Color(1.0, 0.7, 0.9, 0.8)  # Soft pink

	# Scale effect
	scale_factor = 1.3  # 30% larger when held

	# Rotation effect
	max_rotation = 12.0  # degrees (gentle rotation)
	rotation_duration = 2.8  # seconds (smooth and elegant)

	# Pulse effect
	pulse_min_scale = 1.0
	pulse_max_scale = 1.15  # Gentle pulsing
	pulse_duration = 1.5  # seconds (calm pulse)

	# Color shift - Warm light tint
	color_shift_tint = Color(1.15, 1.05, 1.1)  # Light warm tint

	# Aura effect - Soft pink aura
	aura_color = Color(1.0, 0.6, 0.85, 0.5)  # Soft pink aura

	# ========================================
	# HELD PIECE IMAGE PATHS
	# ========================================
	# Custom held piece images (optional)
	# Leave empty to use default paths
	# Default path: res://assets/characters/character_5/pieces/held/white_[piece].png

# ============================================================================
# NOTES
# ============================================================================
# Character 5 (Hiyori) uses an elegant, light theme with soft pink colors
# that complement the character's graceful appearance.
# ============================================================================
