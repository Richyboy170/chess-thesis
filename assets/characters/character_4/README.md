# Character 4 - Scyka (Live2D)

## Character Configuration

**Character Name:** `Scyka`
**Character ID:** `3` (used in code references)
**Folder:** `character_4`

> **Important:** The JSON configuration files (`animations.json`) use `character_id: 3` and `character_name: "Scyka"`. This is required for the Live2D animation system to work correctly. The character ID maps to the character in `live2d_animation_config.gd`.

## Overview

Character 4 features **Scyka**, a fully animated Live2D character model. This character uses the Live2D Cubism SDK through the GDCubism plugin to provide dynamic, real-time 2D animations.

## Assets Included

### Live2D Model Files
- `Scyka.model3.json` - Main model definition file
- `Scyka.moc3` - Model data (mesh and deformers)
- `Scyka.physics3.json` - Physics simulation configuration

### Textures
Located in `Scyka.4096/` folder:
- `texture_00.png` - Main texture atlas
- `texture_01.png` - Additional texture atlas
- `texture_02.png` - Additional texture atlas
- `texture_03.png` - Additional texture atlas

High-resolution textures (4096x4096) for detailed rendering.

### Animations (Motion Files)

| Animation | File | Purpose |
|-----------|------|---------|
| **Idle** | `Idle.motion3.json` | Default idle breathing animation |
| **Hover Piece** | `Hover Piece.motion3.json` | When player hovers over a chess piece |
| **Shock** | `Shock (Been Eated).motion3.json` | Reaction when a piece is captured |
| **Win Enter** | `Win (Enter).motion3.json` | Victory celebration start |
| **Win Idle** | `Win (Idle).motion3.json` | Victory idle loop |
| **Lose Enter** | `Lose(Enter).motion3.json` | Defeat reaction |

## Configuration Files

### Animation Configuration
**File:** `animations.json`

This JSON file defines all animations for Scyka. The file MUST include:

```json
{
  "character_name": "Scyka",
  "character_id": 3,
  "version": "1.0",
  "animations": {
    // ... animation definitions
  }
}
```

**Critical:** The `character_id` must be `3` to match the mapping in `live2d_animation_config.gd`. The `character_name` should be `"Scyka"` for proper identification.

### Piece Effects Config
**File:** `piece_effects_config.gd`

Defines the visual effects for Character 4's chess pieces with a **mystical purple theme**:
- Purple/violet glowing effects
- Enhanced scaling and rotation
- Dramatic particle effects
- Sparkles and aura
- 35% scale increase when holding pieces

### Backgrounds
**Folder:** `backgrounds/`
- `character_background.png` - Static background for character selection preview

### Held Pieces
**Folder:** `pieces/held/`
- Custom held piece images can be placed here
- See `pieces/held/README.md` for instructions

## Character Theme

**Visual Style:** Mystical / Magical
**Primary Colors:** Purple, violet, magenta
**Effects:** Glowing, sparkling, ethereal

## Technical Requirements

### Prerequisites
1. **Godot Engine 4.3+** - Required for GDCubism compatibility
2. **GDCubism Plugin** - Live2D integration plugin
   - Install instructions: See `/LIVE2D_SETUP.md`
   - Repository: https://github.com/MizunagiKB/gd_cubism

### Live2D Parameters

The Scyka model includes the following parameter groups:

**LipSync:**
- `ParamMouthForm`
- `ParamMouthOpenY`

**EyeBlink:**
- `ParamEyeLOpen`
- `ParamEyeLSmile`
- `ParamEyeROpen`
- `ParamEyeRSmile`

These can be controlled programmatically for additional interactivity.

## Integration Status

✅ **Completed:**
- Model and assets imported
- Character selection UI updated
- Piece effects configuration created
- Background and directory structure set up
- Fallback texture preview implemented

⚠️ **Requires Setup:**
- GDCubism plugin binaries installation
- See `LIVE2D_SETUP.md` for complete setup instructions

## Usage in Game

### Character Selection
Character 4 appears as the fourth option in character selection for both Player 1 and Player 2. The preview will show:
- **With GDCubism:** Animated Live2D model (idle animation)
- **Without GDCubism:** Static texture preview (fallback)

### During Gameplay
When Character 4 is selected, the Live2D model can react to game events through animation triggers:
- Idle state during normal play
- Reactions to piece movements
- Victory/defeat animations

### Animation Triggering

Example code to trigger animations using the Live2D Animation Config system:

```gdscript
# Using the Live2DAnimationConfig helper (RECOMMENDED)
const SCYKA_ID = 3  # Character ID for Scyka

# Get the Live2D model node
var live2d_model = get_character_live2d_model()

# Play animations using action names from animations.json
Live2DAnimationConfig.play_animation(live2d_model, SCYKA_ID, "hover_piece")
Live2DAnimationConfig.play_animation(live2d_model, SCYKA_ID, "piece_captured")
Live2DAnimationConfig.play_animation(live2d_model, SCYKA_ID, "win_enter")
Live2DAnimationConfig.play_animation(live2d_model, SCYKA_ID, "idle")

# Manual method (if needed)
if live2d_model and live2d_model.has_method("start_motion"):
    # Hover animation when selecting a piece
    live2d_model.start_motion("Hover Piece", 0, 2, false)

    # Shock animation when piece captured
    live2d_model.start_motion("Shock (Been Eated)", 0, 2, false)

    # Victory animation
    live2d_model.start_motion("Win (Enter)", 0, 2, false)
```

**Note:** Using `Live2DAnimationConfig.play_animation()` is recommended as it automatically loads the correct animation parameters from `animations.json`.

## Customization

### Adjusting Piece Effects
Edit `piece_effects_config.gd` to customize:
- Effect toggles (enable/disable)
- Colors and intensities
- Animation durations
- Scale factors

### Adding Custom Animations
To add new animations:
1. Create motion files using Live2D Cubism Editor
2. Export as `.motion3.json`
3. Place in this folder
4. Reference in code using the motion name

### Changing Colors
To change the character's color theme:
1. Edit glow_color in `piece_effects_config.gd`
2. Edit aura_color for aura effects
3. Edit color_shift_tint for piece color shifts

## Performance Notes

Live2D rendering is generally performant, but for lower-end devices:
- Disable particle effects
- Reduce texture resolution
- Disable physics simulation
- Use static texture preview instead

## License

Please review Live2D licensing terms before distribution:
- **Live2D Cubism SDK:** https://www.live2d.com/en/download/cubism-sdk/
- **GDCubism:** See `addons/gd_cubism/LICENSE.adoc`

## Resources

- **Setup Guide:** `/LIVE2D_SETUP.md`
- **Piece Effects Guide:** `/PIECE_EFFECTS_README.md`
- **Character Effects Setup:** `/CHARACTER_EFFECTS_SETUP.md`
- **GDCubism Docs:** https://mizunagikb.github.io/gd_cubism/

---

**Character Created:** 2025-10-28
**Status:** Ready for use (requires GDCubism setup)
**Model Source:** Scyka Live2D Model
