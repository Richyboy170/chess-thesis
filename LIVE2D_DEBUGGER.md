# Live2D Character Debugger

## Overview

The Live2D Character Debugger is a comprehensive debugging tool designed to help identify and fix issues with Live2D characters not appearing in the Main Game. This system provides detailed diagnostics, error reporting, and visual debugging tools.

## Problem Solved

Previously, Live2D characters (Characters 4, 5, and 6) were not displayed in the Main Game because the `load_character_media` function only supported video and image files. The debugger helps identify issues and the updated code now properly loads Live2D models using the GDCubism plugin.

## Features

### 1. Comprehensive Diagnostic Checks

The debugger performs the following checks for each Live2D character:

- ✓ **Plugin Availability**: Verifies GDCubism plugin is loaded
- ✓ **Model File Existence**: Checks if `.model3.json` files exist
- ✓ **Model Loading**: Attempts to load the model file as a resource
- ✓ **Texture Files**: Verifies texture directory and files exist
- ✓ **Instantiation**: Tests creating a GDCubismUserModel instance
- ✓ **Asset Assignment**: Validates model assets can be assigned

### 2. In-Game Debug Panel

Press **'L'** in the Main Game to toggle the Live2D debugger panel.

The panel provides:
- Quick access to debug individual characters
- Real-time status of current game characters
- Visual feedback on which characters are Live2D
- One-click debugging for all Live2D characters

### 3. Detailed Console Reports

Each debug check generates a detailed report including:
- Character information (ID, name, folder)
- Step-by-step diagnostic results
- Clear error messages and solutions
- Success/failure status for each check

### 4. Character Mappings

The system correctly maps character IDs to Live2D models:

| Character ID | Character # | Model Name | Texture Directory |
|--------------|-------------|------------|-------------------|
| 3            | 4           | Scyka      | Scyka.4096        |
| 4            | 5           | Hiyori     | Hiyori.2048       |
| 5            | 6           | Mark       | Mark.2048         |

## Usage

### In-Game Debugging

1. Start a game with Live2D characters (Characters 4, 5, or 6)
2. Press **'L'** to open the Live2D debugger panel
3. Click on individual character buttons to debug specific characters
4. Check the console output for detailed diagnostic reports

### Keyboard Shortcuts

- **L**: Toggle Live2D debugger panel
- **D**: Toggle character animation debugger (existing)
- **F9**: Toggle animation error viewer (existing)

### Programmatic Usage

You can also use the debugger programmatically:

```gdscript
# Check if a character is Live2D
if Live2DDebugger.is_live2d_character(character_id):
    print("This is a Live2D character!")

# Run diagnostic check
var report = Live2DDebugger.debug_character(character_id)
print(report.to_string())

# Quick status check
var status = Live2DDebugger.get_status_message(character_id)
print("Status: ", status)

# Debug all Live2D characters
print(Live2DDebugger.debug_all_characters())
```

## Files Added/Modified

### New Files

1. **`scripts/live2d_debugger.gd`** - Core debugger implementation
   - `Live2DDebugger` class with static methods
   - `DebugReport` class for structured error reporting
   - Debug panel creation and management
   - Character validation functions

### Modified Files

1. **`scripts/main_game.gd`**
   - Added `load_live2d_character()` function to load Live2D models
   - Modified `load_character_media()` to detect and handle Live2D characters
   - Updated `load_character_assets()` to pass character IDs
   - Added Live2D debugger panel integration
   - Added keyboard shortcut ('L') for debug panel toggle

## How It Works

### Character Loading Flow

1. **Detection**: `load_character_media()` checks if character ID is 3, 4, or 5
2. **Debug Check**: Runs comprehensive diagnostics via `Live2DDebugger.debug_character()`
3. **Loading**: If checks pass, creates GDCubismUserModel instance
4. **Configuration**: Sets up sizing, positioning, and auto-scale
5. **Animation**: Starts idle animation if available
6. **Fallback**: If Live2D fails, falls back to video/image loading

### Error Detection

The debugger can identify common issues:

- **Plugin Not Loaded**: GDCubism plugin not enabled in Project Settings
- **Missing Model Files**: `.model3.json` files not found in character folders
- **Texture Issues**: Missing or incorrectly named texture files
- **Load Failures**: Model files exist but fail to load as resources
- **Instantiation Errors**: Failed to create GDCubismUserModel instances

## Example Debug Output

```
═════════════════════════════════════════════════════════════════════════════════
  LIVE2D CHARACTER DEBUG REPORT
═════════════════════════════════════════════════════════════════════════════════

Character: Hiyori (ID: 4)
Status: ✓ SUCCESS
────────────────────────────────────────────────────────────────────────────────

ℹ INFO:
  • Character folder: res://assets/characters/character_5/
  • Checking GDCubism plugin availability...
  • ✓ GDCubism plugin is loaded (GDCubismUserModel class available)
  • Checking model file: res://assets/characters/character_5/Hiyori.model3.json
  • ✓ Model file exists
  • Attempting to load model file...
  • ✓ Model file can be loaded as resource
  • Checking texture directory: res://assets/characters/character_5/Hiyori.2048/
  • ✓ Texture directory exists
  • ✓ Primary texture found: texture_00.png
  • Found 3 texture file(s) in directory
  • Attempting to instantiate GDCubismUserModel...
  • ✓ Successfully instantiated GDCubismUserModel
  • Attempting to assign model assets...
  • ✓ Model assets assigned
  •
✓✓✓ All checks passed! Character should load correctly. ✓✓✓

═════════════════════════════════════════════════════════════════════════════════
```

## Troubleshooting

### Plugin Not Loaded

**Error**: "GDCubism plugin is NOT loaded!"

**Solution**:
1. Go to **Project → Project Settings → Plugins**
2. Enable the **GDCubism** plugin
3. Restart Godot
4. See `LIVE2D_SETUP.md` for detailed setup instructions

### Model File Missing

**Error**: "Model file NOT FOUND"

**Solution**:
1. Check the character folder exists: `res://assets/characters/character_X/`
2. Verify the `.model3.json` file is present
3. Ensure the filename matches the character name (e.g., `Hiyori.model3.json`)

### Texture Files Missing

**Error**: "Texture directory NOT FOUND" or "Primary texture not found"

**Solution**:
1. Verify the texture directory exists (e.g., `Hiyori.2048/`)
2. Check for `texture_00.png` in the texture directory
3. Ensure texture files were exported with the Live2D model

### Load Failed

**Error**: "Failed to load model file as resource"

**Solution**:
1. Check the `.model3.json` file is valid JSON
2. Verify all referenced files in the model exist
3. Try reimporting the model in Godot
4. Check console for additional error messages

## Integration with Existing Systems

The Live2D debugger integrates seamlessly with existing debugging tools:

- **Animation Error Detector**: Logs Live2D loading errors automatically
- **Character Animation Debugger**: Works alongside the existing 'D' key debugger
- **Animation Error Viewer**: Live2D errors appear in the F9 error viewer

## Performance Notes

- Debug checks are only run when explicitly requested or when loading characters
- The debug panel has minimal performance impact when hidden
- Diagnostic functions use efficient file checks and caching

## Future Enhancements

Potential improvements for future versions:

- [ ] Real-time Live2D parameter monitoring
- [ ] Animation state visualization
- [ ] Model performance metrics (FPS, draw calls)
- [ ] Expression and motion testing UI
- [ ] Automatic fix suggestions
- [ ] Export debug reports to file

## Credits

This debugger was created to solve the issue of Live2D characters not appearing in the Main Game. It provides comprehensive diagnostics to help developers quickly identify and resolve Live2D integration issues.

## See Also

- `LIVE2D_SETUP.md` - Instructions for setting up the GDCubism plugin
- `ANIMATION_ERROR_DETECTOR.md` - General animation error detection system
- `scripts/live2d_debugger.gd` - Complete debugger implementation
- `scripts/main_game.gd` - Main game with Live2D integration
