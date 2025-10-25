# Asset Validation System

This document describes the asset validation system that checks for the presence of background images, character animations, and other game assets.

## Overview

The validation system automatically runs when:
1. **Character Selection Screen** loads - validates character preview assets
2. **Main Game** starts - validates all game assets including backgrounds, character media, and piece images

## What Gets Validated

### 1. Background Images
**Location**: `assets/backgrounds/`

The system checks for:
- Presence of the backgrounds folder
- At least one valid image file (PNG, JPG, JPEG)

**Output Example**:
```
[BACKGROUNDS]
  ✓ Found 3 background image(s):
    - castle_arena.png
    - forest_battlefield.jpg
    - space_station.png
```

**Warning Example**:
```
[BACKGROUNDS]
  ⚠ WARNING: No background images found in backgrounds folder
    Please add PNG or JPG files to: res://assets/backgrounds/
    Game will use default transparent background
```

### 2. Character Assets (Characters 1, 2, 3)

For each character, the system validates:

#### A. MP4 Animation
**Location**: `assets/characters/character_X/animations/character_idle.mp4`

- ✓ Found: Animation will play in character display areas
- ⚠ Warning: Will fall back to using background image only

#### B. Background Image
**Location**: `assets/characters/character_X/backgrounds/character_background.png`

- ✓ Found: Image will display in player areas
- ✗ Error: Critical - character cannot display properly

#### C. Piece Images
**Location**: `assets/characters/character_X/pieces/white_[piece_type].png`

Required pieces: pawn, rook, knight, bishop, queen, king

- ✓ All found: Pieces will display with custom images
- ✗ Some missing: Will fall back to Unicode symbols

**Output Example**:
```
[CHARACTER 1]
  ✓ MP4 animation found: character_idle.mp4
  ✓ Background image found: character_background.png
  ✓ All 6 piece images found

[CHARACTER 2]
  ⚠ WARNING: MP4 animation not found at: res://assets/characters/character_2/animations/character_idle.mp4
    Will use fallback background image
  ✓ Background image found: character_background.png
  ✓ All 6 piece images found
```

### 3. Validation Summary

At the end of validation, you'll see:
```
VALIDATION SUMMARY
------------------------------------------------------------
✓ All assets validated successfully!
```

Or if there are issues:
```
VALIDATION SUMMARY
------------------------------------------------------------
✗ Total Errors: 2
⚠ Total Warnings: 3
```

## Symbols Used

- **✓** - Success: Asset found and loaded correctly
- **⚠** - Warning: Asset missing but has fallback (non-critical)
- **✗** - Error: Critical asset missing, may affect gameplay

## Real-Time Loading Reports

In addition to validation, the system reports when assets are actually loaded:

### Character Media Loading
```
✓ Loaded character animation: res://assets/characters/character_1/animations/character_idle.mp4
✓ Loaded background image: res://assets/characters/character_1/backgrounds/character_background.png
```

Or with issues:
```
⚠ MP4 animation not found at: res://assets/characters/character_2/animations/character_idle.mp4
  Using fallback background image
✓ Loaded background image: res://assets/characters/character_2/backgrounds/character_background.png
⚠ Character loaded with background only (no animation)
```

### Background Loading
```
Selected random background: res://assets/backgrounds/castle_arena.png
Random game background loaded successfully
```

### Character Preview Loading (Character Selection)
```
✓ Character 1: Loaded MP4 preview on button
✓ Character 2: Loaded background image preview on button
✓ Character 3: Loaded background image preview on button
```

## How to Fix Common Issues

### Issue: "No background images found"
**Solution**: Add PNG or JPG files to `assets/backgrounds/` folder

### Issue: "MP4 animation not found"
**Solution**: Add `character_idle.mp4` to the character's `animations/` folder, or accept the fallback to background images

### Issue: "Background image not found"
**Solution**: This is critical! Add `character_background.png` to the character's `backgrounds/` folder

### Issue: "Missing piece images"
**Solution**: Add the missing PNG files to the character's `pieces/` folder
- Required files: `white_pawn.png`, `white_rook.png`, `white_knight.png`, `white_bishop.png`, `white_queen.png`, `white_king.png`

## Technical Details

### Functions

#### Main Game Validation
- `validate_all_assets()` - Master validation function
- `validate_background_images()` - Checks game backgrounds
- `validate_character_assets(character_num)` - Validates a specific character's assets
- `check_specific_asset(path, name)` - Helper for individual file checks

#### Character Selection Validation
- `validate_character_previews()` - Checks preview assets for all characters

### When Validation Runs

1. **Character Selection Screen**: On `_ready()` before loading previews
2. **Main Game**: After chessboard creation, before component initialization

### Console Output Location

All validation messages appear in the Godot console/output panel. Look for:
- `=== CHARACTER SELECTION: Asset Validation ===` - Character selection validation
- `ASSET VALIDATION REPORT` - Main game validation

## Best Practices

1. **Always check console output** when starting the game
2. **Fix errors (✗) immediately** - they indicate critical issues
3. **Address warnings (⚠) when possible** - they indicate suboptimal configurations
4. **Keep assets organized** - follow the folder structure exactly as documented

## Example Full Validation Output

```
=== CHARACTER SELECTION: Asset Validation ===

[Character 1 Preview]
  ✓ MP4 animation available for preview
  ✓ Background image available for preview

[Character 2 Preview]
  ⚠ MP4 animation not found - will use background image
  ✓ Background image available for preview

[Character 3 Preview]
  ⚠ MP4 animation not found - will use background image
  ✓ Background image available for preview

=== End Asset Validation ===

============================================================
ASSET VALIDATION REPORT
============================================================

[BACKGROUNDS]
  ⚠ WARNING: No background images found in backgrounds folder
    Please add PNG or JPG files to: res://assets/backgrounds/
    Game will use default transparent background

[CHARACTER 1]
  ✓ MP4 animation found: character_idle.mp4
  ✓ Background image found: character_background.png
  ✓ All 6 piece images found

[CHARACTER 2]
  ⚠ WARNING: MP4 animation not found at: res://assets/characters/character_2/animations/character_idle.mp4
    Will use fallback background image
  ✓ Background image found: character_background.png
  ✓ All 6 piece images found

[CHARACTER 3]
  ⚠ WARNING: MP4 animation not found at: res://assets/characters/character_3/animations/character_idle.mp4
    Will use fallback background image
  ✓ Background image found: character_background.png
  ✓ All 6 piece images found

------------------------------------------------------------
VALIDATION SUMMARY
------------------------------------------------------------
⚠ Total Warnings: 4

============================================================
```
