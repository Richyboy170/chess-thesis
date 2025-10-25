# Chess Board Highlight Images

This folder contains highlight images used for indicating valid chess moves.

## Required Images

1. **valid_move.png** - Green glowing highlight for valid empty squares
   - Recommended size: 128x128 pixels or larger
   - Should have a green glow/light effect
   - Use transparency (alpha channel) for smooth blending

2. **capture_move.png** - Red glowing highlight for capture moves
   - Recommended size: 128x128 pixels or larger
   - Should have a red glow/light effect
   - Use transparency (alpha channel) for smooth blending

## Fallback Behavior

If these images are not present, the game will use built-in visual effects with:
- Green glow effect for valid moves
- Red glow effect for capture moves

## Creating Highlight Images

You can create these images using any image editor. Recommended effects:
- Radial gradient from center
- Outer glow
- Soft edges with transparency
- Bright center fading to transparent edges
