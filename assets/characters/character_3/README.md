# Character 3 - Fantasy Theme

## Character Configuration

**Character Name:** `Character 3`
**Character ID:** `3` (used in code references)
**Folder:** `character_3`

> **Important:** The configuration file (`piece_effects_config.gd`) uses `character_id: 3` and `character_name: "Character 3"`. This ID must match across all character references in the codebase.

## Overview

This folder contains all assets for Character 3 with the Fantasy theme.

## Folder Structure

### backgrounds/
Place character and chessboard background images here:
- `character_background.png` - Background image for character display (recommended: 512x512px or higher)
- `chessboard_half.png` - Background for this character's half of the chessboard (recommended: 1024x512px)

### pieces/
Place individual chess piece images here (.png with transparency):
- `white_king.png` (recommended size: 256x256px) - OR - `black_king.png` depending on player assignment
- `white_queen.png` (or `black_queen.png`)
- `white_rook.png` (or `black_rook.png`)
- `white_bishop.png` (or `black_bishop.png`)
- `white_knight.png` (or `black_knight.png`)
- `white_pawn.png` (or `black_pawn.png`)

### animations/
Place character animation files here:
- `character_idle.mp4` - Idle animation for character display
- `character_victory.mp4` - Victory animation (optional)
- `character_defeat.mp4` - Defeat animation (optional)
- `piece_capture_effect.mp4` - Effect when capturing pieces (optional)

## Theme Details
- **Style**: Fantasy/magical design
- **Color Palette**: Warm mystical tones (golds, purples, magical effects)
- **Recommended Art Style**: Fantasy RPG aesthetic with magical elements

## File Format Requirements
- Images: PNG with alpha channel for transparency
- Videos: MP4 format, H.264 codec
- Recommended video resolution: 512x512px or 1024x1024px
- Keep file sizes optimized for mobile devices (< 5MB per file)

## Configuration Files

### Piece Effects Config
**File:** `piece_effects_config.gd`

Defines the visual effects for Character 3's chess pieces with a **fantasy magical pink/purple theme**:
- Pink/magenta glowing effects
- 40% scale increase when holding pieces (most dramatic scaling)
- Shimmer, particles, sparkles, and aura effects enabled
- Magical, fantasy appearance

**Configuration:**
- `character_id = 3`
- `character_name = "Character 3"`
- `glow_color = Color(1.0, 0.3, 0.8, 0.8)` (pink/magenta glow)
- `scale_factor = 1.4` (40% larger when held)
- `shimmer_enabled = true`
- `particle_enabled = true`
- `sparkle_enabled = true`
- `aura_enabled = true`

## File Naming

All configuration files use:
- `character_id: 3` in all config files
- Folder name: `character_3`

**No file name changes needed** - all files are properly named and configured.
