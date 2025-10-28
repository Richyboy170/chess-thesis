# Animation Error Detection System

This document describes the Animation Error Detection System integrated into the chess game. This system captures, logs, and reports all animation-related errors to help with debugging and troubleshooting.

## Overview

The Animation Error Detection System consists of three main components:

1. **AnimationErrorDetector** (Singleton) - Core error logging and management system
2. **AnimationErrorViewer** - Debug UI panel for viewing errors in real-time
3. **Integration Points** - Error detection integrated into all animation systems

## Quick Start

### Viewing Errors During Gameplay

Press **F9** during gameplay to toggle the Animation Error Viewer panel. This will show:
- Total error count
- Errors categorized by type
- Detailed error messages with context
- Recent error history

### Exporting Errors

You have two options to export errors:

1. **During Gameplay**: Press **F10** to export errors immediately
2. **Programmatically**: Call `AnimationErrorDetector.export_errors_to_file()`

Exported files:
- `user://animation_errors.log` - Human-readable text format
- `user://animation_errors.json` - Machine-readable JSON format

### Clearing Errors

- Press **F11** during gameplay to clear all logged errors
- Or call `AnimationErrorDetector.clear_errors()`

## Error Types

The system detects and categorizes the following error types:

| Error Type | Description | Icon |
|------------|-------------|------|
| `FILE_NOT_FOUND` | Animation file doesn't exist | 📁❌ |
| `LOAD_FAILED` | File exists but failed to load | ⚠️ |
| `PLUGIN_MISSING` | Required plugin not available (e.g., GDCubism) | 🔌❌ |
| `INVALID_RESOURCE` | Resource loaded but is invalid/corrupt | 🚫 |
| `PLAYBACK_FAILED` | Animation couldn't be played | ▶️❌ |
| `CONFIGURATION_ERROR` | Character configuration issue | ⚙️❌ |
| `LIVE2D_ERROR` | Live2D model loading/playback error | 🎭❌ |
| `UNKNOWN` | Unclassified error | ❓ |

## Integration Points

The error detection system is integrated into the following animation systems:

### 1. Piece Effects System (`piece_effects.gd`)

Detects errors when:
- Loading character-specific effect configurations
- Loading held piece images
- Applying visual effects to pieces

**Example errors caught:**
- Missing piece effect configuration files
- Missing held piece textures
- Failed texture loads

### 2. Character Selection (`character_selection.gd`)

Detects errors when:
- Loading character preview videos
- Loading character background images
- Loading Live2D models (Character 4)
- Loading fallback textures

**Example errors caught:**
- Missing character idle animation videos
- Missing background images
- GDCubism plugin not installed
- Missing Live2D model files
- Failed texture/video loads

### 3. Main Game (`main_game.gd`)

Detects errors when:
- Loading character idle animations
- Loading special animations (victory/defeat/capture)
- Playing special animations

**Example errors caught:**
- Missing character idle animations
- Failed video/GIF loads
- Missing special animations
- Special animation playback failures

## Using the AnimationErrorDetector API

### Logging Errors

The AnimationErrorDetector provides several convenient methods for logging errors:

```gdscript
# Generic error logging
AnimationErrorDetector.log_error(
    AnimationErrorDetector.ErrorType.LOAD_FAILED,
    "Failed to load animation",
    {"file_path": "path/to/file.ogv"}
)

# Specialized logging functions
AnimationErrorDetector.log_file_not_found(
    "res://path/to/missing_file.ogv",
    "res://path/to/expected_location/"
)

AnimationErrorDetector.log_load_failed(
    "res://path/to/file.ogv",
    "Character idle animation"
)

AnimationErrorDetector.log_plugin_missing(
    "GDCubism",
    "Live2D character animation"
)

AnimationErrorDetector.log_playback_failed(
    "character_victory",
    "Player1Display"
)

AnimationErrorDetector.log_live2d_error(
    "res://assets/characters/character_4/Scyka.model3.json",
    "Failed to initialize model"
)

AnimationErrorDetector.log_config_error(
    4,  # character_id
    "Missing piece effects configuration"
)
```

### Querying Errors

```gdscript
# Get total error count
var count = AnimationErrorDetector.get_error_count()

# Get errors by type
var load_errors = AnimationErrorDetector.get_errors_by_type(
    AnimationErrorDetector.ErrorType.LOAD_FAILED
)

# Get recent errors
var recent = AnimationErrorDetector.get_recent_errors(10)

# Check if there are any errors
if AnimationErrorDetector.has_errors():
    print("There are animation errors!")

# Check for critical errors
if AnimationErrorDetector.has_critical_errors():
    print("Critical errors detected!")
```

### Getting Reports

```gdscript
# Get a summary of all errors
var summary = AnimationErrorDetector.get_error_summary()
print(summary)

# Get a detailed report
var report = AnimationErrorDetector.get_detailed_report()
print(report)
```

### Exporting Errors

```gdscript
# Export to default location (user://animation_errors.log)
AnimationErrorDetector.export_errors_to_file()

# Export to custom location
AnimationErrorDetector.export_errors_to_file("user://my_custom_errors.log")

# Export as JSON
AnimationErrorDetector.export_errors_as_json()
AnimationErrorDetector.export_errors_as_json("user://custom_errors.json")
```

## Signals

The AnimationErrorDetector emits signals you can connect to:

```gdscript
# Emitted when a new error is logged
AnimationErrorDetector.error_logged.connect(func(error):
    print("New error logged: ", error.message)
)

# Emitted when critical error count is reached (default: 50)
AnimationErrorDetector.critical_error_count_reached.connect(func(count):
    push_warning("Critical error count reached: %d" % count)
    # Automatically show error viewer
    toggle_error_viewer()
)
```

## Error Data Structure

Each error contains the following information:

```gdscript
{
    "timestamp": "2025-10-28T12:34:56",  # When the error occurred
    "error_type": "LOAD_FAILED",          # Type of error
    "message": "Failed to load video",     # Human-readable message
    "context": {                           # Additional context
        "file_path": "res://path/to/file.ogv",
        "resource_type": "VideoStream"
    },
    "stack_trace": [...]                   # Stack trace at error time
}
```

## Configuration

### Auto-Save Settings

By default, errors are automatically saved to a log file. You can configure this:

```gdscript
# Disable auto-save
AnimationErrorDetector.auto_save_enabled = false

# Change log file path
AnimationErrorDetector.error_log_path = "user://my_custom_log.log"

# Set maximum error storage (default: 1000)
AnimationErrorDetector.max_errors = 500
```

## Hotkeys Reference

| Key | Action |
|-----|--------|
| **F9** | Toggle Animation Error Viewer |
| **F10** | Export errors to file |
| **F11** | Clear all logged errors |
| **D** | Toggle Animation Debugger (separate tool) |

## Best Practices

### For Developers

1. **Always log animation errors** - Use the appropriate logging function whenever an animation operation fails
2. **Provide context** - Include relevant information like file paths, character IDs, etc.
3. **Check for errors during development** - Press F9 regularly to check for errors
4. **Export and share errors** - When reporting bugs, export errors and include the JSON file

### For Testers

1. **Enable error viewer at start** - Press F9 when the game starts
2. **Test all characters** - Ensure you test all character combinations
3. **Export errors before closing** - Press F10 to export errors before exiting
4. **Clear errors between tests** - Press F11 to start fresh for each test session

### For Users

If you encounter visual glitches or missing animations:

1. Press **F9** to open the error viewer
2. Check if there are any errors listed
3. Press **F10** to export the errors
4. Share the exported files with the developer:
   - Find files at: `user://animation_errors.log` and `user://animation_errors.json`
   - On Windows: `%APPDATA%/Godot/app_userdata/Chess Thesis/`
   - On Linux: `~/.local/share/godot/app_userdata/Chess Thesis/`
   - On macOS: `~/Library/Application Support/Godot/app_userdata/Chess Thesis/`

## Troubleshooting

### Error Viewer Not Showing

- Make sure you're in the Main Game scene (not character selection)
- Try pressing F9 multiple times
- Check console output for "Animation Error Viewer created" message

### Errors Not Being Logged

- Verify AnimationErrorDetector is in autoload (Project Settings → Autoload)
- Check console for initialization message: "🔍 AnimationErrorDetector initialized"
- Ensure error logging calls are placed in try/catch or after null checks

### Export Files Not Found

- Check the console for export success messages
- Navigate to the correct user data directory for your OS (see above)
- Verify write permissions for the user data directory

## Technical Details

### Autoload Configuration

The AnimationErrorDetector is configured as an autoload singleton in `project.godot`:

```ini
[autoload]
AnimationErrorDetector="*res://scripts/animation_error_detector.gd"
```

This ensures it's available globally and persists across scene changes.

### Performance Considerations

- Error logging is lightweight and has minimal performance impact
- Maximum error limit (default 1000) prevents memory issues
- Auto-save appends to file incrementally
- Error viewer is created once and reused

### Thread Safety

The error detector is designed for single-threaded use (main thread only). If you need to log errors from other threads, use `call_deferred()`:

```gdscript
AnimationErrorDetector.call_deferred(
    "log_error",
    AnimationErrorDetector.ErrorType.LOAD_FAILED,
    "Error message",
    {}
)
```

## Future Enhancements

Planned improvements for the error detection system:

- [ ] Email/webhook notifications for critical errors
- [ ] Error statistics dashboard
- [ ] Automatic error reporting to server
- [ ] Error filtering by severity
- [ ] Error search functionality
- [ ] Integration with issue tracking systems

## Support

For questions or issues with the Animation Error Detection System, please:

1. Check this documentation first
2. Review the console output
3. Export and review error logs
4. Contact the development team with exported error files

---

**Version**: 1.0
**Last Updated**: 2025-10-28
**Author**: Claude (with Animation Error Detection System)
