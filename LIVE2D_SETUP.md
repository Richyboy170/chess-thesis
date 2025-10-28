# Live2D Integration Setup Guide

> **Seeing GDExtension errors?** Check [QUICK_FIX_GDCUBISM_ERROR.md](QUICK_FIX_GDCUBISM_ERROR.md) for a quick explanation and fix.

## Overview

This project includes **Character 4 (Scyka)**, a Live2D animated character integrated into the chess game. This guide explains how to set up the Live2D functionality using the GDCubism plugin.

**Note:** The project will work without GDCubism binaries installed - Character 4 will simply display as a static image instead of an animated Live2D model.

## Current Status

✅ **COMPLETED:**
- Character 4 assets (Scyka Live2D model) are present in `assets/characters/character_4/`
- Character 4 UI integration complete
- Character selection screen updated with Character 4 button
- Piece effects configuration created for Character 4
- GDCubism plugin structure installed in `addons/gd_cubism/`
- **GDCubism binaries compiled and installed** (v0.9.1 with CubismSDK 5-r.4.1)
- Linux x86_64 binaries (debug + release) ready in `addons/gd_cubism/bin/`

✅ **READY TO USE:**
- Open project in Godot 4.5 and test Character 4!
- See [IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md) for full details

## Live2D Assets Included

The following Live2D assets for Scyka are already included:

```
assets/characters/character_4/
├── Scyka.model3.json          # Live2D model definition
├── Scyka.moc3                 # Live2D model data
├── Scyka.physics3.json        # Physics simulation
├── Scyka.4096/                # Texture files
│   ├── texture_00.png
│   ├── texture_01.png
│   ├── texture_02.png
│   └── texture_03.png
└── Motion files:
    ├── Idle.motion3.json
    ├── Hover Piece.motion3.json
    ├── Shock (Been Eated).motion3.json
    ├── Win (Enter).motion3.json
    ├── Win (Idle).motion3.json
    └── Lose(Enter).motion3.json
```

## GDCubism Plugin Setup

### About GDCubism

GDCubism is an unofficial GDExtension that enables Live2D Cubism SDK functionality in Godot Engine 4.3+.

- **Repository:** https://github.com/MizunagiKB/gd_cubism
- **Documentation:** https://mizunagikb.github.io/gd_cubism/
- **License:** See `addons/gd_cubism/LICENSE.adoc`

### Installation Steps

#### Option 1: Download Pre-built Binaries (Recommended)

1. **Download the latest release:**
   - Visit: https://github.com/MizunagiKB/gd_cubism/releases
   - Download the appropriate version for Godot 4.3+
   - Look for `gd_cubism-vX.X.X.zip` in the release assets

2. **Extract binaries:**
   ```bash
   # Extract the downloaded zip file
   unzip gd_cubism-vX.X.X.zip -d /tmp/gd_cubism_release

   # Copy the bin folder to the project
   cp -r /tmp/gd_cubism_release/addons/gd_cubism/bin/* addons/gd_cubism/bin/
   ```

3. **Verify installation:**
   The `addons/gd_cubism/bin/` folder should now contain:
   - `libgd_cubism.linux.*.so` (for Linux)
   - `libgd_cubism.windows.*.dll` (for Windows)
   - `libgd_cubism.macos.*.framework` (for macOS)

#### Option 2: Build from Source

If pre-built binaries are not available for your platform:

1. **Prerequisites:**
   - Python 3.6+
   - SCons build system
   - C++ compiler (GCC, Clang, or MSVC)
   - Git

2. **Build steps:**
   ```bash
   # Navigate to the cloned repository (outside project)
   cd /path/to/gd_cubism

   # Initialize submodules (if not done)
   git submodule update --init --recursive

   # Build for your platform
   scons platform=linux target=template_release
   scons platform=linux target=template_debug

   # Copy built binaries to project
   cp bin/*.so /path/to/chess-thesis/addons/gd_cubism/bin/
   ```

3. **Platform-specific build instructions:**
   - Full build guide: https://mizunagikb.github.io/gd_cubism/gd_cubism/0.8/en/build.html

### Enable the Plugin in Godot

1. **Open the project in Godot Engine**

2. **Enable GDCubism plugin:**
   - Go to `Project → Project Settings → Plugins`
   - Find "GDCubism" in the list
   - Check the "Enable" checkbox
   - Click "Close"

3. **Verify plugin is loaded:**
   - Open the Godot console/output panel
   - Look for GDCubism initialization messages
   - No errors should appear

4. **Test Character 4:**
   - Run the project
   - Navigate to Character Selection
   - Character 4 button should display the Live2D preview
   - If GDCubism is properly loaded, you'll see the animated Scyka model
   - If not loaded, you'll see a static texture preview instead

## Project Configuration

The project is already configured to use Character 4:

### Character Selection Integration

**File:** `scripts/character_selection.gd`

The script includes:
- `load_live2d_preview_on_button()` - Loads Live2D preview on character buttons
- Automatic fallback to texture preview if GDCubism is unavailable
- Support for both Player 1 and Player 2 selecting Character 4

### Piece Effects Configuration

**File:** `assets/characters/character_4/piece_effects_config.gd`

Character 4 features a **mystical purple theme** with enhanced visual effects:
- Purple/violet glowing effects
- More dramatic scaling and rotation
- Sparkles and aura effects
- Enhanced particle effects

To customize effects, edit this file and adjust the parameters.

## Live2D Animations Available

Character 4 (Scyka) includes the following animations:

| Animation | File | Use Case |
|-----------|------|----------|
| Idle | `Idle.motion3.json` | Default idle state |
| Hover Piece | `Hover Piece.motion3.json` | When hovering over a piece |
| Shock | `Shock (Been Eated).motion3.json` | When a piece is captured |
| Win Enter | `Win (Enter).motion3.json` | Victory animation start |
| Win Idle | `Win (Idle).motion3.json` | Victory idle state |
| Lose Enter | `Lose(Enter).motion3.json` | Defeat animation |

## Troubleshooting

### Character 4 Preview Not Showing

**Problem:** Character 4 button shows no preview or blank space

**Solutions:**
1. Check that `Scyka.4096/texture_00.png` exists (fallback texture)
2. Verify file paths are correct
3. Check Godot console for error messages

### Live2D Model Not Animating

**Problem:** Character 4 shows static image instead of animated Live2D model

**Solutions:**
1. Verify GDCubism plugin binaries are installed in `addons/gd_cubism/bin/`
2. Check that GDCubism is enabled in Project Settings → Plugins
3. Confirm you're using Godot Engine 4.3 or later
4. Look for errors in Godot console mentioning "GDCubismUserModel"

### Plugin Not Loading

**Problem:** GDCubism plugin fails to load with errors

**Solutions:**
1. Ensure binaries match your OS and architecture:
   - Linux: `libgd_cubism.linux.*.so`
   - Windows: `libgd_cubism.windows.*.dll`
   - macOS: `libgd_cubism.macos.*.framework`
2. Check that you have both debug and release versions
3. Verify Godot version is 4.3 or later
4. Try rebuilding the plugin from source

### Performance Issues

**Problem:** Game runs slowly with Character 4

**Solutions:**
1. Reduce visual effects in `piece_effects_config.gd`:
   - Disable `particle_enabled`
   - Disable `trail_enabled`
   - Reduce `scale_factor`
2. Use lower resolution textures if needed
3. Disable Live2D physics in model settings

## Using Live2D During Gameplay

### Triggering Animations

To trigger animations for Character 4 during gameplay, use:

```gdscript
# Example: Trigger win animation
if character_id == 3:  # Character 4 (index 3)
    var live2d_model = get_character_live2d_node()
    if live2d_model and live2d_model.has_method("start_motion"):
        live2d_model.start_motion("Win (Enter)", 0, 2, false)
```

### Available Animation Control Methods

GDCubism provides these methods for controlling Live2D models:

- `start_motion(group, no, priority, loop)` - Start a motion
- `stop_motion()` - Stop current motion
- `set_parameter_value(id, value)` - Set parameter (e.g., eye blink)
- `get_parameter_value(id)` - Get current parameter value

Refer to GDCubism documentation for complete API reference.

## License Notes

### Live2D Cubism SDK License

The Live2D Cubism SDK has specific licensing terms:

- **Free License:** For small-scale applications and personal projects
- **Indie License:** For indie developers (annual revenue < $10M USD)
- **Commercial License:** For larger commercial projects

**Important:** Review the Live2D license terms at https://www.live2d.com/en/download/cubism-sdk/ before distributing your project.

### GDCubism License

GDCubism is provided under its own license terms. See `addons/gd_cubism/LICENSE.adoc` for details.

## Resources

### Official Links

- **Live2D Cubism:** https://www.live2d.com/
- **Live2D SDK Download:** https://www.live2d.com/download/cubism-sdk/
- **GDCubism GitHub:** https://github.com/MizunagiKB/gd_cubism
- **GDCubism Documentation:** https://mizunagikb.github.io/gd_cubism/

### Community Resources

- **Live2D Forums:** https://community.live2d.com/
- **Godot Forums:** https://forum.godotengine.org/
- **GDCubism Issues:** https://github.com/MizunagiKB/gd_cubism/issues

## Support

If you encounter issues:

1. **Check this guide first** - Most common issues are covered here
2. **Review GDCubism documentation** - https://mizunagikb.github.io/gd_cubism/
3. **Check Godot console** - Error messages often indicate the problem
4. **Search GDCubism issues** - Someone may have had the same problem
5. **Create a new issue** - If the problem is plugin-related

---

**Status:** ✅ Integration Framework Complete
**Next Step:** Install GDCubism binaries and enable plugin
**Version:** 1.0
**Date:** 2025-10-28
