# Character 4 Board Theme - Quick Start Guide

This guide explains how to set up custom chessboard themes for Character 4 (Scyka).

## Option 1: Use a Background Image (Easiest)

1. **Prepare your image:**
   - Create or find a chessboard background image
   - Recommended size: 1040x1040 pixels (or any square resolution)
   - Format: PNG or JPEG
   - Make sure the board pattern is visible (8x8 grid should be distinguishable)

2. **Add the image:**
   - Rename your image to `board_theme.png` or `board_theme.jpg`
   - Place it in: `assets/characters/character_4/chessboard/`
   - Path should be: `assets/characters/character_4/chessboard/board_theme.png`

3. **Test in game:**
   - Start the game and select Character 4
   - The chessboard should now display your custom background
   - The board squares will be transparent, showing your image underneath
   - Chess pieces remain fully interactive on top

**That's it!** The image will automatically be detected and used.

## Option 2: Use Custom Colors (Programmatic)

If you want to use colors instead of an image, or want more control:

1. **Open the configuration file:**
   - File: `assets/characters/character_4/chessboard/board_theme_config.gd`

2. **Edit the color values:**
   ```gdscript
   # Light square color (RGBA: Red, Green, Blue, Alpha)
   var light_color: Color = Color(0.75, 0.65, 0.85, 0.7)

   # Dark square color (RGBA: Red, Green, Blue, Alpha)
   var dark_color: Color = Color(0.45, 0.35, 0.55, 0.7)
   ```

3. **Understanding Color values:**
   - Each value ranges from 0.0 to 1.0
   - Format: `Color(red, green, blue, alpha)`
   - Example: `Color(1.0, 0.0, 0.0, 0.8)` = Bright red at 80% opacity
   - Example: `Color(0.5, 0.5, 1.0, 0.7)` = Light blue at 70% opacity

4. **Try preset themes:**
   The config file includes several preset themes you can activate:
   - `apply_mystic_purple_theme()` - Default mystical purple
   - `apply_ghost_blue_theme()` - Ghostly blue
   - `apply_spectral_green_theme()` - Spectral green
   - `apply_ethereal_pink_theme()` - Ethereal pink
   - `apply_dark_mystic_theme()` - Dark mystical

   To use a preset, uncomment it in the config file's `_ready()` function.

## Option 3: Both Image and Color Override

You can use both systems together:

1. Place your background image (`board_theme.png`)
2. Edit `board_theme_config.gd` to control:
   - Whether to use the image: `var use_image_if_available: bool = true`
   - Square opacity when image is shown: `var image_mode_square_opacity: float = 0.0`
     - `0.0` = Fully transparent squares (image fully visible)
     - `0.3` = Slightly visible squares over image
     - `0.5` = Equal blend of squares and image

## Advanced: Disable Image Theming

To force color-only mode even if an image exists:

1. Open `board_theme_config.gd`
2. Set: `var use_image_if_available: bool = false`
3. The system will ignore any images and use only colors

## Tips and Best Practices

### For Image Themes:
- Use high-resolution images (1040x1040 or higher) for crisp display
- Make sure light and dark squares are distinguishable
- Test with chess pieces on the board to ensure visibility
- PNG format supports transparency if needed
- The image will scale to fit the board automatically

### For Color Themes:
- Use contrasting light and dark colors for clear squares
- Keep opacity between 0.6-0.8 for best visual effect
- Test colors in-game to ensure pieces are visible
- Remember: lower alpha values = more transparency

### For Mystical/Ghost Themes:
- Character 4 (Scyka) has a mystical ghost theme
- Consider using purples, blues, or ethereal colors
- Slightly transparent squares (alpha 0.6-0.7) work well with the character
- Ghost/spectral effects in images complement the character design

## Troubleshooting

**Image not showing:**
- Check filename: Must be exactly `board_theme.png` or `board_theme.jpg`
- Check location: Must be in `assets/characters/character_4/chessboard/`
- Verify the file is a valid image (not corrupted)
- Check if `use_image_if_available` is set to `true` in config

**Colors not changing:**
- Make sure you saved `board_theme_config.gd` after editing
- If an image exists, colors are only used for the transparent overlay
- Remove the image file to see pure color theme
- Check the alpha value isn't set to 0.0 (fully transparent)

**Board looks weird:**
- If image is distorted: Check that it's square (1:1 aspect ratio)
- If squares are too visible over image: Lower `image_mode_square_opacity` to 0.0
- If pieces are hard to see: Adjust image brightness or square opacity

## Technical Details

The theme system works as follows:

1. **Loading priority:**
   - System checks for `board_theme_config.gd` first
   - Reads color and settings from config
   - Checks for image file (`board_theme.png` or `.jpg`)
   - If image exists and enabled, loads it as background layer
   - If no image, uses pure color mode

2. **Rendering layers (bottom to top):**
   - Background image (z-index: -10) - if present
   - Board squares (z-index: 0) - transparent in image mode
   - Chess pieces (z-index: 10+) - always visible and interactive

3. **Files in this directory:**
   - `README.md` - Detailed technical documentation
   - `USAGE_GUIDE.md` - This file (quick start guide)
   - `board_theme_config.gd` - Color configuration script
   - `board_theme.png` or `.jpg` - Optional background image (you add this)
   - `.gitkeep` - Keeps directory in git (ignore this)

## Examples

### Example 1: Purple Mystical Board
```gdscript
# In board_theme_config.gd
var light_color: Color = Color(0.85, 0.75, 0.95, 0.7)  # Light lavender
var dark_color: Color = Color(0.50, 0.35, 0.65, 0.7)   # Deep purple
```

### Example 2: Ghostly Blue Board
```gdscript
# In board_theme_config.gd
var light_color: Color = Color(0.75, 0.85, 0.95, 0.65)  # Pale blue
var dark_color: Color = Color(0.35, 0.50, 0.70, 0.75)   # Ocean blue
```

### Example 3: Custom Image with Slight Overlay
```gdscript
# In board_theme_config.gd
var use_image_if_available: bool = true
var image_mode_square_opacity: float = 0.15  # Slight checkerboard overlay

# Add your board_theme.png to the directory
```

## Need Help?

- Check the main `README.md` for more technical details
- Review `board_theme_config.gd` comments for all options
- Test changes in-game by selecting Character 4 in character selection
- The game logs will show whether image or color mode is active

---

**Happy theming! Make Character 4's board uniquely yours!**
