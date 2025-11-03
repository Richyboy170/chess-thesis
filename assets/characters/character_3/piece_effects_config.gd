extends PieceEffectsConfig

# ============================================================================
# CHARACTER 3 - PIECE EFFECTS CONFIGURATION
# ============================================================================
# This configuration defines the visual effects for Character 3's chess pieces.
# You can customize all effect settings and parameters here.
#
# To adjust effects:
# 1. Enable/disable effects by setting the boolean values (true/false)
# 2. Customize effect parameters (colors, intensities, durations)
# 3. Add custom held piece images in the "held/" folder
# ============================================================================

func _init():
	# Character identification
	character_id = 3
	character_name = "Character 3"

	# ========================================
	# EFFECT TOGGLES
	# ========================================
	# Enable/disable individual effects
	# Character 3 uses a magical/fantasy effect set with particles and sparkles
	image_swap_enabled = true          # Swap to alternate image when held
	scale_enabled = true               # Scale piece up when held
	rotation_enabled = false           # Gentle rotation animation
	glow_enabled = true                # Add glowing outline
	pulse_enabled = false              # Pulsing scale animation
	shimmer_enabled = true             # Shimmering light effect - ENABLED for Character 3
	particle_enabled = true            # Particle effect around piece - ENABLED for Character 3
	shadow_blur_enabled = true         # Blurred shadow effect
	color_shift_enabled = false        # Shift piece color when held
	sparkle_enabled = true             # Occasional sparkle effects - ENABLED for Character 3
	aura_enabled = true                # Colored aura around piece - ENABLED for Character 3
	trail_enabled = false              # Motion trail effect

	# ========================================
	# EFFECT PARAMETERS
	# ========================================
	# Customize the appearance of each effect

	# Glow effect - Pink/purple/magenta glow for Character 3
	glow_color = Color(1.0, 0.3, 0.8, 0.8)  # Pink/magenta glow

	# Scale effect
	scale_factor = 1.4  # 40% larger when held (most dramatic)

	# Rotation effect
	max_rotation = 8.0  # degrees
	rotation_duration = 3.5  # seconds

	# Pulse effect
	pulse_min_scale = 1.0
	pulse_max_scale = 1.18
	pulse_duration = 1.8  # seconds

	# Color shift - Pink/purple tint
	color_shift_tint = Color(1.3, 0.9, 1.1)  # Pink/purple tint

	# Aura effect - Pink/purple aura
	aura_color = Color(1.0, 0.0, 0.5, 0.5)  # Pink aura

	# ========================================
	# HELD PIECE IMAGE PATHS
	# ========================================
	# Custom held piece images (optional)
	# Leave empty to use default paths
	# Default path: res://assets/characters/character_3/pieces/held/white_[piece].png
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
