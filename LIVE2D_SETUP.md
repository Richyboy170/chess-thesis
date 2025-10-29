# Live2D Integration Setup Guide

## Overview

This project uses the **GDCubism plugin** to enable Live2D Cubism functionality in Godot Engine. Character 4 (Scyka) is a Live2D animated character integrated into the chess game.

## Current Status

✅ **PLUGIN STRUCTURE INSTALLED:**
- GDCubism plugin structure (v0.9.1) installed in `gd_cubism/`
- Plugin ready for binary installation

⚠️ **BINARIES REQUIRED:**
- You need to download and install the platform-specific binaries
- See installation instructions below

## What You Need

### Prerequisites

- Godot Engine 4.3 or later
- GDCubism binaries for your platform (Linux, Windows, or macOS)

## Installation Steps

### Option 1: Download Pre-built Binaries (Recommended)

This is the easiest method and works for most users.

1. **Download the latest GDCubism release:**
   - Visit: https://github.com/MizunagiKB/gd_cubism/releases
   - Download the latest version (currently v0.9.1)
   - Look for the release ZIP file in the Assets section

2. **Extract the binaries:**
   ```bash
   # Extract the downloaded zip file
   unzip gd_cubism-vX.X.X.zip -d /tmp/gd_cubism_release

   # Navigate to your project directory
   cd /path/to/chess-thesis

   # Copy ONLY the bin folder contents to your project
   cp -r /tmp/gd_cubism_release/demo/addons/gd_cubism/bin/* gd_cubism/bin/
   ```

3. **Verify installation:**
   The `gd_cubism/bin/` folder should now contain platform-specific libraries:
   - **Linux:** `libgd_cubism.linux.debug.x86_64.so` and `libgd_cubism.linux.release.x86_64.so`
   - **Windows:** `libgd_cubism.windows.debug.x86_64.dll` and `libgd_cubism.windows.release.x86_64.dll`
   - **macOS:** `libgd_cubism.macos.debug.framework` and `libgd_cubism.macos.release.framework`

### Option 2: Build from Source

If pre-built binaries don't work or aren't available for your platform:

1. **Prerequisites:**
   - Python 3.6+
   - SCons build system (`pip install scons`)
   - C++ compiler (GCC/Clang/MSVC)
   - Git

2. **Clone and build:**
   ```bash
   # Clone the repository
   cd /tmp
   git clone --branch v0.9.1 https://github.com/MizunagiKB/gd_cubism.git
   cd gd_cubism

   # Initialize submodules
   git submodule update --init --recursive

   # Build for your platform
   # For Linux:
   scons platform=linux target=template_release arch=x86_64
   scons platform=linux target=template_debug arch=x86_64

   # For Windows:
   scons platform=windows target=template_release arch=x86_64
   scons platform=windows target=template_debug arch=x86_64

   # For macOS:
   scons platform=macos target=template_release arch=x86_64
   scons platform=macos target=template_debug arch=x86_64
   ```

3. **Copy built binaries:**
   ```bash
   # Copy built libraries to your project
   cp demo/addons/gd_cubism/bin/* /path/to/chess-thesis/gd_cubism/bin/
   ```

### Enable the Plugin in Godot

1. **Open the project in Godot Engine**

2. **The plugin should auto-enable, but if not:**
   - Go to `Project → Project Settings → Plugins`
   - Find "GDCubism" in the list
   - Check the "Enable" checkbox
   - Click "Close"

3. **Verify plugin is working:**
   - Open the Godot console/output panel
   - Look for GDCubism initialization messages
   - If you see errors, check that binaries are in the correct location

4. **Test Character 4:**
   - Run the project (F5)
   - Navigate to Character Selection
   - Click on Character 4 button
   - If GDCubism loaded successfully, you'll see the animated Live2D model
   - If not, you'll see a static texture fallback

## Live2D Assets Included

Character 4 (Scyka) assets are already included in the project:

```
assets/characters/character_4/
├── Scyka.model3.json          # Live2D model definition
├── Scyka.moc3                 # Live2D model data
├── Scyka.physics3.json        # Physics simulation
├── Scyka.4096/                # Texture files (4K)
│   ├── texture_00.png
│   ├── texture_01.png
│   ├── texture_02.png
│   └── texture_03.png
└── Animations/
    ├── Idle.motion3.json
    ├── Hover Piece.motion3.json
    ├── Shock (Been Eated).motion3.json
    ├── Win (Enter).motion3.json
    ├── Win (Idle).motion3.json
    └── Lose(Enter).motion3.json
```

## Available Animations

| Animation | File | Use Case |
|-----------|------|----------|
| Idle | `Idle.motion3.json` | Default idle state |
| Hover Piece | `Hover Piece.motion3.json` | When hovering over a piece |
| Shock | `Shock (Been Eated).motion3.json` | When a piece is captured |
| Win Enter | `Win (Enter).motion3.json` | Victory animation start |
| Win Idle | `Win (Idle).motion3.json` | Victory idle state |
| Lose Enter | `Lose(Enter).motion3.json` | Defeat animation |

## Troubleshooting

### Plugin Not Loading

**Symptoms:** Error messages mentioning "GDCubism" or "GDCubismUserModel" in console

**Solutions:**
1. Verify binaries exist in `gd_cubism/bin/`
2. Check that binaries match your platform (Linux/Windows/macOS)
3. Ensure you have both debug and release versions
4. Confirm Godot version is 4.3 or later
5. Check file permissions (Linux/macOS: binaries should be executable)

### Character 4 Shows Static Image

**Symptoms:** Character 4 displays but doesn't animate

**Solutions:**
1. Check that GDCubism plugin loaded successfully (see console)
2. Verify `Scyka.model3.json` and `.moc3` files exist
3. Check Godot console for model loading errors
4. Ensure all texture files are present in `Scyka.4096/` folder

### Build Errors (When Building from Source)

**Symptoms:** SCons build fails

**Solutions:**
1. Install SCons: `pip install scons`
2. Initialize submodules: `git submodule update --init --recursive`
3. Install C++ compiler:
   - Linux: `sudo apt install build-essential`
   - Windows: Install Visual Studio Build Tools
   - macOS: Install Xcode Command Line Tools
4. Check that godot-cpp submodule is properly initialized

## License Information

### Live2D Cubism SDK

The Live2D Cubism SDK has specific licensing terms:

- **Free License:** Small-scale applications and personal projects
- **Indie License:** Indie developers (annual revenue < $10M USD)
- **Commercial License:** Larger commercial projects

**Important:** Review Live2D license terms before distribution:
https://www.live2d.com/en/download/cubism-sdk/

### GDCubism Plugin

GDCubism is an unofficial community plugin. See the official repository for license details.

## Resources

### Official Links

- **GDCubism GitHub:** https://github.com/MizunagiKB/gd_cubism
- **GDCubism Documentation:** https://mizunagikb.github.io/gd_cubism/
- **Live2D Cubism:** https://www.live2d.com/
- **Godot Engine:** https://godotengine.org/

### Getting Help

1. Check this guide first
2. Review GDCubism documentation
3. Check Godot console for error messages
4. Search GDCubism GitHub issues
5. Create a new issue if needed

---

**Version:** 2.0
**Date:** 2025-10-28
**Status:** Plugin structure installed, binaries required
