# Chess Piece Drag Effects System

A comprehensive visual effects system for chess pieces during drag operations. This system provides customizable animations and visual feedback when players hold and move chess pieces.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Available Effects](#available-effects)
- [Custom Held Images](#custom-held-images)
- [Presets](#presets)
- [Advanced Usage](#advanced-usage)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)

---

## Overview

The Piece Effects System (`scripts/piece_effects.gd`) provides a modular and highly customizable way to add visual effects to chess pieces when they are being dragged. Each effect can be independently enabled, disabled, and customized.

**Key Features:**
- 12 different effect types (glow, pulse, particles, etc.)
- Image swapping system for alternate piece appearances
- Easy enable/disable configuration
- Multiple built-in presets
- No performance impact when effects are disabled

---

## Features

### 1. Image Swap System
- Swap piece images when held (PNG, JPEG, OGV supported)
- Support for static images and animated videos
- Automatic fallback to default images

### 2. Visual Effects
- **Glow**: Glowing outline/aura with customizable colors
- **Pulse**: Gentle pulsing scale animation
- **Rotation**: Smooth swaying rotation
- **Shimmer**: Sweeping light effect across piece
- **Particles**: Sparkle/magic dust particles
- **Shadow Blur**: Multi-layered shadow for depth
- **Color Shift**: Dynamic color tinting
- **Sparkle**: Occasional random sparkles
- **Aura**: Large colored energy field
- **Trail**: Motion trail effect (experimental)

### 3. Easy Configuration
- Enable/disable effects in one central location
- Per-effect parameter customization
- Runtime configuration support
- Built-in preset configurations

---

## Installation

The effects system is already integrated into the main game. If you need to set it up manually:

1. **Add the script**: The file `scripts/piece_effects.gd` contains all effect logic.

2. **Integration**: The main game (`scripts/main_game.gd`) automatically:
   - Initializes the effects system on startup
   - Applies effects when pieces are picked up
   - Removes effects when pieces are released

3. **No additional setup required** - the system is ready to use!

---

## Quick Start

### Enabling/Disabling Effects

Open `scripts/piece_effects.gd` and find the configuration section:

```gdscript
var config = {
	"image_swap_enabled": true,      # Swap to alternate image when held
	"scale_enabled": true,           # Scale piece up when held
	"rotation_enabled": false,       # Gentle rotation animation
	"glow_enabled": true,            # Add glowing outline
	"pulse_enabled": false,          # Pulsing scale animation
	"shimmer_enabled": false,        # Shimmering light effect
	"particle_enabled": false,       # Particle effect around piece
	"shadow_blur_enabled": true,     # Blurred shadow effect
	"color_shift_enabled": false,    # Shift piece color when held
	"sparkle_enabled": false,        # Occasional sparkle effects
	"aura_enabled": false,           # Colored aura around piece
	"trail_enabled": false,          # Motion trail effect
}
```

**To enable an effect**: Set its value to `true`
**To disable an effect**: Set its value to `false`

### Example: Minimal Setup

For a clean, professional look with minimal effects:

```gdscript
var config = {
	"image_swap_enabled": false,
	"scale_enabled": true,           # ✓ Enabled
	"rotation_enabled": false,
	"glow_enabled": true,            # ✓ Enabled
	"pulse_enabled": false,
	"shimmer_enabled": false,
	"particle_enabled": false,
	"shadow_blur_enabled": true,     # ✓ Enabled
	"color_shift_enabled": false,
	"sparkle_enabled": false,
	"aura_enabled": false,
	"trail_enabled": false,
}
```

This provides subtle visual feedback without being overwhelming.

---

## Configuration

### Effect Configuration

Each effect has customizable parameters in its function definition. Find the effect function in `scripts/piece_effects.gd` and adjust values.

#### Example: Customizing Glow Color

Find the `apply_glow_effect()` function call in the `apply_drag_effects()` function:

```gdscript
# Default golden glow
apply_glow_effect(piece_node, Color(1.0, 0.9, 0.3, 0.8))

# Alternative options (uncomment to use):
#apply_glow_effect(piece_node, Color(0.3, 0.8, 1.0, 0.8))  # Blue glow
#apply_glow_effect(piece_node, Color(1.0, 0.3, 0.3, 0.8))  # Red glow
#apply_glow_effect(piece_node, Color(0.5, 1.0, 0.3, 0.8))  # Green glow
```

**To change glow color:**
1. Comment out the current line by adding `#` at the start
2. Uncomment your desired color option by removing the `#`

#### Example: Customizing Pulse Speed

Find the pulse effect call:

```gdscript
apply_pulse_effect(piece_node, 1.0, 1.15, 1.5)
# Parameters: min_scale, max_scale, duration (seconds)
```

**To make pulsing faster:**
```gdscript
apply_pulse_effect(piece_node, 1.0, 1.15, 0.8)  # Faster (0.8 seconds)
```

**To make pulsing more dramatic:**
```gdscript
apply_pulse_effect(piece_node, 1.0, 1.25, 1.5)  # Larger size change
```

---

## Available Effects

### 1. Image Swap Effect
**Purpose**: Changes piece appearance when held
**Config**: `image_swap_enabled`
**Customization**: Define custom image paths in `held_piece_image_paths`

```gdscript
var held_piece_image_paths = {
	"king": "res://assets/characters/character_1/pieces/held/white_king.png",
	"queen": "res://assets/characters/character_1/pieces/held/white_queen.png",
	# ... add more pieces
}
```

**Supported formats**: PNG, JPEG, OGV (video)

---

### 2. Enhanced Scale Effect
**Purpose**: Makes piece larger when held
**Config**: `scale_enabled`
**Default**: 1.3x scale (30% larger)
**Parameters**:
- `scale_factor`: How much to enlarge (1.3 = 30% larger)

---

### 3. Glow Effect
**Purpose**: Adds glowing outline around piece
**Config**: `glow_enabled`
**Default Color**: Golden (1.0, 0.9, 0.3, 0.8)
**Parameters**:
- `glow_color`: RGBA color of the glow

**Available presets** (uncomment to use):
- Golden glow (default)
- Blue glow
- Red glow
- Green glow

---

### 4. Pulse Effect
**Purpose**: Gentle pulsing size animation
**Config**: `pulse_enabled`
**Default**: 1.0 to 1.15 scale over 1.5 seconds
**Parameters**:
- `min_scale`: Minimum size multiplier
- `max_scale`: Maximum size multiplier
- `duration`: Full pulse cycle time (seconds)

---

### 5. Rotation Effect
**Purpose**: Gentle swaying rotation
**Config**: `rotation_enabled`
**Default**: ±10 degrees over 3 seconds
**Parameters**:
- `max_rotation`: Maximum rotation angle (degrees)
- `duration`: Full rotation cycle time (seconds)

---

### 6. Shimmer Effect
**Purpose**: Light sweeps across piece surface
**Config**: `shimmer_enabled`
**Behavior**: White light bar moves across piece every 3 seconds

---

### 7. Particle Effect
**Purpose**: Sparkles/magic dust around piece
**Config**: `particle_enabled`
**Default**: 20 golden particles
**Note**: Uses `CPUParticles2D` for best compatibility

---

### 8. Shadow Blur Effect
**Purpose**: Enhanced multi-layer shadow
**Config**: `shadow_blur_enabled`
**Behavior**: Creates 3 shadow layers for depth effect

---

### 9. Color Shift Effect
**Purpose**: Changes piece tint/color when held
**Config**: `color_shift_enabled`
**Default**: Warm golden tint (1.2, 1.1, 0.9)
**Parameters**:
- `target_color`: RGB multipliers (>1.0 = brighter, <1.0 = darker)

**Available presets** (uncomment to use):
- Warm golden tint (default)
- Cool blue tint
- Pink/purple tint

---

### 10. Sparkle Effect
**Purpose**: Random sparkle flashes on piece
**Config**: `sparkle_enabled`
**Behavior**: Occasional white sparkles appear randomly

---

### 11. Aura Effect
**Purpose**: Large colored energy field around piece
**Config**: `aura_enabled`
**Default**: Golden aura (1.0, 0.8, 0.0, 0.5)
**Parameters**:
- `aura_color`: RGBA color of the aura

**Available presets** (uncomment to use):
- Golden aura (default)
- Blue aura
- Pink aura

---

### 12. Trail Effect
**Purpose**: Motion trail following piece
**Config**: `trail_enabled`
**Status**: Experimental - sets metadata flag for custom implementation

---

## Custom Held Images

You can use different images for pieces when they are being held.

### Directory Structure

Create a `held` folder in each character's pieces directory:

```
assets/
├── characters/
│   ├── character_1/
│   │   ├── pieces/
│   │   │   ├── white_king.png          (default image)
│   │   │   ├── white_queen.png
│   │   │   └── held/
│   │   │       ├── white_king.png      (held image)
│   │   │       ├── white_queen.png
│   │   │       └── white_king.ogv      (animated held image)
│   │   └── ...
│   ├── character_2/
│   │   └── ...
│   └── character_3/
│       └── ...
```

### Configuring Custom Images

**Option 1: Automatic Discovery**
Place images in `assets/characters/character_X/pieces/held/white_PIECETYPE.png`
The system will automatically find and use them.

**Option 2: Manual Configuration**
Edit `held_piece_image_paths` in `piece_effects.gd`:

```gdscript
var held_piece_image_paths = {
	"king": "res://assets/characters/character_1/pieces/held/white_king.png",
	"queen": "res://assets/characters/character_1/pieces/held/white_queen.ogv",
	"rook": "res://assets/characters/character_1/pieces/held/white_rook.png",
	"bishop": "res://assets/characters/character_1/pieces/held/white_bishop.png",
	"knight": "res://assets/characters/character_1/pieces/held/white_knight.png",
	"pawn": "res://assets/characters/character_1/pieces/held/white_pawn.png",
}
```

### Supported Image Types

| Format | Extension | Use Case |
|--------|-----------|----------|
| PNG | `.png` | Static images (recommended) |
| JPEG | `.jpg`, `.jpeg` | Static images |
| OGV Video | `.ogv` | Animated pieces |

### Creating Held Images

**Recommendations:**
- Use the same dimensions as your default piece images
- Add visual effects (glow, highlight, energy) in the image itself
- Combine image swap with other effects for maximum impact
- For animations, keep OGV files under 1MB for performance

**Example Ideas:**
- Glowing version of the piece
- Piece with energy/magic effects
- Highlighted/selected version
- Animated floating or rotating piece (OGV)

---

## Presets

The effects system includes built-in preset configurations for different styles.

### Available Presets

#### 1. Minimal Preset
```gdscript
piece_effects.apply_preset_minimal()
```
**Effects**: Scale + Subtle Glow
**Use**: Clean, professional look
**Performance**: Excellent

---

#### 2. Moderate Preset
```gdscript
piece_effects.apply_preset_moderate()
```
**Effects**: Scale + Glow + Pulse + Shadow
**Use**: Balanced visual feedback
**Performance**: Good

---

#### 3. Maximum Preset
```gdscript
piece_effects.apply_preset_maximum()
```
**Effects**: ALL effects enabled
**Use**: Showcase/demonstration
**Performance**: May be intense
**Warning**: Very flashy, potentially overwhelming

---

#### 4. Elegant Preset
```gdscript
piece_effects.apply_preset_elegant()
```
**Effects**: Glow + Shimmer + Subtle Pulse + Shadow
**Use**: Refined, sophisticated look
**Performance**: Good

---

#### 5. Magical Preset
```gdscript
piece_effects.apply_preset_magical()
```
**Effects**: Particles + Sparkles + Aura + Glow
**Use**: Fantasy/magical theme
**Performance**: Moderate

---

### Using Presets

**Option 1: In Code**
Add to `main_game.gd` in the `_ready()` function:

```gdscript
func _ready():
	# ... existing initialization code ...

	# Apply preset after piece_effects initialization
	if piece_effects:
		piece_effects.apply_preset_elegant()
```

**Option 2: Runtime Toggle**
Create UI buttons to switch presets during gameplay:

```gdscript
func _on_minimal_button_pressed():
	piece_effects.apply_preset_minimal()

func _on_magical_button_pressed():
	piece_effects.apply_preset_magical()
```

---

## Advanced Usage

### Runtime Configuration

You can change effect settings while the game is running:

```gdscript
# Enable glow effect at runtime
piece_effects.set_config("glow_enabled", true)

# Disable particles at runtime
piece_effects.set_config("particle_enabled", false)

# Check if effect is enabled
var is_glow_on = piece_effects.get_config("glow_enabled")
```

### Custom Effect Parameters

To create your own effect variations, modify the function calls in `apply_drag_effects()`:

```gdscript
# Custom purple glow
if config.glow_enabled:
	apply_glow_effect(piece_node, Color(0.8, 0.2, 1.0, 0.7))

# Fast, dramatic pulse
if config.pulse_enabled:
	apply_pulse_effect(piece_node, 1.0, 1.4, 0.6)

# Intense rotation
if config.rotation_enabled:
	apply_rotation_effect(piece_node, 25.0, 2.0)
```

### Per-Piece Effect Customization

You can apply different effects based on piece type:

```gdscript
func apply_drag_effects(piece_node: Node, piece_data: Dictionary = {}):
	# ... existing code ...

	var piece_type = piece_data.get("type", "")

	# Special effects for kings
	if piece_type == "king":
		apply_aura_effect(piece_node, Color(1.0, 0.8, 0.0, 0.6))  # Golden aura

	# Different glow for queens
	elif piece_type == "queen":
		apply_glow_effect(piece_node, Color(0.8, 0.2, 1.0, 0.8))  # Purple glow

	# Sparkles for knights
	elif piece_type == "knight":
		apply_sparkle_effect(piece_node)

	# Default effects for other pieces
	else:
		if config.glow_enabled:
			apply_glow_effect(piece_node, Color(1.0, 0.9, 0.3, 0.8))
```

### Performance Optimization

**Disable Effects for Low-End Devices:**

```gdscript
func _ready():
	# ... initialization ...

	# Detect device performance
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		# Mobile devices: use minimal effects
		piece_effects.apply_preset_minimal()
	else:
		# Desktop: use elegant effects
		piece_effects.apply_preset_elegant()
```

**Conditional Effect Loading:**

```gdscript
# Only enable particle effects on high-end systems
if OS.get_processor_count() >= 4:
	piece_effects.set_config("particle_enabled", true)
else:
	piece_effects.set_config("particle_enabled", false)
```

---

## API Reference

### Main Functions

#### `apply_drag_effects(piece_node: Node, piece_data: Dictionary)`
Applies all enabled effects to a piece when drag starts.

**Parameters:**
- `piece_node`: The visual node (TextureRect or Label) of the piece
- `piece_data`: Dictionary with piece information:
  - `type`: Piece type ("king", "queen", etc.)
  - `color`: Piece color ("white" or "black")
  - `character_id`: Character theme ID (1-3)
  - `position`: Board position (Vector2i)

**Example:**
```gdscript
var data = {
	"type": "queen",
	"color": "white",
	"character_id": 1
}
piece_effects.apply_drag_effects(piece_node, data)
```

---

#### `remove_drag_effects(piece_node: Node)`
Removes all effects from a piece when drag ends.

**Parameters:**
- `piece_node`: The piece node to clean up

**Example:**
```gdscript
piece_effects.remove_drag_effects(piece_node)
```

---

#### `set_config(key: String, value: bool)`
Dynamically enable/disable effects at runtime.

**Parameters:**
- `key`: Effect name (e.g., "glow_enabled")
- `value`: `true` to enable, `false` to disable

**Example:**
```gdscript
piece_effects.set_config("particle_enabled", true)
```

---

#### `get_config(key: String) -> bool`
Gets current configuration value for an effect.

**Returns:** `true` if enabled, `false` if disabled

**Example:**
```gdscript
var has_glow = piece_effects.get_config("glow_enabled")
print("Glow is ", "enabled" if has_glow else "disabled")
```

---

### Preset Functions

- `apply_preset_minimal()` - Minimal effects
- `apply_preset_moderate()` - Balanced effects
- `apply_preset_maximum()` - All effects
- `apply_preset_elegant()` - Refined effects
- `apply_preset_magical()` - Fantasy effects

---

## Troubleshooting

### Issue: Effects not appearing

**Solution 1**: Check that effects are enabled in config
```gdscript
# In piece_effects.gd, verify:
var config = {
	"glow_enabled": true,  # Make sure this is true, not false
	# ...
}
```

**Solution 2**: Verify piece_effects is initialized
```gdscript
# In main_game.gd _ready() function:
piece_effects = preload("res://scripts/piece_effects.gd").new()
add_child(piece_effects)
```

---

### Issue: Image swap not working

**Possible causes:**
1. Image file doesn't exist at the specified path
2. Image path is incorrect in `held_piece_image_paths`
3. `image_swap_enabled` is set to `false`

**Solution:**
```gdscript
# Verify file exists
var path = "res://assets/characters/character_1/pieces/held/white_king.png"
if FileAccess.file_exists(path):
	print("Image found!")
else:
	print("Image NOT found at: ", path)
```

---

### Issue: Performance problems

**Solution 1**: Use a lighter preset
```gdscript
piece_effects.apply_preset_minimal()
```

**Solution 2**: Disable specific heavy effects
```gdscript
piece_effects.set_config("particle_enabled", false)
piece_effects.set_config("shimmer_enabled", false)
```

**Solution 3**: Reduce particle count
```gdscript
# In apply_particle_effect() function:
particles.amount = 10  # Reduced from 20
```

---

### Issue: Effects look different than expected

**Cause**: Color modulation from black piece tinting may affect effect colors

**Solution**: Adjust effect colors for black pieces separately:
```gdscript
var piece_color = piece_data.get("color", "white")
var glow_color = Color(1.0, 0.9, 0.3, 0.8) if piece_color == "white" else Color(0.7, 0.7, 1.0, 0.8)
apply_glow_effect(piece_node, glow_color)
```

---

### Issue: Effects persist after dropping piece

**Cause**: `remove_drag_effects()` not being called

**Solution**: Verify it's called in both `end_drag()` and `return_piece_to_original_position()`:
```gdscript
if piece_effects and dragging_piece:
	piece_effects.remove_drag_effects(dragging_piece)
```

---

## Support and Feedback

For questions, issues, or feature requests:

1. Check the main `GAME_INTERFACE_GUIDE.md` for UI adjustment information
2. Review the inline comments in `scripts/piece_effects.gd`
3. Examine example configurations in this README

---

## Version History

**v1.0** - Initial release
- 12 effect types
- Image swap system
- 5 built-in presets
- Runtime configuration
- Full documentation

---

## License

Part of the Chess Thesis project. See main project license.
