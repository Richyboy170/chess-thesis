# Character 5 - Hiyori (Live2D)

## Character Configuration

**Character Name:** `Hiyori`
**Character ID:** `5` (used in code references)
**Folder:** `character_5`

> **Important:** The JSON configuration files (`animations.json`) use `character_id: 5` and `character_name: "Hiyori"`. This is required for the Live2D animation system to work correctly. The character ID maps to the character in `live2d_animation_config.gd` and `piece_effects_config.gd`.

## Overview

Character 5 features **Hiyori**, a fully animated Live2D character model. This character uses the Live2D Cubism SDK through the GDCubism plugin to provide dynamic, real-time 2D animations with an elegant, light theme.

## Assets Included

### Live2D Model Files
- `Hiyori.model3.json` - Main model definition file
- `Hiyori.moc3` - Model data (mesh and deformers) (not included, needs to be compiled)
- `Hiyori.physics3.json` - Physics simulation configuration
- `Hiyori.pose3.json` - Pose configuration
- `Hiyori.userdata3.json` - User data configuration
- `Hiyori.cdi3.json` - CDI configuration file

### Textures
High-resolution textures for detailed rendering are included in the model directory.

### Animations (Motion Files)

Located in `motions/` folder:

| Animation | File | Purpose |
|-----------|------|---------|
| **Idle** | `Hiyori_m01.motion3.json` | Default idle animation |
| **Idle Variant 2** | `Hiyori_m02.motion3.json` | Alternative idle/hover animation |
| **Idle Variant 3** | `Hiyori_m03.motion3.json` | Alternative idle/select animation |
| **TapBody** | `Hiyori_m04.motion3.json` | Reaction when piece captured |
| **Flick Head** | `Hiyori_m05.motion3.json` | Victory celebration start |
| **Pinch In** | `Hiyori_m06.motion3.json` | Victory idle loop |
| **Shake** | `Hiyori_m07.motion3.json` | Defeat reaction |
| **Pinch Out** | `Hiyori_m08.motion3.json` | Defeat idle loop |
| **Tap Special** | `Hiyori_m09.motion3.json` | Special idle variant |
| **Idle Variant 10** | `Hiyori_m10.motion3.json` | Additional idle variant |

## Configuration Files

### Animation Configuration
**File:** `animations.json`

This JSON file defines all animations for Hiyori. The file MUST include:

```json
{
  "character_name": "Hiyori",
  "character_id": 5,
  "version": "1.0",
  "animations": {
    // ... animation definitions
  }
}
```

**Critical:** The `character_id` must be `5` to match the mapping in `live2d_animation_config.gd` and `piece_effects_config.gd`. The `character_name` should be `"Hiyori"` for proper identification.

### Piece Effects Config
**File:** `piece_effects_config.gd`

Defines the visual effects for Character 5's chess pieces with a **soft pink/elegant theme**:
- Soft pink glowing effects
- Gentle scaling and rotation
- Delicate particle effects
- Elegant sparkles and aura
- 30% scale increase when holding pieces

### Backgrounds
**Folder:** `backgrounds/`
- `character_background.png` - Static background for character selection preview

## Character Theme

**Visual Style:** Elegant / Light / Graceful
**Primary Colors:** Soft pink, light tones, warm pastels
**Effects:** Gentle glow, subtle sparkles, elegant

## Technical Requirements

### Prerequisites
1. **Godot Engine 4.3+** - Required for GDCubism compatibility
2. **GDCubism Plugin** - Live2D integration plugin
   - Install instructions: See `/LIVE2D_SETUP.md`
   - Repository: https://github.com/MizunagiKB/gd_cubism

## Integration Status

✅ **Completed:**
- Model and assets imported
- Character selection UI updated
- Piece effects configuration created
- Background and directory structure set up
- Animation configuration with multiple idle variants
- Character ID properly set to 5

⚠️ **Requires Setup:**
- GDCubism plugin binaries installation
- See `LIVE2D_SETUP.md` for complete setup instructions

## Usage in Game

### Character Selection
Character 5 appears as the fifth option in character selection for both Player 1 and Player 2. The preview will show:
- **With GDCubism:** Animated Live2D model (idle animation)
- **Without GDCubism:** Static texture preview (fallback)

### During Gameplay
When Character 5 is selected, the Live2D model can react to game events through animation triggers:
- Idle state during normal play (multiple variant animations)
- Reactions to piece movements
- Victory/defeat animations

### Animation Triggering

Example code to trigger animations using the Live2D Animation Config system:

```gdscript
# Using the Live2DAnimationConfig helper (RECOMMENDED)
const HIYORI_ID = 5  # Character ID for Hiyori

# Get the Live2D model node
var live2d_model = get_character_live2d_model()

# Play animations using action names from animations.json
Live2DAnimationConfig.play_animation(live2d_model, HIYORI_ID, "hover_piece")
Live2DAnimationConfig.play_animation(live2d_model, HIYORI_ID, "piece_captured")
Live2DAnimationConfig.play_animation(live2d_model, HIYORI_ID, "win_enter")
Live2DAnimationConfig.play_animation(live2d_model, HIYORI_ID, "idle")
```

**Note:** Using `Live2DAnimationConfig.play_animation()` is recommended as it automatically loads the correct animation parameters from `animations.json`.

## Customization

### Adjusting Piece Effects
Edit `piece_effects_config.gd` to customize:
- Effect toggles (enable/disable)
- Colors and intensities (currently soft pink theme)
- Animation durations
- Scale factors

### Adding Custom Animations
To add new animations:
1. Create motion files using Live2D Cubism Editor
2. Export as `.motion3.json`
3. Place in the `motions/` folder
4. Update `animations.json` to reference the new animations

### Changing Colors
To change the character's color theme:
1. Edit `glow_color` in `piece_effects_config.gd` (currently Color(1.0, 0.7, 0.9, 0.8))
2. Edit `aura_color` for aura effects (currently Color(1.0, 0.6, 0.85, 0.5))
3. Edit `color_shift_tint` for piece color shifts (currently Color(1.15, 1.05, 1.1))

## Performance Notes

Live2D rendering is generally performant, but for lower-end devices:
- Disable particle effects
- Reduce texture resolution
- Disable physics simulation
- Use static texture preview instead

## File Naming

All files follow the naming convention:
- Model files: `Hiyori.*`
- Motion files: `Hiyori_m##.motion3.json`
- Configuration: `character_id: 5` in all config files

**No file name changes needed** - all files are properly named and configured.

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
**Model Source:** Hiyori Live2D Model
