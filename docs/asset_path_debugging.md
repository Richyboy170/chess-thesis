# Asset Path Debugging Guide

## Problem Description

The white_knight scene for character 4 (`hovereffect_scyka.tscn`) was using incorrect relative paths that referenced files from the project root instead of the correct location within the character's asset folder.

### The Bug

The `.tscn` file contained these incorrect paths:
```
path="res://eye.png"
path="res://purple piece.png"
path="res://ghost flip.png"
```

These paths were pointing to the project root (`res://`) instead of the actual location of the files in:
```
res://assets/characters/character_4/pieces/held/white_knight/
```

### Impact

This caused the following issues:
1. The white_knight scene would fail to load its textures
2. Missing texture errors would appear in the console
3. The piece would not render correctly in-game
4. The AnimatedSprite2D and GPUParticles2D nodes would be missing their required textures

## Solution

### 1. Fixed Paths in hovereffect_scyka.tscn

Updated the paths to absolute paths from the project root:

```diff
- [ext_resource type="Texture2D" uid="uid://bb8xqgf0rh6su" path="res://eye.png" id="1_waf30"]
- [ext_resource type="Texture2D" uid="uid://b54dg3ekb6m6s" path="res://purple piece.png" id="2_e6wfc"]
- [ext_resource type="Texture2D" uid="uid://b2kjwedurjnen" path="res://ghost flip.png" id="3_waf30"]
+ [ext_resource type="Texture2D" uid="uid://bb8xqgf0rh6su" path="res://assets/characters/character_4/pieces/held/white_knight/eye.png" id="1_waf30"]
+ [ext_resource type="Texture2D" uid="uid://b54dg3ekb6m6s" path="res://assets/characters/character_4/pieces/held/white_knight/purple piece.png" id="2_e6wfc"]
+ [ext_resource type="Texture2D" uid="uid://b2kjwedurjnen" path="res://assets/characters/character_4/pieces/held/white_knight/ghost flip.png" id="3_waf30"]
```

### 2. Enhanced Logging in chess_piece_sprite.gd

Added comprehensive debug logging to track all asset loading operations:

```gdscript
# Now logs:
# - Base paths being checked
# - Scene directory paths
# - Each scene file being tested
# - Success/failure of file existence checks
# - Texture loading status
# - PNG fallback behavior
```

This helps identify path resolution issues in real-time during gameplay.

### 3. Created Asset Path Bug Checker

A comprehensive debugging tool (`scripts/asset_path_bug_checker.gd`) that:

- ✓ Scans all .tscn files for broken asset references
- ✓ Checks for relative vs absolute path issues
- ✓ Validates file existence for all referenced assets
- ✓ Tests ChessPieceSprite path resolution
- ✓ Generates detailed JSON reports
- ✓ Suggests fixes for broken paths

## How to Use the Bug Checker

### Method 1: Run the Test Scene

Open and run the scene:
```
scenes/debug/asset_path_checker.tscn
```

This will automatically run all checks and output results to the console.

### Method 2: Run from Code

```gdscript
var issues = AssetPathBugChecker.run_check()
print("Found %d issues" % issues.size())
```

### Method 3: Add as Autoload

Add to `project.godot`:
```ini
[autoload]
AssetPathChecker="*res://scripts/asset_path_bug_checker.gd"
```

Then access from any script:
```gdscript
AssetPathChecker.check_white_knight_assets()
```

## Output

The bug checker produces:

1. **Console Output** - Color-coded results showing:
   - ✓ Green for successful checks
   - ✗ Red for failures
   - Yellow for warnings

2. **JSON Report** - Detailed report saved to:
   ```
   res://asset_path_bug_report.json
   ```

## Files Affected by White Knight Assets

The following files interact with the white_knight assets:

1. **`assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn`**
   - Main scene file for the white_knight hover effect
   - References: eye.png, purple piece.png, ghost flip.png
   - **FIXED**: Updated to use absolute paths

2. **`scripts/chess_piece_sprite.gd`**
   - Loads scene-based pieces using `find_piece_scene()`
   - Searches for .tscn files in the `/scene` subdirectory
   - **ENHANCED**: Added debug logging for all path operations

3. **`scripts/piece_effects_config.gd`**
   - Defines held piece image paths
   - Auto-generates paths based on character_id
   - Uses: `held_images_base_path + "white_knight.png"`

## Prevention

To prevent similar issues in the future:

1. **Always use absolute paths** starting with `res://` in .tscn files
2. **Run the bug checker** before committing scene changes
3. **Check console logs** for path resolution warnings
4. **Test scene loading** in isolation before integration

## Common Path Issues

### Issue: Relative Paths
```
❌ path="res://eye.png"
✓ path="res://assets/characters/character_4/pieces/held/white_knight/eye.png"
```

### Issue: Wrong Base Directory
```
❌ path="res://pieces/held/white_knight/eye.png"
✓ path="res://assets/characters/character_4/pieces/held/white_knight/eye.png"
```

### Issue: Missing Character Folder
```
❌ path="res://assets/pieces/held/white_knight/eye.png"
✓ path="res://assets/characters/character_4/pieces/held/white_knight/eye.png"
```

## Debug Logs Reference

When `chess_piece_sprite.gd` runs, you'll see logs like:

```
[ChessPieceSprite] Searching for scene-based piece:
  - piece_type: knight
  - character_id: 4
  - is_held: true
  - base_path: res://assets/characters/character_4/pieces/held/white_knight
  - scene_dir: res://assets/characters/character_4/pieces/held/white_knight/scene
  - Checking: res://assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn
  ✓ FOUND: res://assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn
[ChessPieceSprite] Loading scene: res://assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn
[ChessPieceSprite] ✓ Scene loaded successfully
[ChessPieceSprite] Attempting to instantiate scene...
[ChessPieceSprite] ✓ Created scene-based piece: knight (Character 4, is_held: true)
```

## Related Files

- `/home/user/chess-thesis/scripts/asset_path_bug_checker.gd` - Main bug checker
- `/home/user/chess-thesis/scenes/debug/asset_path_checker.tscn` - Test scene
- `/home/user/chess-thesis/scripts/chess_piece_sprite.gd` - Piece sprite loader
- `/home/user/chess-thesis/assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn` - Fixed scene

## Testing Checklist

After making changes to asset paths, verify:

- [ ] Run asset_path_checker.tscn - all checks pass
- [ ] No red "✗" errors in console output
- [ ] JSON report shows 0 issues
- [ ] White knight piece loads correctly in-game
- [ ] Hover effect displays with all textures
- [ ] No "Failed to load texture" errors
- [ ] AnimatedSprite2D eye animation plays
- [ ] GPU particles show ghost effects
