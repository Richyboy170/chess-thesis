# Character 2 - Held Piece Images

This folder contains alternate images for chess pieces when they are picked up and held by the player.

## How It Works

When a player picks up a piece belonging to Character 2, the system will automatically look for an alternate image in this folder. If found, it will temporarily swap to that image until the piece is released.

## File Naming Convention

Files should be named according to this pattern:
```
white_[piece_type].png
```

For example:
- `white_king.png` - Image for held King
- `white_queen.png` - Image for held Queen
- `white_rook.png` - Image for held Rook
- `white_bishop.png` - Image for held Bishop
- `white_knight.png` - Image for held Knight
- `white_pawn.png` - Image for held Pawn

## Supported Formats

- **PNG** (`.png`) - Recommended for static images
- **JPEG** (`.jpg`, `.jpeg`) - For static images
- **OGV** (`.ogv`) - For animated/video pieces

## Image Specifications

- Use the same dimensions as your regular piece images
- Recommended: Add visual effects like glow, highlight, or energy effects
- For animations (OGV), keep file size under 1MB for best performance

## Ideas for Held Images

- **Glowing version**: Add a bright outline or glow effect
- **Highlighted**: Use brighter colors or add a selection highlight
- **Energy effect**: Add magical or energy particles in the image itself
- **Animated**: Create an OGV video showing the piece with subtle animation

## Character 2 Theme

Character 2 uses a **Mystical/Blue** theme:
- Recommended colors: Blue, cyan, cool tones
- Effect style: Mystical, dynamic, with rotation and pulsing

## Testing Your Images

1. Add your image to this folder with the correct naming
2. Start the game
3. Pick up the corresponding piece
4. The held image should appear automatically

## Customization

To use custom paths instead of this folder, edit:
`assets/characters/character_2/piece_effects_config.gd`

And set the custom paths in the `_init()` function:
```gdscript
custom_held_image_king = "res://path/to/your/custom_king.png"
```
