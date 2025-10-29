# GDCubism Binary Libraries Missing

## Issue

The gd_cubism GDExtension is currently missing its compiled binary libraries. These are required for the extension to work properly.

## Error Symptoms

You may see errors like:
- `ERROR: GDExtension dynamic library not found: 'res://addons/gd_cubism/gd_cubism.gdextension'`
- `Parse Error: Could not find type "GDCubismUserModel" in the current scope`
- `Parse Error: Could not find type "GDCubismEffectCustom" in the current scope`

## Solution

You have two options to get the required binaries:

### Option 1: Download Pre-built Binaries (Recommended)

1. Go to the gd_cubism releases page: https://github.com/MizunagiKB/gd_cubism/releases
2. Download the latest release for your platform
3. Extract the contents and copy the binary files from the `bin/` directory to `addons/gd_cubism/bin/`

Required files for Windows:
- `bin/libgd_cubism.windows.debug.x86_64.dll`
- `bin/libgd_cubism.windows.release.x86_64.dll`

Required files for Linux:
- `bin/libgd_cubism.linux.debug.x86_64.so`
- `bin/libgd_cubism.linux.release.x86_64.so`

Required files for macOS:
- `bin/libgd_cubism.macos.debug.framework`
- `bin/libgd_cubism.macos.release.framework`

### Option 2: Build from Source

The source code is available in `addons/gd_cubism-0.9.1/`. Follow the build instructions at:
https://mizunagikb.github.io/gd_cubism/gd_cubism/0.6/en/build.html

Build using SCons:
```bash
cd addons/gd_cubism-0.9.1
scons
```

After building, copy the generated binaries to `addons/gd_cubism/bin/`.

## After Installing Binaries

1. Restart Godot Editor
2. The GDCubism types (GDCubismUserModel, GDCubismEffectCustom, etc.) should now be available
3. All parse errors should be resolved

## Notes

- The binary files are ignored by git (see `addons/gd_cubism/bin/.gitignore`)
- You need to install binaries for your development platform
- For deployment, include binaries for all target platforms
