# Live2D Model Test Sandbox

A simple sandbox environment for testing Live2D models with the GDCubism plugin, without any game logic.

## Purpose

This sandbox allows you to:
- Verify that the GDCubism plugin is working correctly
- Test Live2D model loading and display
- Switch between different characters
- Test animations without running the full game

## Prerequisites

**IMPORTANT**: Before using this sandbox, you must install the GDCubism plugin binaries.

If you get a `GDEXTENSION_NOT_FOUND` error, see **[GDCUBISM_SETUP.md](../../GDCUBISM_SETUP.md)** for detailed setup instructions.

## How to Use

1. Open the project in Godot 4.x
2. Navigate to `scenes/sandbox/model_test.tscn`
3. Run the scene (F6 or click the "Run Current Scene" button)

## Features

### Character Selection
- **Scyka (3)** - Character 3 model
- **Hiyori (4)** - Character 4 model
- **Mark (5)** - Character 5 model

Click any character button to load and display that model.

### Animation Testing
- **Idle** - Play the default idle animation
- **Piece Captured** - Play the piece captured reaction
- **Check** - Play the check reaction

### Status Display
The sandbox shows:
- Current character name and ID
- Loading status (success/error messages)
- Console output with detailed debug information

## Troubleshooting

### GDEXTENSION_NOT_FOUND Error
This means the GDCubism compiled libraries are missing. See **[GDCUBISM_SETUP.md](../../GDCUBISM_SETUP.md)** for complete setup instructions.

Quick fix:
1. Download GDCubism binaries from https://github.com/MizunagiKB/gd_cubism/releases
2. Extract and copy the `bin/` contents to `addons/gd_cubism/bin/`
3. Restart Godot Editor

### "GDCubism plugin not loaded" Error
- Make sure the GDCubism plugin is properly installed in the `addons/` folder
- Check that the plugin is enabled in Project Settings → Plugins
- Verify the compiled libraries are in `addons/gd_cubism/bin/`

### "Model file not found" Error
- Verify that the character models exist in `assets/characters/character_X/`
- Check that the `.model3.json` files are present

### Model Loads but Doesn't Display
- Check the console output for errors
- Verify that the model files and textures are intact
- Try increasing the ModelContainer size in the scene

## Files

- `scenes/sandbox/model_test.tscn` - The sandbox scene
- `scripts/model_test.gd` - The sandbox script with model loading logic

## Dependencies

This sandbox uses:
- `Live2DDebugger` (scripts/live2d_debugger.gd) - For getting model paths
- `Live2DAnimationConfig` (scripts/live2d_animation_config.gd) - For animation playback
- GDCubism plugin - For Live2D model rendering
