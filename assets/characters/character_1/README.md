# Character 1 - Classic Theme

## Character Configuration

**Character Name:** `Character 1`
**Character ID:** `1` (used in code references)
**Folder:** `character_1`

> **Important:** The configuration file (`piece_effects_config.gd`) uses `character_id: 1` and `character_name: "Character 1"`. This ID must match across all character references in the codebase.

## Overview

This folder contains all assets for Character 1 with the Classic theme.

## Folder Structure

### backgrounds/
Place character and chessboard background images here:
- `character_background.png` - Background image for character display (recommended: 512x512px or higher)
- `chessboard_half.png` - Background for this character's half of the chessboard (recommended: 1024x512px)

### pieces/
Place individual chess piece images here (.png with transparency):
- `white_king.png` (recommended size: 256x256px)
- `white_queen.png`
- `white_rook.png`
- `white_bishop.png`
- `white_knight.png`
- `white_pawn.png`

### animations/
Place character animation files here:
- `character_idle.mp4` - Idle animation for character display
- `character_victory.mp4` - Victory animation (optional)
- `character_defeat.mp4` - Defeat animation (optional)
- `piece_capture_effect.mp4` - Effect when capturing pieces (optional)

## Theme Details
- **Style**: Classic chess aesthetic
- **Color Palette**: Traditional white pieces (pure white, cream tones)
- **Recommended Art Style**: Elegant, traditional chess design

## File Format Requirements
- Images: PNG with alpha channel for transparency
- Videos: MP4 format, H.264 codec
- Recommended video resolution: 512x512px or 1024x1024px
- Keep file sizes optimized for mobile devices (< 5MB per file)

## Configuration Files

### Piece Effects Config
**File:** `piece_effects_config.gd`

Defines the visual effects for Character 1's chess pieces with a **classic golden theme**:
- Golden/yellow glowing effects
- 30% scale increase when holding pieces
- Blurred shadow effects
- Traditional, elegant appearance

**Configuration:**
- `character_id = 1`
- `character_name = "Character 1"`
- `glow_color = Color(1.0, 0.9, 0.3, 0.8)` (golden glow)
- `scale_factor = 1.3` (30% larger when held)

## File Naming

All configuration files use:
- `character_id: 1` in all config files
- Folder name: `character_1`

**No file name changes needed** - all files are properly named and configured.
