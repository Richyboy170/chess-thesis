# Quick Fix: GDCubism Error

## The Error You're Seeing

```
ERROR: platform/windows/os_windows.cpp:475 - Condition "!FileAccess::exists(path)" is true. Returning: ERR_FILE_NOT_FOUND
ERROR: GDExtension dynamic library not found: 'res://addons/gd_cubism/gd_cubism.gdextension'.
```

## What This Means

This error appears because the **GDCubism plugin binaries are missing**. The plugin structure is installed, but the actual compiled library files (`.dll`, `.so`, `.framework`) are not present in `addons/gd_cubism/bin/`.

## Good News: Your Project Will Still Work!

**The application has a built-in fallback mechanism:**
- Character 4 (Scyka) will display as a **static image** instead of an animated Live2D model
- All other functionality works normally
- You can play the chess game without any issues

## Three Options to Fix This

### Option 1: Ignore the Error (Recommended for Now)
- The error is non-critical
- Your project runs fine with Character 4 showing as a static preview
- Continue development and add Live2D later when needed

### Option 2: Remove Character 4 Temporarily
If the error message bothers you:

1. Open Godot project settings
2. Navigate to the character selection scene
3. Hide or remove the Character 4 button
4. The error will disappear

### Option 3: Install GDCubism Binaries (For Full Live2D Support)

This requires downloading the Cubism SDK and building from source.

**Quick Steps:**
1. Download Cubism SDK from: https://www.live2d.com/download/cubism-sdk/
   - You'll need to create a free Live2D account
   - Download "Cubism SDK for Native"
   - Version 5-r.1 or later recommended

2. Extract and build GDCubism:
   ```bash
   # Install build tools (if not already installed)
   pip3 install scons

   # Clone GDCubism
   cd /tmp
   git clone --branch v0.9.1 https://github.com/MizunagiKB/gd_cubism.git
   cd gd_cubism

   # Initialize submodules
   git submodule update --init --recursive

   # Extract Cubism SDK to thirdparty directory
   # (Unzip your downloaded CubismSdkForNative-*.zip here)
   unzip ~/Downloads/CubismSdkForNative-*.zip -d thirdparty/

   # Build for your platform
   scons platform=linux target=template_release    # Linux
   scons platform=linux target=template_debug
   # OR
   scons platform=windows target=template_release  # Windows
   scons platform=windows target=template_debug
   # OR
   scons platform=macos target=template_release    # macOS
   scons platform=macos target=template_debug

   # Copy binaries to your project
   cp bin/*.so /path/to/chess-thesis/addons/gd_cubism/bin/     # Linux
   # OR
   cp bin/*.dll /path/to/chess-thesis/addons/gd_cubism/bin/    # Windows
   # OR
   cp -r bin/*.framework /path/to/chess-thesis/addons/gd_cubism/bin/  # macOS
   ```

3. Restart Godot and the error should be gone with full Live2D support

## Understanding the Error

**Why don't the binaries come with the project?**
- Binary files are platform-specific (Linux/Windows/macOS)
- They're large files (several MB each)
- They require the proprietary Cubism SDK to build
- Git best practice is to not commit compiled binaries

**Why is the plugin included if it doesn't work?**
- The plugin structure is needed for the fallback to work correctly
- It allows the project to detect when Live2D becomes available
- It makes it easy to enable Live2D later by just adding the binaries

## Technical Details

The code in `scripts/character_selection.gd` (line 474) checks:
```gdscript
if ClassDB.class_exists("GDCubismUserModel") and FileAccess.file_exists(model_path):
    # Load Live2D model
else:
    # Fall back to texture preview
```

This means:
- ✅ Project loads successfully
- ✅ Character selection works
- ✅ Character 4 button works (shows static image)
- ❌ Live2D animation disabled (until binaries installed)

## Recommended Action

For most users: **Ignore the error and continue development**

The error message is informational and doesn't prevent your project from working. When you're ready to add full Live2D support, follow Option 3 above or see `LIVE2D_SETUP.md` for detailed instructions.

## Need Help?

- Full setup guide: See `LIVE2D_SETUP.md`
- GDCubism documentation: https://mizunagikb.github.io/gd_cubism/
- Live2D Cubism SDK: https://www.live2d.com/download/cubism-sdk/
- GDCubism GitHub: https://github.com/MizunagiKB/gd_cubism

---

**Status:** This is expected behavior when GDCubism binaries are not installed.
**Impact:** Low - Project works with static character preview fallback.
**Date:** 2025-10-28
