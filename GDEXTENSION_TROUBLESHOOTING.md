# GDExtension Troubleshooting Guide

This document explains the GDExtension errors encountered and how they were resolved.

## Issues Detected

### 1. Missing Dynamic Library Files

**Error:**
```
ERROR: platform/windows/os_windows.cpp:475 - Condition "!FileAccess::exists(path)" is true. Returning: ERR_FILE_NOT_FOUND
ERROR: GDExtension dynamic library not found: 'res://gd_cubism/gd_cubism.gdextension'.
```

**Root Cause:**
The compiled library files (`.dll`, `.so`, `.dylib`) are missing from `gd_cubism/bin/` directory. These files are gitignored (see `gd_cubism/bin/.gitignore`) and must be built or downloaded.

**Solution:**
1. **Option A - Build from source:**
   - Navigate to `gd_cubism-0.9.1/`
   - Follow the build instructions for your platform
   - Copy the built libraries to `gd_cubism/bin/`

2. **Option B - Download precompiled binaries:**
   - Download the appropriate binaries for your platform from the gd_cubism releases
   - Place them in `gd_cubism/bin/`

3. **Expected library files:**
   - Windows: `libgd_cubism.windows.debug.x86_64.dll` and `libgd_cubism.windows.release.x86_64.dll`
   - Linux: `libgd_cubism.linux.debug.x86_64.so` and `libgd_cubism.linux.release.x86_64.so`
   - macOS: `libgd_cubism.macos.debug.framework` and `libgd_cubism.macos.release.framework`

### 2. Nested project.godot Warning

**Warning:**
```
WARNING: editor/file_system/editor_file_system.cpp:3446 - Detected another project.godot at res://gd_cubism-0.9.1/demo. The folder will be ignored.
```

**Root Cause:**
The demo folder inside `gd_cubism-0.9.1` contains its own `project.godot` file, which Godot detects as a nested project.

**Solution:**
The file has been renamed from `project.godot` to `project.godot.disabled`:
```bash
mv gd_cubism-0.9.1/demo/project.godot gd_cubism-0.9.1/demo/project.godot.disabled
```

This prevents the warning while preserving the demo configuration for reference.

## GDExtension Error Detection System

A comprehensive error detection system has been created to proactively identify and diagnose GDExtension issues.

### Features

1. **Automatic Scanning**
   - Scans for missing library files
   - Validates GDExtension configuration files
   - Checks platform compatibility
   - Detects nested project warnings
   - Verifies file permissions

2. **Error Types Detected**
   - `LIBRARY_NOT_FOUND` - Dynamic library files missing
   - `GDEXTENSION_NOT_FOUND` - .gdextension file not found
   - `CONFIGURATION_ERROR` - Invalid configuration
   - `SYMBOL_NOT_FOUND` - Missing entry symbol
   - `WRONG_GODOT_VERSION` - Version incompatibility
   - `PLATFORM_MISMATCH` - No library for current platform
   - `NESTED_PROJECT_WARNING` - Nested project.godot detected
   - `PLUGIN_LOAD_FAILED` - Plugin loading failed
   - `MISSING_DEPENDENCIES` - Missing required dependencies
   - `PERMISSION_ERROR` - File permission issues

3. **Usage**

The detector runs automatically on startup and can be accessed via:

```gdscript
# Manual scan
GDExtensionErrorDetector.scan_for_issues()

# Get error summary
GDExtensionErrorDetector.print_summary()

# Export errors to file
GDExtensionErrorDetector.export_errors_to_file()

# Log custom errors
GDExtensionErrorDetector.log_library_not_found(
    "bin/libgd_cubism.windows.debug.x86_64.dll",
    "res://gd_cubism/gd_cubism.gdextension"
)
```

4. **Debug Hotkeys**
   - **F8** - Rescan for issues
   - **F9** - Print error summary
   - **F10** - Export errors to file
   - **F11** - Clear error log

### Suggested Fixes

Each error includes a suggested fix in the output. For example:

```
🔍 GDEXTENSION ERROR [LIBRARY_NOT_FOUND]
Message: Dynamic library file not found: bin/libgd_cubism.windows.debug.x86_64.dll
Context: {"library_path": "...", "platform": "windows"}
💡 Suggested Fix: Build the GDExtension library or check if it's excluded by .gitignore. Run the build process for the extension.
```

## Additional Error Detectors

The project also includes:

1. **AnimationErrorDetector** (`scripts/animation_error_detector.gd`)
   - Tracks animation loading and playback errors
   - Monitors Live2D-specific issues
   - Provides detailed error logs with stack traces

2. **GDExtensionErrorDetector** (`scripts/gdextension_error_detector.gd`) *(New)*
   - Monitors GDExtension loading and configuration
   - Validates library files and dependencies
   - Provides platform-specific guidance

## Next Steps

1. **Build or obtain the missing library files** for your platform
2. **Run the project** and check the console for any remaining errors
3. **Use F8** to rescan after adding libraries
4. **Use F9** to check the error summary at any time

## References

- [gd_cubism GitHub Repository](https://github.com/MizunagiKB/gd_cubism)
- [Godot GDExtension Documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/index.html)
