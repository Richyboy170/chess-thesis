extends Node

# ============================================================================
# CHESS PIECE DRAG EFFECTS SYSTEM - CHARACTER-SPECIFIC
# ============================================================================
# This script provides configurable visual effects for chess pieces when
# they are being held/dragged by the player. Each CHARACTER has its own
# individual configuration with customizable effects.
#
# USAGE:
# 1. Add this script as an autoload singleton in Project Settings
# 2. Call PieceEffects.apply_drag_effects(piece_node, piece_data) when drag starts
# 3. Call PieceEffects.remove_drag_effects(piece_node) when drag ends
# 4. Each character's config is in assets/characters/character_X/piece_effects_config.gd
#
# CUSTOMIZATION:
# - Edit character-specific configs in assets/characters/character_X/piece_effects_config.gd
# - Each character has its own effect toggles, parameters, and held image folder
# - Add custom piece images for held state in assets/characters/character_X/pieces/held/
# ============================================================================

# ============================================================================
# CHARACTER-SPECIFIC CONFIGURATIONS
# ============================================================================
# Store loaded configurations for each character
var character_configs = {}

# Default fallback config (used if character config not found)
var config = {
	"image_swap_enabled": true,
	"scale_enabled": true,
	"rotation_enabled": false,
	"glow_enabled": true,
	"pulse_enabled": false,
	"shimmer_enabled": false,
	"particle_enabled": false,
	"shadow_blur_enabled": true,
	"color_shift_enabled": false,
	"sparkle_enabled": false,
	"aura_enabled": false,
	"trail_enabled": false,
}

# Default held piece image paths (fallback)
var held_piece_image_paths = {}

# Store original textures to restore later
var original_textures = {}
var active_effects = {}  # Track active tweens and effects per piece

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	"""Load all character-specific configurations on startup."""
	load_character_configs()

func load_character_configs():
	"""
	Loads character-specific piece effects configurations.
	Each character has its own config file in their assets folder.
	"""
	for character_id in range(1, 4):  # Characters 1, 2, 3
		var config_path = "res://assets/characters/character_%d/piece_effects_config.gd" % character_id

		# Try to load the config
		if FileAccess.file_exists(config_path):
			var config_script = load(config_path)
			if config_script:
				var config_instance = config_script.new()
				character_configs[character_id] = config_instance
				print("Loaded piece effects config for Character ", character_id)
			else:
				# File exists but failed to load
				AnimationErrorDetector.log_load_failed(
					config_path,
					"PieceEffectsConfig script"
				)
		else:
			# File doesn't exist
			AnimationErrorDetector.log_file_not_found(
				config_path,
				"assets/characters/character_%d/" % character_id
			)
			print("Warning: No piece effects config found for Character ", character_id, " at ", config_path)

func get_character_config(character_id: int) -> PieceEffectsConfig:
	"""
	Gets the configuration for a specific character.
	Returns fallback config if character config not found.
	"""
	if character_id in character_configs:
		return character_configs[character_id]
	else:
		# Return null if not found - caller will use fallback
		return null

# ============================================================================
# MAIN EFFECT FUNCTIONS
# ============================================================================

func apply_drag_effects(piece_node: Node, piece_data: Dictionary = {}):
	"""
	Applies all enabled visual effects when a piece starts being dragged.
	Uses character-specific configuration.

	Args:
		piece_node: The visual node (TextureRect or Label) representing the piece
		piece_data: Dictionary with piece info (type, color, character_id)
	"""
	if not piece_node:
		return

	# Initialize effect tracking for this piece
	active_effects[piece_node] = {}

	# Get character-specific configuration
	var character_id = piece_data.get("character_id", 1)
	var char_config = get_character_config(character_id)

	# Use character config if available, otherwise use global fallback
	var active_config = char_config if char_config else null

	# ========================================
	# EFFECT ACTIVATION SECTION
	# ========================================
	# Effects are controlled by the character-specific config
	# Edit configs in: assets/characters/character_X/piece_effects_config.gd

	# 1. IMAGE SWAP - Change piece appearance when held
	var image_swap = active_config.image_swap_enabled if active_config else config.image_swap_enabled
	if image_swap:
		apply_image_swap(piece_node, piece_data, active_config)

	# 2. SCALE EFFECT - Make piece larger
	var scale_on = active_config.scale_enabled if active_config else config.scale_enabled
	if scale_on:
		var scale_factor = active_config.scale_factor if active_config else 1.3
		apply_enhanced_scale(piece_node, scale_factor)

	# 3. GLOW EFFECT - Add glowing outline
	var glow_on = active_config.glow_enabled if active_config else config.glow_enabled
	if glow_on:
		var glow_color = active_config.glow_color if active_config else Color(1.0, 0.9, 0.3, 0.8)
		apply_glow_effect(piece_node, glow_color)

	# 4. PULSE EFFECT - Gentle pulsing animation
	var pulse_on = active_config.pulse_enabled if active_config else config.pulse_enabled
	if pulse_on:
		var min_s = active_config.pulse_min_scale if active_config else 1.0
		var max_s = active_config.pulse_max_scale if active_config else 1.15
		var duration = active_config.pulse_duration if active_config else 1.5
		apply_pulse_effect(piece_node, min_s, max_s, duration)

	# 5. ROTATION EFFECT - Gentle rotation
	var rotation_on = active_config.rotation_enabled if active_config else config.rotation_enabled
	if rotation_on:
		var max_rot = active_config.max_rotation if active_config else 10.0
		var duration = active_config.rotation_duration if active_config else 3.0
		apply_rotation_effect(piece_node, max_rot, duration)

	# 6. SHIMMER EFFECT - Shimmering light overlay
	var shimmer_on = active_config.shimmer_enabled if active_config else config.shimmer_enabled
	if shimmer_on:
		apply_shimmer_effect(piece_node)

	# 7. PARTICLE EFFECT - Sparkles and particles
	var particle_on = active_config.particle_enabled if active_config else config.particle_enabled
	if particle_on:
		apply_particle_effect(piece_node)

	# 8. SHADOW BLUR - Enhanced shadow with blur
	var shadow_on = active_config.shadow_blur_enabled if active_config else config.shadow_blur_enabled
	if shadow_on:
		apply_shadow_blur(piece_node)

	# 9. COLOR SHIFT - Change piece tint when held
	var color_shift_on = active_config.color_shift_enabled if active_config else config.color_shift_enabled
	if color_shift_on:
		var tint = active_config.color_shift_tint if active_config else Color(1.2, 1.1, 0.9)
		apply_color_shift(piece_node, tint)

	# 10. SPARKLE EFFECT - Occasional sparkles
	var sparkle_on = active_config.sparkle_enabled if active_config else config.sparkle_enabled
	if sparkle_on:
		apply_sparkle_effect(piece_node)

	# 11. AURA EFFECT - Colored aura around piece
	var aura_on = active_config.aura_enabled if active_config else config.aura_enabled
	if aura_on:
		var aura_color = active_config.aura_color if active_config else Color(1.0, 0.8, 0.0, 0.5)
		apply_aura_effect(piece_node, aura_color)

	# 12. TRAIL EFFECT - Motion trail (for drag movement)
	var trail_on = active_config.trail_enabled if active_config else config.trail_enabled
	if trail_on:
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
func apply_image_swap(piece_node: Node, piece_data: Dictionary, char_config: PieceEffectsConfig = null):
	"""
	Swaps the piece image to an alternate 'held' version.
	Supports PNG, JPEG, and OGV (video) files.
	Uses character-specific held image paths.

	Args:
		piece_node: The TextureRect displaying the piece
		piece_data: Dictionary with 'type' (e.g., 'king'), 'color', 'character_id'
		char_config: Character-specific configuration (optional)
	"""
	if not piece_node is TextureRect:
		return  # Only works with TextureRect (image-based pieces)

	# Get piece type
	var piece_type = piece_data.get("type", "").to_lower()
	if piece_type == "":
		return

	var character_id = piece_data.get("character_id", 1)
	var held_image_path = ""

	# Try to get held image path from character config
	if char_config:
		held_image_path = char_config.get_held_image_path(piece_type)
	else:
		# Fallback: Try loading from default held folder
		held_image_path = "res://assets/characters/character_%d/pieces/held/white_%s.png" % [character_id, piece_type]

	# Try to load the held image
	if held_image_path != "" and FileAccess.file_exists(held_image_path):
		var held_texture = load(held_image_path)
		if held_texture:
			# Store original texture for restoration
			original_textures[piece_node] = piece_node.texture

			# Apply held texture
			piece_node.texture = held_texture
			print("Swapped to held image for Character %d: %s" % [character_id, held_image_path])
			return
		else:
			# File exists but failed to load
			AnimationErrorDetector.log_load_failed(
				held_image_path,
				"Held piece texture for %s" % piece_type
			)

	# If we get here, no held image was found - piece keeps its original image
	# (This is not an error - held images are optional)
	print("No held image found for Character %d, %s - using original" % [character_id, piece_type])

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
