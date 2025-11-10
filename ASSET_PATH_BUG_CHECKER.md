# Asset Path Bug Checker

## Quick Start

Run the bug checker to diagnose asset path issues in your project:

```bash
# Open and run this scene in Godot:
scenes/debug/asset_path_checker.tscn
```

Or from code:
```gdscript
var issues = AssetPathBugChecker.run_check()
```

## What Was Fixed

**Problem:** The white_knight scene had incorrect relative paths:
- ❌ `res://eye.png`
- ❌ `res://purple piece.png`
- ❌ `res://ghost flip.png`

**Solution:** Updated to correct absolute paths:
- ✓ `res://assets/characters/character_4/pieces/held/white_knight/eye.png`
- ✓ `res://assets/characters/character_4/pieces/held/white_knight/purple piece.png`
- ✓ `res://assets/characters/character_4/pieces/held/white_knight/ghost flip.png`

## Files Modified

1. **`assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn`**
   - Fixed asset paths from relative to absolute

2. **`scripts/chess_piece_sprite.gd`**
   - Added comprehensive debug logging
   - Tracks all file loading operations
   - Reports missing files immediately

3. **`scripts/asset_path_bug_checker.gd`** (NEW)
   - Comprehensive asset path validator
   - Scans all .tscn files
   - Checks file existence
   - Generates JSON reports

4. **`scenes/debug/asset_path_checker.tscn`** (NEW)
   - Test scene to run the bug checker

## The Bug Checker Does

✓ Checks all white_knight asset files exist
✓ Scans all .tscn files for broken paths
✓ Detects relative vs absolute path issues
✓ Tests ChessPieceSprite.find_piece_scene()
✓ Validates scene loading and instantiation
✓ Generates detailed JSON reports
✓ Provides suggested fixes for broken paths

## Output

### Console Output
```
================================================================================
ASSET PATH BUG CHECKER - Starting Diagnostics
================================================================================

[CHECK 1] White Knight Asset Files
--------------------------------------------------------------------------------
Base path: res://assets/characters/character_4/pieces/held/white_knight/

Checking files:
  ✓ FOUND: scene/hovereffect_scyka.tscn
  ✓ FOUND: eye.png
  ✓ FOUND: ghost flip.png
  ...

[CHECK 2] Scanning .tscn Files for Broken Paths
--------------------------------------------------------------------------------
Found 17 .tscn files to check
  ✓ OK: res://scenes/game/main_game.tscn
  ✗ BROKEN PATH: res://assets/.../scene.tscn
    Line 3: res://missing_file.png (FILE NOT FOUND)
  ...

[CHECK 3] Chess Piece Sprite Path Resolution
--------------------------------------------------------------------------------
Testing ChessPieceSprite.find_piece_scene():
  piece_type: knight
  character_id: 4
  is_held: true
  ✓ Found scene: res://assets/.../hovereffect_scyka.tscn
  ✓ Scene loads successfully
  ✓ Scene instantiated successfully

================================================================================
BUG CHECKER SUMMARY
================================================================================

Statistics:
  Files checked: 45
  Issues found: 3
  Broken paths: 1

✓ All checks passed! No issues found.

Detailed report saved to: res://asset_path_bug_report.json
```

### JSON Report
Located at `res://asset_path_bug_report.json`:

```json
{
  "timestamp": "2025-11-10T14:23:45",
  "files_checked": 45,
  "issues_count": 3,
  "broken_paths": 1,
  "issues": [
    {
      "type": "relative_path",
      "file": "res://assets/.../scene.tscn",
      "line": 3,
      "path": "res://eye.png",
      "suggested_fix": "res://assets/.../eye.png"
    }
  ]
}
```

## Enhanced Debug Logging

When pieces are loaded, you now see detailed logs:

```
[ChessPieceSprite] Searching for scene-based piece:
  - piece_type: knight
  - character_id: 4
  - is_held: true
  - base_path: res://assets/characters/character_4/pieces/held/white_knight
  - scene_dir: res://assets/characters/character_4/pieces/held/white_knight/scene
  - Checking: res://assets/.../hovereffect_scyka.tscn
  ✓ FOUND: res://assets/.../hovereffect_scyka.tscn
[ChessPieceSprite] Loading scene: res://assets/.../hovereffect_scyka.tscn
[ChessPieceSprite] ✓ Scene loaded successfully
[ChessPieceSprite] Attempting to instantiate scene...
[ChessPieceSprite] ✓ Created scene-based piece: knight (Character 4, is_held: true)
```

## Prevention Tips

1. **Always use absolute paths** starting with `res://`
2. **Run the bug checker** before committing
3. **Check console logs** for warnings
4. **Test scenes in isolation** first

## More Information

See `docs/asset_path_debugging.md` for detailed documentation.
