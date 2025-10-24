# Asset Checklist for Artists

This checklist helps track which assets need to be created for the themed chess game.

## Character 1 (Classic Theme)

### Backgrounds
- [ ] `character_1/backgrounds/character_background.png` - Character display background
- [ ] `character_1/backgrounds/chessboard_half.png` - Chessboard background for this theme

### Chess Pieces (White)
- [ ] `character_1/pieces/white_king.png`
- [ ] `character_1/pieces/white_queen.png`
- [ ] `character_1/pieces/white_rook.png`
- [ ] `character_1/pieces/white_bishop.png`
- [ ] `character_1/pieces/white_knight.png`
- [ ] `character_1/pieces/white_pawn.png`

### Animations
- [ ] `character_1/animations/character_idle.mp4` - Main character animation
- [ ] `character_1/animations/character_victory.mp4` (Optional)
- [ ] `character_1/animations/character_defeat.mp4` (Optional)
- [ ] `character_1/animations/piece_capture_effect.mp4` (Optional)

---

## Character 2 (Modern Theme)

### Backgrounds
- [ ] `character_2/backgrounds/character_background.png` - Character display background
- [ ] `character_2/backgrounds/chessboard_half.png` - Chessboard background for this theme

### Chess Pieces (Black)
- [ ] `character_2/pieces/black_king.png`
- [ ] `character_2/pieces/black_queen.png`
- [ ] `character_2/pieces/black_rook.png`
- [ ] `character_2/pieces/black_bishop.png`
- [ ] `character_2/pieces/black_knight.png`
- [ ] `character_2/pieces/black_pawn.png`

### Animations
- [ ] `character_2/animations/character_idle.mp4` - Main character animation
- [ ] `character_2/animations/character_victory.mp4` (Optional)
- [ ] `character_2/animations/character_defeat.mp4` (Optional)
- [ ] `character_2/animations/piece_capture_effect.mp4` (Optional)

---

## Character 3 (Fantasy Theme)

### Backgrounds
- [ ] `character_3/backgrounds/character_background.png` - Character display background
- [ ] `character_3/backgrounds/chessboard_half.png` - Chessboard background for this theme

### Chess Pieces (Can be White or Black)
- [ ] `character_3/pieces/white_king.png` (or black_king.png)
- [ ] `character_3/pieces/white_queen.png` (or black_queen.png)
- [ ] `character_3/pieces/white_rook.png` (or black_rook.png)
- [ ] `character_3/pieces/white_bishop.png` (or black_bishop.png)
- [ ] `character_3/pieces/white_knight.png` (or black_knight.png)
- [ ] `character_3/pieces/white_pawn.png` (or black_pawn.png)

### Animations
- [ ] `character_3/animations/character_idle.mp4` - Main character animation
- [ ] `character_3/animations/character_victory.mp4` (Optional)
- [ ] `character_3/animations/character_defeat.mp4` (Optional)
- [ ] `character_3/animations/piece_capture_effect.mp4` (Optional)

---

## Chessboard Backgrounds

### Split Board Halves (Recommended)
- [ ] `chessboards/classic_half.png` - Classic theme board half (1024x512px)
- [ ] `chessboards/modern_half.png` - Modern theme board half (1024x512px)
- [ ] `chessboards/fantasy_half.png` - Fantasy theme board half (1024x512px)

### Full Board Variants (Optional Alternative)
- [ ] `chessboards/classic_full.png` - Complete classic board (1024x1024px)
- [ ] `chessboards/modern_full.png` - Complete modern board (1024x1024px)
- [ ] `chessboards/fantasy_full.png` - Complete fantasy board (1024x1024px)

---

## File Requirements Summary

### Images (PNG)
- Use alpha channel for transparency
- Recommended resolutions:
  - Chess pieces: 256x256px
  - Character backgrounds: 512x512px or higher
  - Chessboard halves: 1024x512px
  - Full chessboards: 1024x1024px

### Videos (MP4)
- Codec: H.264
- Resolution: 512x512px or 1024x1024px
- Keep under 5MB per file for mobile optimization
- Loopable for idle animations

---

## Priority Order

1. **HIGH PRIORITY** - Core Assets
   - Character idle animations (.mp4)
   - Chess piece images (all 6 types per character)
   - Chessboard backgrounds

2. **MEDIUM PRIORITY** - Enhancement Assets
   - Character backgrounds
   - Victory/defeat animations

3. **LOW PRIORITY** - Optional Polish
   - Capture effect animations
   - Full board variants

---

## Notes
- The game will automatically combine different character themes on the same board
- The top half of the board shows Player 2's theme
- The bottom half shows Player 1's theme
- Ensure visual consistency within each theme
- Test how themes blend together at the centerline
