# GDCubism Plugin Setup Instructions

## Problem

The GDCubism plugin is configured but the compiled library files are missing, causing the `GDEXTENSION_NOT_FOUND` error.

## Solution

You need to download the precompiled GDCubism binaries or compile them yourself.

### Option 1: Download Precompiled Binaries (Recommended)

1. Go to the GDCubism releases page:
   https://github.com/MizunagiKB/gd_cubism/releases

2. Download the latest release for Godot 4.x (look for version compatible with Godot 4.3+)

3. Extract the downloaded archive

4. Copy the library files from the `bin/` folder in the archive to:
   ```
   /home/user/chess-thesis/addons/gd_cubism/bin/
   ```

5. Make sure the following files are present (depending on your platform):
   - **Linux**: `libgd_cubism.linux.debug.x86_64.so` and `libgd_cubism.linux.release.x86_64.so`
   - **Windows**: `libgd_cubism.windows.debug.x86_64.dll` and `libgd_cubism.windows.release.x86_64.dll`
   - **macOS**: `libgd_cubism.macos.debug.framework` and `libgd_cubism.macos.release.framework`

### Option 2: Compile from Source

If precompiled binaries aren't available for your platform:

1. Clone the GDCubism repository:
   ```bash
   git clone https://github.com/MizunagiKB/gd_cubism.git
   ```

2. Follow the build instructions in the repository's README

3. Copy the compiled library files to:
   ```
   /home/user/chess-thesis/addons/gd_cubism/bin/
   ```

## Verification

After installing the binaries:

1. Open the project in Godot Editor
2. Go to **Project → Project Settings → Plugins**
3. Verify that "GDCubism" appears in the list and is enabled
4. Run the test sandbox: `scenes/sandbox/model_test.tscn` (F6)
5. You should see "Model loaded successfully!" in green

## Current Plugin Structure

```
addons/gd_cubism/
├── bin/                          # ← Library files go here
│   ├── libgd_cubism.linux.debug.x86_64.so
│   ├── libgd_cubism.linux.release.x86_64.so
│   └── ... (other platform binaries)
├── gd_cubism.gdextension        # Extension configuration
├── plugin.cfg                    # Plugin metadata
└── plugin.gd                     # Plugin script
```

## Troubleshooting

### Still Getting GDEXTENSION_NOT_FOUND?

1. **Check file permissions**: Ensure the `.so`/`.dll` files are executable
   ```bash
   chmod +x addons/gd_cubism/bin/*.so
   ```

2. **Check Godot version**: GDCubism requires Godot 4.3 or higher
   - Current project is configured for Godot 4.5

3. **Reload the project**: Close and reopen Godot Editor after adding binaries

4. **Check the console**: Look for more specific error messages in the Godot console

### Missing Dependencies on Linux

If you get "shared library not found" errors on Linux:

```bash
# Install required libraries
sudo apt-get install libstdc++6 libgcc1
```

## Additional Resources

- **GDCubism GitHub**: https://github.com/MizunagiKB/gd_cubism
- **Live2D Cubism SDK**: https://www.live2d.com/en/download/cubism-sdk/
- **Godot GDExtension Docs**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/what_is_gdextension.html

## Quick Test

After setup, test the plugin with:

```bash
# In Godot Editor
# 1. Open scenes/sandbox/model_test.tscn
# 2. Press F6 to run
# 3. Check for "Model loaded successfully!" message
```

If you see the Live2D character displayed, the plugin is working correctly!
