# Windows GDCubism Plugin Setup Guide

## The Problem You're Experiencing

You have `.a` files (static library archives) but Godot on Windows needs `.dll` files (dynamic link libraries).

**Wrong files (what you have):**
- `libgodot-cpp.windows.template_debug.x86_64.a`
- `libgodot-cpp.windows.template_release.x86_64.a`

**Correct files (what you need):**
- `libgd_cubism.windows.debug.x86_64.dll`
- `libgd_cubism.windows.release.x86_64.dll`

---

## Solution: Check Your Downloaded Files First

Since you have `C:\Rocky\chess-thesis\gd_cubism-0.9.1\` on your Windows machine, the DLL files might already be built there!

### Step 1: Check for Existing DLLs

1. Open File Explorer and navigate to:
   ```
   C:\Rocky\chess-thesis\gd_cubism-0.9.1\demo\addons\gd_cubism\bin\
   ```

2. Look for these files:
   - `libgd_cubism.windows.debug.x86_64.dll`
   - `libgd_cubism.windows.release.x86_64.dll`

3. **If you find them:**
   - Copy BOTH `.dll` files
   - Paste them into: `C:\Rocky\chess-thesis\gd_cubism\bin\`
   - Skip to "Verify Installation" section below
   - ✅ You're done!

4. **If they're NOT there:**
   - The binaries weren't built
   - Continue to Step 2 below

---

## If DLLs Don't Exist: Build Them

### Prerequisites

You need to install these on your Windows machine:

1. **Visual Studio Community 2019 or later**
   - Download: https://visualstudio.microsoft.com/vs/community/
   - ⚠️ IMPORTANT: During installation, check "Desktop development with C++"
   - This installs the C++ compiler needed for building

2. **Python 3.8 or later**
   - Download: https://www.python.org/downloads/windows/
   - During install, check "Add Python to PATH"

3. **SCons 4.7** (build system)
   - Open Command Prompt (Windows key + R, type `cmd`, press Enter)
   - Run: `pip install scons==4.7`
   - ⚠️ Use version 4.7 specifically (4.8 has known issues)

4. **Live2D Cubism SDK for Native**
   - Go to: https://www.live2d.com/download/cubism-sdk/
   - Create a free Live2D account if you don't have one
   - Download "Cubism SDK for Native" (Version 5-r.1 or later)
   - You'll get a file like: `CubismSdkForNative-5-r.1.zip`

### Build Process

1. **Extract Cubism SDK**

   Open Command Prompt and run:
   ```cmd
   cd C:\Rocky\chess-thesis\gd_cubism-0.9.1

   REM Extract the Cubism SDK you downloaded into the thirdparty folder
   REM Replace the path with where you downloaded it
   powershell Expand-Archive -Path "%USERPROFILE%\Downloads\CubismSdkForNative-5-r.1.zip" -DestinationPath "thirdparty\"
   ```

2. **Verify folder structure**

   Check that this path exists:
   ```
   C:\Rocky\chess-thesis\gd_cubism-0.9.1\thirdparty\CubismSdkForNative-5-r.1\Core
   ```

3. **Initialize submodules**

   ```cmd
   cd C:\Rocky\chess-thesis\gd_cubism-0.9.1
   git submodule update --init --recursive
   ```

4. **Build the DLLs**

   Open "Developer Command Prompt for VS" (search in Start Menu) and run:
   ```cmd
   cd C:\Rocky\chess-thesis\gd_cubism-0.9.1

   scons platform=windows arch=x86_64 target=template_debug
   scons platform=windows arch=x86_64 target=template_release
   ```

5. **Wait for build to complete**

   This will take 5-15 minutes. When done, you'll see the DLLs created in:
   ```
   C:\Rocky\chess-thesis\gd_cubism-0.9.1\demo\addons\gd_cubism\bin\
   ```

6. **Copy the DLLs to your project**

   ```cmd
   copy "C:\Rocky\chess-thesis\gd_cubism-0.9.1\demo\addons\gd_cubism\bin\*.dll" "C:\Rocky\chess-thesis\gd_cubism\bin\"
   ```

---

## Verify Installation

1. Open your project in Godot Engine

2. Check the Output/Console panel at the bottom

3. Look for GDCubism initialization messages (no errors)

4. Run the project (F5) and test Character 4 selection

5. If successful:
   - ✅ Character 4 will show animated Live2D model
   - ✅ No more "GDExtension dynamic library not found" errors

---

## Troubleshooting

### Build Error: "scons: command not found"

**Solution:** Python or SCons not in PATH
```cmd
REM Reinstall SCons
pip install --force-reinstall scons==4.7

REM Or specify full path
python -m pip install scons==4.7
```

### Build Error: "No C++ compiler found"

**Solution:** Visual Studio not installed correctly

1. Run Visual Studio Installer
2. Click "Modify" on your Visual Studio installation
3. Check "Desktop development with C++"
4. Click "Modify" to install

### Build Error: Can't find CubismSdk

**Solution:** Check folder structure

Make sure you have:
```
thirdparty\CubismSdkForNative-5-r.1\Core\
```

NOT:
```
thirdparty\Core\
```

### Error: "SCons 4.8 build failures"

**Solution:** Downgrade to SCons 4.7
```cmd
pip uninstall scons
pip install scons==4.7
```

---

## Alternative: Use Pre-built Binaries (If Available)

Sometimes the GDCubism releases include pre-built binaries. Check:

1. Go to: https://github.com/MizunagiKB/gd_cubism/releases
2. Look at the v0.9.1 release Assets section
3. If there's a release archive, download and extract it
4. Copy the DLLs from the extracted `demo/addons/gd_cubism/bin/` folder

**Note:** As of now, v0.9.1 does not include pre-built binaries, so building from source is required.

---

## Quick Reference

**Files you NEED (put in `C:\Rocky\chess-thesis\gd_cubism\bin\`):**
- ✅ `libgd_cubism.windows.debug.x86_64.dll`
- ✅ `libgd_cubism.windows.release.x86_64.dll`

**Files you DON'T need:**
- ❌ `*.a` files (static libraries)
- ❌ `libgodot-cpp.*` files (build dependencies, not runtime)

**Build command summary:**
```cmd
cd C:\Rocky\chess-thesis\gd_cubism-0.9.1
git submodule update --init --recursive
scons platform=windows arch=x86_64 target=template_debug
scons platform=windows arch=x86_64 target=template_release
copy demo\addons\gd_cubism\bin\*.dll C:\Rocky\chess-thesis\gd_cubism\bin\
```

---

## Need More Help?

- GDCubism Documentation: https://mizunagikb.github.io/gd_cubism/
- GDCubism GitHub: https://github.com/MizunagiKB/gd_cubism
- Live2D Cubism SDK: https://www.live2d.com/download/cubism-sdk/
- Visual Studio Downloads: https://visualstudio.microsoft.com/downloads/

**Status:** Setup guide for Windows users
**Date:** 2025-11-01
