# Character 4 (Scyka) - Held Piece Images

This folder is for custom held piece images for **Character 4 (Scyka Live2D)**.

## Overview

When a chess piece is picked up (held) by the player, you can optionally display a different image for that piece. This folder is where you place those custom held piece images.

## How to Add Custom Held Images

1. **Create or prepare your images**
   - Supported formats: PNG, JPEG, OGV (video)
   - Recommended size: 128x128 to 256x256 pixels
   - Images should have transparent backgrounds (for PNG)

2. **Name your files using this convention:**
   - `white_king.png` - White king held image
   - `white_queen.png` - White queen held image
   - `white_rook.png` - White rook held image
   - `white_bishop.png` - White bishop held image
   - `white_knight.png` - White knight held image
   - `white_pawn.png` - White pawn held image
   - `black_king.png` - Black king held image
   - `black_queen.png` - Black queen held image
   - `black_rook.png` - Black rook held image
   - `black_bishop.png` - Black bishop held image
   - `black_knight.png` - Black knight held image
   - `black_pawn.png` - Black pawn held image

3. **Place the files in this folder**
   - Path: `assets/characters/character_4/pieces/held/`

4. **The system will automatically detect and use them**
   - No code changes needed
   - Images are loaded when the piece is picked up
   - If no custom image is found, the default piece image is used

## Theme Guidelines for Character 4

Character 4 (Scyka) features a **mystical/magical purple theme** with Live2D animation. Consider these guidelines when creating held piece images:

- **Color scheme**: Purple, violet, magenta, blue highlights
- **Style**: Magical, mystical, glowing effects
- **Effects**: Consider adding:
  - Purple/violet glowing outlines
  - Sparkle or shimmer effects
  - Mystical energy auras
  - Ethereal or translucent elements

## Custom Paths

If you want to use images from a different location, you can specify custom paths in the piece effects config file:

**File**: `assets/characters/character_4/piece_effects_config.gd`

```gdscript
func _init():
    # ...
    # Specify custom paths for held images
    custom_held_image_king = "res://path/to/custom/king.png"
    custom_held_image_queen = "res://path/to/custom/queen.png"
    # etc...
```

## Example File Structure

```
assets/characters/character_4/pieces/held/
├── README.md (this file)
├── white_king.png
├── white_queen.png
├── white_rook.png
├── white_bishop.png
├── white_knight.png
├── white_pawn.png
├── black_king.png
├── black_queen.png
├── black_rook.png
├── black_bishop.png
├── black_knight.png
└── black_pawn.png
```

## Notes

- Held images are optional - the system works fine without them
- You can provide images for only some pieces (e.g., just the king and queen)
- Video files (.ogv) are supported for animated held pieces
- The piece effects configuration controls visual effects applied to held pieces
- See `PIECE_EFFECTS_README.md` in the project root for more information

## Live2D Integration

Character 4 uses Live2D animation technology. While the held piece images are standard 2D images, they're displayed alongside the Live2D character during gameplay, creating a unique visual experience.

For more information about the Live2D setup, see `LIVE2D_SETUP.md` in the project root.
