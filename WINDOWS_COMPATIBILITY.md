# Windows Compatibility Guide

## GDCubism GDExtension on Windows

### Issue
The GDCubism extension currently only has compiled libraries for Linux (`x86_64`). When running Godot on Windows, you'll see this error:

```
ERROR: No GDExtension library found for current OS and architecture (windows.x86_64)
```

### Solutions

#### Option 1: Use WSL (Recommended for Windows users)
1. Install [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install)
2. Install Godot in your WSL environment
3. Run the project from WSL

#### Option 2: Build Windows Libraries
To compile the Windows libraries yourself:

1. Download the [Cubism SDK for Native](https://www.live2d.com/en/download/cubism-sdk/)
2. Follow the build instructions in the GDCubism repository
3. Place the compiled `.dll` files in `addons/gd_cubism/bin/`
4. Uncomment the Windows library paths in `addons/gd_cubism/gd_cubism.gdextension`:
   ```
   windows.debug.x86_64 = "bin/libgd_cubism.windows.debug.x86_64.dll"
   windows.release.x86_64 = "bin/libgd_cubism.windows.release.x86_64.dll"
   ```

#### Option 3: Run on Linux
The project works out-of-the-box on Linux systems with the pre-compiled libraries.

## Current Status
- ✅ Linux x86_64: Fully supported
- ⚠️ Windows x86_64: Requires manual compilation or WSL
- ❌ macOS: Not currently configured (libraries commented out)
