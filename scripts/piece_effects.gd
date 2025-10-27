extends Node

# ============================================================================
# CHESS PIECE DRAG EFFECTS SYSTEM
# ============================================================================
# This script provides configurable visual effects for chess pieces when
# they are being held/dragged by the player. Each effect can be enabled
# or disabled by uncommenting/commenting the corresponding line in the
# apply_drag_effects() function.
#
# USAGE:
# 1. Add this script as an autoload singleton in Project Settings
# 2. Call PieceEffects.apply_drag_effects(piece_node, piece_data) when drag starts
# 3. Call PieceEffects.remove_drag_effects(piece_node) when drag ends
# 4. Optionally swap piece images by setting up held_piece_images dictionary
#
# CUSTOMIZATION:
# - Enable/disable effects in apply_drag_effects() by uncommenting/commenting
# - Adjust effect parameters (colors, speeds, intensities) in each function
# - Add custom piece images for held state in assets/characters/.../pieces/held/
# ============================================================================

# ============================================================================
# CONFIGURATION - EFFECT TOGGLES
# ============================================================================
# Enable/disable specific effects by setting these to true/false
# You can also control effects per piece type or color

var config = {
	"image_swap_enabled": true,          # Swap to alternate image when held
	"scale_enabled": true,               # Scale piece up when held
	"rotation_enabled": false,           # Gentle rotation animation
	"glow_enabled": true,                # Add glowing outline
	"pulse_enabled": false,              # Pulsing scale animation
	"shimmer_enabled": false,            # Shimmering light effect
	"particle_enabled": false,           # Particle effect around piece
	"shadow_blur_enabled": true,         # Blurred shadow effect
	"color_shift_enabled": false,        # Shift piece color when held
	"sparkle_enabled": false,            # Occasional sparkle effects
	"aura_enabled": false,               # Colored aura around piece
	"trail_enabled": false,              # Motion trail effect
}

# ============================================================================
# HELD PIECE IMAGE PATHS
# ============================================================================
# Define alternate images to use when pieces are held
# Format: "piece_type": "path/to/held_image.png"
# If not specified, uses the default piece image
#
# RECOMMENDED STRUCTURE:
# res://assets/characters/character_X/pieces/held/white_PIECE.png
# res://assets/characters/character_X/pieces/held/white_PIECE.ogv (animated)
#
# Examples:
# - Static images: PNG, JPEG
# - Animated: OGV (video), Animated textures
var held_piece_image_paths = {
	# Uncomment and modify these to use custom held images
	# "king": "res://assets/characters/character_1/pieces/held/white_king.png",
	# "queen": "res://assets/characters/character_1/pieces/held/white_queen.png",
	# "rook": "res://assets/characters/character_1/pieces/held/white_rook.png",
	# "bishop": "res://assets/characters/character_1/pieces/held/white_bishop.png",
	# "knight": "res://assets/characters/character_1/pieces/held/white_knight.png",
	# "pawn": "res://assets/characters/character_1/pieces/held/white_pawn.png",
}

# Store original textures to restore later
var original_textures = {}
var active_effects = {}  # Track active tweens and effects per piece

# ============================================================================
# MAIN EFFECT FUNCTIONS
# ============================================================================

func apply_drag_effects(piece_node: Node, piece_data: Dictionary = {}):
	"""
	Applies all enabled visual effects when a piece starts being dragged.

	Args:
		piece_node: The visual node (TextureRect or Label) representing the piece
		piece_data: Optional dictionary with piece info (type, color, character_id)
	"""
	if not piece_node:
		return

	# Initialize effect tracking for this piece
	active_effects[piece_node] = {}

	# ========================================
	# EFFECT ACTIVATION SECTION
	# ========================================
	# Uncomment the effects you want to use!
	# You can enable/disable each effect independently

	# 1. IMAGE SWAP - Change piece appearance when held
	if config.image_swap_enabled:
		apply_image_swap(piece_node, piece_data)

	# 2. SCALE EFFECT - Make piece larger (already in main_game.gd, but can enhance)
	if config.scale_enabled:
		apply_enhanced_scale(piece_node)

	# 3. GLOW EFFECT - Add glowing outline
	if config.glow_enabled:
		apply_glow_effect(piece_node, Color(1.0, 0.9, 0.3, 0.8))  # Golden glow
		#apply_glow_effect(piece_node, Color(0.3, 0.8, 1.0, 0.8))  # Blue glow
		#apply_glow_effect(piece_node, Color(1.0, 0.3, 0.3, 0.8))  # Red glow
		#apply_glow_effect(piece_node, Color(0.5, 1.0, 0.3, 0.8))  # Green glow

	# 4. PULSE EFFECT - Gentle pulsing animation
	if config.pulse_enabled:
		apply_pulse_effect(piece_node, 1.0, 1.15, 1.5)  # min_scale, max_scale, duration

	# 5. ROTATION EFFECT - Gentle rotation
	if config.rotation_enabled:
		apply_rotation_effect(piece_node, 10.0, 3.0)  # max_rotation_degrees, duration

	# 6. SHIMMER EFFECT - Shimmering light overlay
	if config.shimmer_enabled:
		apply_shimmer_effect(piece_node)

	# 7. PARTICLE EFFECT - Sparkles and particles
	if config.particle_enabled:
		apply_particle_effect(piece_node)

	# 8. SHADOW BLUR - Enhanced shadow with blur
	if config.shadow_blur_enabled:
		apply_shadow_blur(piece_node)

	# 9. COLOR SHIFT - Change piece tint when held
	if config.color_shift_enabled:
		apply_color_shift(piece_node, Color(1.2, 1.1, 0.9))  # Warm golden tint
		#apply_color_shift(piece_node, Color(0.9, 1.0, 1.3))  # Cool blue tint
		#apply_color_shift(piece_node, Color(1.3, 0.9, 1.1))  # Pink/purple tint

	# 10. SPARKLE EFFECT - Occasional sparkles
	if config.sparkle_enabled:
		apply_sparkle_effect(piece_node)

	# 11. AURA EFFECT - Colored aura around piece
	if config.aura_enabled:
		apply_aura_effect(piece_node, Color(1.0, 0.8, 0.0, 0.5))  # Golden aura
		#apply_aura_effect(piece_node, Color(0.0, 0.5, 1.0, 0.5))  # Blue aura
		#apply_aura_effect(piece_node, Color(1.0, 0.0, 0.5, 0.5))  # Pink aura

	# 12. TRAIL EFFECT - Motion trail (for drag movement)
	if config.trail_enabled:
		apply_trail_effect(piece_node)

func remove_drag_effects(piece_node: Node):
	"""
	Removes all active effects from a piece when drag ends.
	Restores original appearance and cleans up effect nodes.

	Args:
		piece_node: The piece node to clean up
	"""
	if not piece_node:
		return

	# Restore original texture if it was swapped
	restore_original_texture(piece_node)

	# Remove all active effect nodes
	if piece_node in active_effects:
		for effect_name in active_effects[piece_node]:
			var effect = active_effects[piece_node][effect_name]
			if effect is Node:
				effect.queue_free()
			elif effect is Tween:
				effect.kill()

		active_effects.erase(piece_node)

	# Clean up any child effect nodes (glow, aura, particles, etc.)
	for child in piece_node.get_children():
		if child.has_meta("piece_effect"):
			child.queue_free()

	# Reset modulation and rotation
	piece_node.modulate = Color(1, 1, 1, piece_node.modulate.a)  # Keep alpha
	piece_node.rotation = 0

# ============================================================================
# INDIVIDUAL EFFECT IMPLEMENTATIONS
# ============================================================================

# ----------------------------------------------------------------------------
# 1. IMAGE SWAP EFFECT
# ----------------------------------------------------------------------------
func apply_image_swap(piece_node: Node, piece_data: Dictionary):
	"""
	Swaps the piece image to an alternate 'held' version.
	Supports PNG, JPEG, and OGV (video) files.

	Args:
		piece_node: The TextureRect displaying the piece
		piece_data: Dictionary with 'type' (e.g., 'king'), 'color', 'character_id'
	"""
	if not piece_node is TextureRect:
		return  # Only works with TextureRect (image-based pieces)

	# Get piece type
	var piece_type = piece_data.get("type", "").to_lower()
	if piece_type == "":
		return

	# Check if we have a custom held image for this piece type
	if piece_type in held_piece_image_paths:
		var held_image_path = held_piece_image_paths[piece_type]

		# Try to load the held image
		if FileAccess.file_exists(held_image_path):
			var held_texture = load(held_image_path)
			if held_texture:
				# Store original texture for restoration
				original_textures[piece_node] = piece_node.texture

				# Apply held texture
				piece_node.texture = held_texture
				print("Swapped to held image: ", held_image_path)
				return

	# Fallback: Try loading from default held folder
	var character_id = piece_data.get("character_id", 1)
	var default_held_path = "res://assets/characters/character_%d/pieces/held/white_%s.png" % [character_id, piece_type]

	if FileAccess.file_exists(default_held_path):
		var held_texture = load(default_held_path)
		if held_texture:
			original_textures[piece_node] = piece_node.texture
			piece_node.texture = held_texture
			print("Swapped to default held image: ", default_held_path)

func restore_original_texture(piece_node: Node):
	"""Restores the original piece texture after drag ends."""
	if piece_node in original_textures:
		if piece_node is TextureRect:
			piece_node.texture = original_textures[piece_node]
		original_textures.erase(piece_node)

# ----------------------------------------------------------------------------
# 2. ENHANCED SCALE EFFECT
# ----------------------------------------------------------------------------
func apply_enhanced_scale(piece_node: Node, scale_factor: float = 1.3):
	"""
	Scales up the piece with a smooth animation.
	Note: Basic scaling is already in main_game.gd, this provides more options.
	"""
	var tween = piece_node.create_tween()
	tween.tween_property(piece_node, "scale", piece_node.scale * scale_factor, 0.15)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	active_effects[piece_node]["scale_tween"] = tween

# ----------------------------------------------------------------------------
# 3. GLOW EFFECT
# ----------------------------------------------------------------------------
func apply_glow_effect(piece_node: Node, glow_color: Color = Color(1, 0.9, 0.3, 0.8)):
	"""
	Adds a glowing outline/aura behind the piece.
	Uses a ColorRect with blur-like layering.
	"""
	# Create glow background
	var glow = ColorRect.new()
	glow.color = glow_color
	glow.set_meta("piece_effect", true)

	# Position behind the piece
	glow.z_index = piece_node.z_index - 1
	glow.size = piece_node.size * 1.3
	glow.position = -piece_node.size * 0.15  # Center offset

	# Add to piece node
	piece_node.add_child(glow)
	active_effects[piece_node]["glow"] = glow

	# Animate glow intensity
	var tween = piece_node.create_tween()
	tween.set_loops()
	tween.tween_property(glow, "modulate:a", 0.4, 1.0)
	tween.tween_property(glow, "modulate:a", 0.8, 1.0)
	active_effects[piece_node]["glow_tween"] = tween

# ----------------------------------------------------------------------------
# 4. PULSE EFFECT
# ----------------------------------------------------------------------------
func apply_pulse_effect(piece_node: Node, min_scale: float = 1.0, max_scale: float = 1.15, duration: float = 1.5):
	"""
	Creates a gentle pulsing animation by varying the scale.
	"""
	var base_scale = piece_node.scale
	var tween = piece_node.create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(piece_node, "scale", base_scale * max_scale, duration / 2)
	tween.tween_property(piece_node, "scale", base_scale * min_scale, duration / 2)
	active_effects[piece_node]["pulse_tween"] = tween

# ----------------------------------------------------------------------------
# 5. ROTATION EFFECT
# ----------------------------------------------------------------------------
func apply_rotation_effect(piece_node: Node, max_rotation: float = 10.0, duration: float = 3.0):
	"""
	Adds a gentle swaying rotation animation.
	max_rotation is in degrees.
	"""
	var tween = piece_node.create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(piece_node, "rotation_degrees", max_rotation, duration / 2)
	tween.tween_property(piece_node, "rotation_degrees", -max_rotation, duration / 2)
	active_effects[piece_node]["rotation_tween"] = tween

# ----------------------------------------------------------------------------
# 6. SHIMMER EFFECT
# ----------------------------------------------------------------------------
func apply_shimmer_effect(piece_node: Node):
	"""
	Creates a shimmering light effect that sweeps across the piece.
	Uses a gradient overlay that animates.
	"""
	var shimmer = ColorRect.new()
	shimmer.set_meta("piece_effect", true)
	shimmer.color = Color(1, 1, 1, 0.3)
	shimmer.size = Vector2(piece_node.size.x * 0.3, piece_node.size.y)
	shimmer.position = Vector2(-piece_node.size.x * 0.3, 0)

	piece_node.add_child(shimmer)
	active_effects[piece_node]["shimmer"] = shimmer

	# Animate shimmer sweeping across
	var tween = piece_node.create_tween()
	tween.set_loops()
	tween.tween_property(shimmer, "position:x", piece_node.size.x * 1.3, 2.0)
	tween.tween_interval(1.0)
	tween.tween_property(shimmer, "position:x", -piece_node.size.x * 0.3, 0.0)
	active_effects[piece_node]["shimmer_tween"] = tween

# ----------------------------------------------------------------------------
# 7. PARTICLE EFFECT
# ----------------------------------------------------------------------------
func apply_particle_effect(piece_node: Node):
	"""
	Adds a particle effect around the piece (sparkles, magic dust, etc.).
	Note: Requires CPUParticles2D or GPUParticles2D node.
	"""
	var particles = CPUParticles2D.new()
	particles.set_meta("piece_effect", true)
	particles.emitting = true
	particles.amount = 20
	particles.lifetime = 1.5
	particles.position = piece_node.size / 2  # Center of piece

	# Particle appearance
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.gravity = Vector2(0, -20)
	particles.initial_velocity_min = 20
	particles.initial_velocity_max = 50
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 5.0

	# Color
	particles.color = Color(1.0, 0.9, 0.3, 0.8)

	piece_node.add_child(particles)
	active_effects[piece_node]["particles"] = particles

# ----------------------------------------------------------------------------
# 8. SHADOW BLUR EFFECT
# ----------------------------------------------------------------------------
func apply_shadow_blur(piece_node: Node):
	"""
	Adds a blurred shadow effect beneath the piece.
	Creates multiple shadow layers for a blur-like effect.
	"""
	for i in range(3):
		var shadow = ColorRect.new()
		shadow.set_meta("piece_effect", true)
		shadow.color = Color(0, 0, 0, 0.1 - i * 0.03)
		shadow.z_index = piece_node.z_index - 10 - i
		shadow.size = piece_node.size * (1.1 + i * 0.05)

		var offset = 10 + i * 3
		shadow.position = Vector2(offset, offset) - (shadow.size - piece_node.size) / 2

		piece_node.add_child(shadow)
		if not active_effects[piece_node].has("shadows"):
			active_effects[piece_node]["shadows"] = []
		active_effects[piece_node]["shadows"].append(shadow)

# ----------------------------------------------------------------------------
# 9. COLOR SHIFT EFFECT
# ----------------------------------------------------------------------------
func apply_color_shift(piece_node: Node, target_color: Color = Color(1.2, 1.1, 0.9)):
	"""
	Shifts the piece's color/tint when held.
	Values > 1.0 brighten, < 1.0 darken.
	"""
	var tween = piece_node.create_tween()
	tween.tween_property(piece_node, "modulate", target_color, 0.2)
	active_effects[piece_node]["color_tween"] = tween

# ----------------------------------------------------------------------------
# 10. SPARKLE EFFECT
# ----------------------------------------------------------------------------
func apply_sparkle_effect(piece_node: Node):
	"""
	Creates occasional sparkle flashes on the piece.
	"""
	# Create sparkle node
	var sparkle = ColorRect.new()
	sparkle.set_meta("piece_effect", true)
	sparkle.color = Color(1, 1, 1, 0)
	sparkle.size = Vector2(20, 20)
	sparkle.position = piece_node.size / 2 - sparkle.size / 2

	piece_node.add_child(sparkle)
	active_effects[piece_node]["sparkle"] = sparkle

	# Animate sparkles appearing randomly
	var tween = piece_node.create_tween()
	tween.set_loops()
	tween.tween_interval(randf_range(0.5, 1.5))
	tween.tween_property(sparkle, "modulate:a", 1.0, 0.1)
	tween.tween_property(sparkle, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		# Randomize position for next sparkle
		sparkle.position = Vector2(
			randf_range(0, piece_node.size.x - sparkle.size.x),
			randf_range(0, piece_node.size.y - sparkle.size.y)
		)
	)
	active_effects[piece_node]["sparkle_tween"] = tween

# ----------------------------------------------------------------------------
# 11. AURA EFFECT
# ----------------------------------------------------------------------------
func apply_aura_effect(piece_node: Node, aura_color: Color = Color(1.0, 0.8, 0.0, 0.5)):
	"""
	Creates a colored aura/energy field around the piece.
	Similar to glow but larger and more diffuse.
	"""
	var aura = ColorRect.new()
	aura.set_meta("piece_effect", true)
	aura.color = aura_color
	aura.z_index = piece_node.z_index - 2
	aura.size = piece_node.size * 1.6
	aura.position = -piece_node.size * 0.3

	piece_node.add_child(aura)
	active_effects[piece_node]["aura"] = aura

	# Pulsing aura animation
	var tween = piece_node.create_tween()
	tween.set_loops()
	tween.set_parallel(true)
	tween.tween_property(aura, "scale", Vector2(1.1, 1.1), 1.0)
	tween.tween_property(aura, "modulate:a", 0.3, 1.0)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_property(aura, "scale", Vector2(1.0, 1.0), 1.0)
	tween.tween_property(aura, "modulate:a", 0.6, 1.0)
	active_effects[piece_node]["aura_tween"] = tween

# ----------------------------------------------------------------------------
# 12. TRAIL EFFECT
# ----------------------------------------------------------------------------
func apply_trail_effect(piece_node: Node):
	"""
	Creates a motion trail effect.
	Note: This requires updating in _process() to create trail copies.
	For now, stores a flag that can be checked in main_game.gd
	"""
	piece_node.set_meta("has_trail_effect", true)
	active_effects[piece_node]["trail_enabled"] = true
	# Actual trail rendering would be done in main_game.gd's _input() during drag

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

func get_piece_data_from_node(piece_node: Node) -> Dictionary:
	"""
	Extracts piece information from metadata or parent nodes.
	Helper function to get piece type, color, etc.
	"""
	var data = {}

	# Try to get from metadata
	if piece_node.has_meta("piece_type"):
		data["type"] = piece_node.get_meta("piece_type")
	if piece_node.has_meta("piece_color"):
		data["color"] = piece_node.get_meta("piece_color")
	if piece_node.has_meta("character_id"):
		data["character_id"] = piece_node.get_meta("character_id")

	return data

func set_config(key: String, value: bool):
	"""
	Dynamically enable/disable effects at runtime.

	Example:
		PieceEffects.set_config("glow_enabled", true)
	"""
	if key in config:
		config[key] = value

func get_config(key: String) -> bool:
	"""Get current configuration value for an effect."""
	return config.get(key, false)

# ============================================================================
# PRESET CONFIGURATIONS
# ============================================================================

func apply_preset_minimal():
	"""Minimal effects - just scale and subtle glow."""
	config.scale_enabled = true
	config.glow_enabled = true
	# Disable all others
	for key in config:
		if key not in ["scale_enabled", "glow_enabled"]:
			config[key] = false

func apply_preset_moderate():
	"""Moderate effects - scale, glow, pulse, and shadow."""
	config.scale_enabled = true
	config.glow_enabled = true
	config.pulse_enabled = true
	config.shadow_blur_enabled = true
	# Disable others
	config.rotation_enabled = false
	config.shimmer_enabled = false
	config.particle_enabled = false
	config.sparkle_enabled = false
	config.aura_enabled = false
	config.trail_enabled = false

func apply_preset_maximum():
	"""Maximum effects - ALL effects enabled (may be overwhelming!)."""
	for key in config:
		config[key] = true

func apply_preset_elegant():
	"""Elegant effects - glow, shimmer, and subtle pulse."""
	config.glow_enabled = true
	config.shimmer_enabled = true
	config.pulse_enabled = true
	config.shadow_blur_enabled = true
	# Disable flashy effects
	config.particle_enabled = false
	config.sparkle_enabled = false
	config.rotation_enabled = false

func apply_preset_magical():
	"""Magical effects - particles, sparkles, and aura."""
	config.particle_enabled = true
	config.sparkle_enabled = true
	config.aura_enabled = true
	config.glow_enabled = true
	# Disable subtle effects
	config.shimmer_enabled = false
	config.pulse_enabled = false
