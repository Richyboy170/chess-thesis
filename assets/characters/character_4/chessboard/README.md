# Character 4 Chessboard Theme

This directory contains the chessboard theme assets for Character 4 (Scyka).

## Theme System

The chessboard theming system supports two modes:

### 1. Image-Based Theming
Place PNG or JPEG images in this directory to use as the chessboard background:
- `board_theme.png` or `board_theme.jpg` - Full board background image
- The image will be displayed as a background layer with the chessboard overlay becoming transparent
- Recommended resolution: 1040x1040 pixels (130px per square * 8 squares)
- The board overlay will have near-zero opacity to show the image underneath
- Chess pieces remain fully interactive and visible on top

### 2. Color-Based Theming
Edit the `board_theme_config.gd` file to programmatically set chessboard colors:
- Define light and dark square colors using Color values
- Supports full RGBA color specification
- Colors are applied when no image is present, or can override image theming

## Priority System
1. If a valid `board_theme.png` or `board_theme.jpg` exists, it will be used as the background
2. If no image is found, the color configuration from `board_theme_config.gd` is used
3. If neither exists, falls back to the default character colors in `game_state.gd`

## How It Works

### Image Mode
When an image is detected:
1. The game loads the image as a TextureRect background layer
2. The image is positioned under the chessboard grid (lower z-index)
3. The chessboard square panels have their opacity set to 0.0 (fully transparent)
4. The image shows through, creating a custom board appearance
5. Chess pieces and interaction remain fully functional on top

### Color Mode
When using colors only:
1. The theme config file is loaded
2. Light and dark colors are applied to the checkerboard pattern
3. Standard StyleBoxFlat rendering is used
4. No background texture is created

## Technical Details
- Background images are loaded at game initialization
- Images are stretched to fit the board dimensions
- Z-index layering: Background image (-10) → Board squares (0) → Pieces (10+)
- Mouse input passes through transparent squares to maintain interactivity
- The system integrates with the existing character theme system

## Example Usage

### Adding an Image Theme:
1. Create or obtain a chessboard background image (PNG or JPEG)
2. Rename it to `board_theme.png` or `board_theme.jpg`
3. Place it in this directory
4. The game will automatically load it when Character 4 is selected

### Configuring Colors Programmatically:
1. Open `board_theme_config.gd`
2. Modify the `light_color` and `dark_color` values:
   ```gdscript
   var light_color = Color(0.85, 0.75, 0.95, 0.8)  # Light purple
   var dark_color = Color(0.45, 0.35, 0.60, 0.8)   # Dark purple
   ```
3. Save the file
4. Colors will be applied when no image is present

## Asset Guidelines
- **Image Format**: PNG (with alpha) or JPEG recommended
- **Resolution**: 1040x1040 pixels or higher for best quality
- **Aspect Ratio**: 1:1 (square)
- **Theme**: Should match Character 4's mystical/ghost aesthetic
- **Visibility**: Ensure important board features (squares, center) are distinguishable
- **Colors**: Consider light/dark square visibility for gameplay

## Files in This Directory
- `README.md` - This file
- `board_theme_config.gd` - Color configuration script (programmer-editable)
- `board_theme.png` or `board_theme.jpg` - Optional background image
- `.gitkeep` - Keeps directory in git (can be ignored)
