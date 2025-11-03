# Character 2 - Modern Theme

## Character Configuration

**Character Name:** `Character 2`
**Character ID:** `2` (used in code references)
**Folder:** `character_2`

> **Important:** The configuration file (`piece_effects_config.gd`) uses `character_id: 2` and `character_name: "Character 2"`. This ID must match across all character references in the codebase.

## Overview

This folder contains all assets for Character 2 with the Modern theme.

## Folder Structure

### backgrounds/
Place character and chessboard background images here:
- `character_background.png` - Background image for character display (recommended: 512x512px or higher)
- `chessboard_half.png` - Background for this character's half of the chessboard (recommended: 1024x512px)

### pieces/
Place individual chess piece images here (.png with transparency):
- `black_king.png` (recommended size: 256x256px)
- `black_queen.png`
- `black_rook.png`
- `black_bishop.png`
- `black_knight.png`
- `black_pawn.png`

### animations/
Place character animation files here:
- `character_idle.mp4` - Idle animation for character display
- `character_victory.mp4` - Victory animation (optional)
- `character_defeat.mp4` - Defeat animation (optional)
- `piece_capture_effect.mp4` - Effect when capturing pieces (optional)

## Theme Details
- **Style**: Modern, sleek design
- **Color Palette**: Cool tones (blues, teals) for black pieces
- **Recommended Art Style**: Minimalist, futuristic aesthetic

## File Format Requirements
- Images: PNG with alpha channel for transparency
- Videos: MP4 format, H.264 codec
- Recommended video resolution: 512x512px or 1024x1024px
- Keep file sizes optimized for mobile devices (< 5MB per file)

## Configuration Files

### Piece Effects Config
**File:** `piece_effects_config.gd`

Defines the visual effects for Character 2's chess pieces with a **modern blue/cyan theme**:
- Cool blue/cyan glowing effects
- 35% scale increase when holding pieces (more dramatic than Character 1)
- Rotation and pulse animations enabled
- Color shift effects
- Modern, futuristic appearance

**Configuration:**
- `character_id = 2`
- `character_name = "Character 2"`
- `glow_color = Color(0.3, 0.8, 1.0, 0.8)` (cool blue glow)
- `scale_factor = 1.35` (35% larger when held)
- `rotation_enabled = true`
- `pulse_enabled = true`
- `color_shift_enabled = true`

## File Naming

All configuration files use:
- `character_id: 2` in all config files
- Folder name: `character_2`

**No file name changes needed** - all files are properly named and configured.
