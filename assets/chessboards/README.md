# Chessboard Assets

This folder contains themed chessboard backgrounds.

## Required Files

### Split Chessboard Backgrounds
The chessboard will be split in half vertically, with each half showing the theme of the player controlling that side:

- `classic_half.png` - Classic theme chessboard half (recommended: 1024x512px)
- `modern_half.png` - Modern theme chessboard half (recommended: 1024x512px)
- `fantasy_half.png` - Fantasy theme chessboard half (recommended: 1024x512px)

### Alternative: Full Board Variants (Optional)
If you want to create complete board designs:
- `classic_full.png` - Full classic board (recommended: 1024x1024px)
- `modern_full.png` - Full modern board (recommended: 1024x1024px)
- `fantasy_full.png` - Full fantasy board (recommended: 1024x1024px)

## Design Guidelines

### Classic Theme
- Traditional checkered pattern
- Warm brown and cream colors
- Wood texture optional

### Modern Theme
- Sleek, minimalist design
- Cool color palette (dark blue/teal and light blue/white)
- Glossy or metallic finish optional

### Fantasy Theme
- Mystical, magical appearance
- Rich warm colors (purple, gold, bronze)
- Particle effects, runes, or magical symbols optional

## Technical Requirements
- Format: PNG with alpha channel
- Resolution: At least 1024x1024px for full boards, 1024x512px for halves
- The chessboard will dynamically combine two halves based on player character selection
- Ensure seamless blending at the center line for split boards

## How It Works
When two players with different characters face each other:
- Player 1's character theme appears on rows 1-4 (bottom half)
- Player 2's character theme appears on rows 5-8 (top half)
- The themes blend at the centerline of the board
