# Main Game Interface Adjustment Guide

This guide explains how to adjust the interface elements in the Main Game scene. Each section includes the exact file locations and search terms to help you find the code quickly.

---

## Quick Reference

| UI Element | File Location | Search Term |
|------------|---------------|-------------|
| Chessboard | `scenes/game/main_game.tscn` | `node name="Chessboard"` |
| Player Info Areas | `scenes/game/main_game.tscn` | `TopPlayerArea` or `BottomPlayerArea` |
| Score Panel | `scenes/game/main_game.tscn` | `node name="ScorePanel"` |
| Character Animations | `scripts/main_game.gd` | `load_character_media` |
| Timers | `scripts/main_game.gd` | `update_timer_display` |
| Captured Pieces | `scripts/main_game.gd` | `update_captured_display` |

---

## Main Files

### Scene File
**Path:** `scenes/game/main_game.tscn`
- Contains all UI layout and visual structure
- Edit this to change sizes, positions, and layout

### Script File
**Path:** `scripts/main_game.gd`
- Contains all game logic and UI updates
- Edit this to change behavior, colors, and animations

---

## 1. Adjusting the Chessboard

### Location in Scene
**Search:** `node name="Chessboard"`
**Path in tree:** `MainGame/MainContainer/GameArea/ChessboardContainer/.../Chessboard`

### Size and Layout
**File:** `scripts/main_game.gd`
**Search:** `func setup_chessboard()`
**Line:** Around 250-300

```gdscript
# To change chessboard size, modify:
chessboard.columns = 8  # Number of columns (default 8)
# Each square size is calculated automatically
```

### Colors
**Search:** `light_color` or `dark_color`
**Function:** `setup_chessboard()`

```gdscript
# Light squares
light_color = Color(0.9, 0.9, 0.8, 0.7)

# Dark squares
dark_color = Color(0.5, 0.4, 0.3, 0.7)
```

### Zoom and Pan
**Search:** `zoom_chessboard_to_center` or `pan_chessboard`
**Functions in:** `scripts/main_game.gd`

- Zoom range: 70% - 100% (use mouse wheel)
- Pan: Click and drag the chessboard

---

## 2. Player Info Areas (Top & Bottom)

### Layout Location
**Scene File:** `scenes/game/main_game.tscn`
**Search:** `node name="TopPlayerArea"` or `node name="BottomPlayerArea"`

### Height Adjustment
**Search:** `custom_minimum_size`
**In scene node:** `TopPlayerArea` or `BottomPlayerArea`

```
Current height: 200 pixels
Change custom_minimum_size = Vector2(0, 200) to adjust
```

### Player Name Font Size
**Script:** `scripts/main_game.gd`
**Search:** `PlayerName` and `add_theme_font_size_override`

```gdscript
# Current size: 48px
player_name.add_theme_font_size_override("font_size", 48)

# Change to make larger/smaller:
player_name.add_theme_font_size_override("font_size", 56)
```

### Character Name Font Size
**Search:** `CharacterName` and `add_theme_font_size_override`

```gdscript
# Current size: 40px
character_name.add_theme_font_size_override("font_size", 40)
```

### Timer Display
**Search:** `func update_timer_display()`
**Colors change based on time remaining:**

```gdscript
# Green: More than 60 seconds
Color(0.3, 1, 0.3, 1)

# Yellow: 30-60 seconds
Color(1, 1, 0, 1)

# Red: Less than 30 seconds
Color(1, 0, 0, 1)
```

**Font size:** 56px (search: `TimerLabel` in scene file)

---

## 3. Character Animation Displays

### Debug Tool
**Press 'D' during gameplay** to open the Character Animation Debugger

### Loading Character Media
**File:** `scripts/main_game.gd`
**Search:** `func load_character_media()`

```gdscript
# Character asset paths:
"res://assets/characters/character_1/"
"res://assets/characters/character_2/"
"res://assets/characters/character_3/"

# Animation states: "idle", "victory", "capture", "check"
```

### Display Size
**Scene File:** `scenes/game/main_game.tscn`
**Search:** `node name="CharacterDisplay"`

```
Current size: 400x400 pixels
Located in TopPlayerArea (right side) and BottomPlayerArea (left side)
```

### Playing Animations
**Search:** `func play_special_animation()`

```gdscript
# Trigger animations:
play_special_animation(player_num, "idle")
play_special_animation(player_num, "victory")
play_special_animation(player_num, "capture")
play_special_animation(player_num, "check")
```

---

## 4. Score Panel (Right Side)

### Toggle Button
**Scene:** `scenes/game/main_game.tscn`
**Search:** `node name="ScoreToggleButton"`

- Shows ">" when panel is hidden
- Shows "<" when panel is visible

### Panel Visibility
**Script:** `scripts/main_game.gd`
**Search:** `func toggle_score_panel()`

```gdscript
# Animation duration: 0.3 seconds
# Fades in/out smoothly
```

### Panel Width
**Scene node:** `ScorePanel`
**Property:** `custom_minimum_size = Vector2(250, 0)`

Change 250 to adjust width.

### Score Panel Content
**Search:** `node name="ScorePanel"` in scene file

Contains:
- Player 1 Score (search: `Player1Score`)
- Player 2 Score (search: `Player2Score`)
- Turn Indicator (search: `TurnIndicator`)
- Moves Counter (search: `MovesLabel`)
- Captured Pieces Counter (search: `CapturedLabel`)
- Menu Button (search: `MenuButton`)

### Font Sizes in Score Panel
**In scene file, search for each label:**

```
ScoreLabel: 26px
Player Score Names: 20px
Score Values: 24px
Turn Indicator: 22px
Game Stats: 18px
Menu Button: 22px
```

---

## 5. Captured Pieces Display

### Update Function
**File:** `scripts/main_game.gd`
**Search:** `func update_captured_display()`

### Colors by Theme
**Search:** `get_captured_piece_tint()`

```gdscript
"classic": Color(0.3, 0.3, 0.3)  # Dark gray
"modern": Color(0.2, 0.3, 0.5)   # Blue-tinted
"fantasy": Color(0.5, 0.2, 0.4)  # Purple-tinted
```

### Container Location
**Scene:** `scenes/game/main_game.tscn`
**Search:** `node name="CapturedPieces"`

Located in both `TopPlayerArea` and `BottomPlayerArea` player info sections.

---

## 6. Background

### Random Background Loading
**File:** `scripts/main_game.gd`
**Search:** `func load_random_background()`

```gdscript
# Background assets folder:
"res://assets/backgrounds/"

# Supports: .png, .jpg, .webp, .ogv
# Z-index: -100 (behind all UI)
```

### Validation
**Search:** `func validate_game_background()`

Checks if background file exists and is valid format.

---

## 7. Main Container Layout

### Scene Structure
**File:** `scenes/game/main_game.tscn`
**Root node:** `MainGame` (Control)
**Main layout:** `MainContainer` (VBoxContainer)

### Vertical Layout Order (Top to Bottom):
1. **TopPlayerArea** (Player 2) - Height: 200px
2. **GameArea** (Chessboard + Score Panel)
3. **ScoreToggleContainer** (Toggle button)
4. **BottomPlayerArea** (Player 1) - Height: 200px

### Spacing
**Search:** `MainContainer` in scene file
**Property:** `separation` controls spacing between sections

---

## 8. Piece Images

### Asset Paths
```
res://assets/characters/character_1/pieces/
res://assets/characters/character_2/pieces/
res://assets/characters/character_3/pieces/
```

### File Naming
```
white_pawn.png
white_rook.png
white_knight.png
white_bishop.png
white_queen.png
white_king.png

black_pawn.png
black_rook.png
(etc.)
```

### Loading Function
**Search:** `func create_visual_piece()`

---

## 9. Game State Variables

### Global State File
**Path:** `scripts/game_state.gd`

### Key Variables to Modify:
**Search term:** `var player`

```gdscript
player1_character     # Character ID (0-2)
player2_character     # Character ID (0-2)
player1_score         # Points
player2_score         # Points
player_time_limit     # Time in seconds
player1_time_remaining
player2_time_remaining
move_count
captured_pieces
```

---

## 10. Common UI Adjustments

### Change Font Size
**Pattern to search:** `add_theme_font_size_override`

```gdscript
# Example:
label.add_theme_font_size_override("font_size", NEW_SIZE)
```

### Change Colors
**Pattern to search:** `modulate =` or `Color(`

```gdscript
# Example:
label.modulate = Color(1, 0, 0, 1)  # Red
```

### Change Size/Position
**In scene file (.tscn):**
- Search: `custom_minimum_size`
- Search: `size_flags_horizontal`
- Search: `size_flags_vertical`

### Change Margins/Padding
**In scene file (.tscn):**
- Search: `MarginContainer`
- Look for: `theme_override_constants`

---

## 11. Animation Timing

### Timer Updates
**Search:** `func update_timer_display()`
**Called by:** Timer nodes in scene

### Score Panel Animation
**Search:** `toggle_score_panel()`
**Duration:** 0.3 seconds

### Flash Effects
**Search:** `func flash_square_red()`
**Duration:** 0.5 seconds

---

## 12. Responsive Layout

### Screen Size
**File:** `project.godot`
**Search:** `display/window`

```
Current resolution: 1080x1920 (mobile portrait)
```

### Expansion Flags
**Scene file:** Search for `size_flags_horizontal` and `size_flags_vertical`

- ChessboardContainer: 3x horizontal expansion
- Player areas: Fixed height (200px)

---

## 13. Menu and Navigation

### Menu Button
**Location:** Inside `ScorePanel`
**Search in scene:** `node name="MenuButton"`

### Navigation Function
**File:** `scripts/main_game.gd`
**Search:** `_on_menu_button_pressed`

Returns to: `res://scenes/ui/login_page.tscn`

---

## 14. Node Path Reference

Quick copy-paste paths for accessing nodes in code:

```gdscript
# Chessboard
$MainContainer/GameArea/ChessboardContainer/MarginContainer/AspectRatioContainer/Chessboard

# Top Player Info
$MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/PlayerInfo

# Bottom Player Info
$MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/PlayerInfo

# Score Panel
$MainContainer/GameArea/ScorePanel

# Score Toggle Button
$MainContainer/ScoreToggleContainer/ScoreToggleButton

# Top Character Display
$MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/CharacterDisplay

# Bottom Character Display
$MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/CharacterDisplay
```

---

## 15. Debugging Tips

### Open Character Animation Debugger
**Press 'D' during gameplay**

Shows:
- Current animation states
- Available animations
- Play controls
- Media validation status

### Console Logging
**Search in script:** `print(` to find debug statements

### Validate Assets
**Search:** `validate_character_media()` or `validate_game_background()`

---

## Quick Search Cheat Sheet

| What to Adjust | Search This |
|----------------|-------------|
| Chessboard colors | `light_color` or `dark_color` |
| Player names | `PlayerName` |
| Timer colors | `update_timer_display` |
| Score panel | `ScorePanel` or `toggle_score_panel` |
| Character animations | `load_character_media` |
| Captured pieces | `update_captured_display` |
| Background | `load_random_background` |
| Font sizes | `add_theme_font_size_override` |
| Layout spacing | `MainContainer` in .tscn |
| Piece images | `create_visual_piece` |

---

## File Structure Summary

```
chess-thesis/
├── scenes/
│   └── game/
│       └── main_game.tscn          ← UI layout
├── scripts/
│   ├── main_game.gd                ← Main game logic
│   └── game_state.gd               ← Global state
├── assets/
│   ├── backgrounds/                ← Game backgrounds
│   └── characters/
│       ├── character_1/
│       ├── character_2/
│       └── character_3/
│           └── pieces/             ← Piece images
└── project.godot                   ← Project settings
```

---

## Need Help?

1. **For scene layout changes:** Edit `scenes/game/main_game.tscn`
2. **For behavior changes:** Edit `scripts/main_game.gd`
3. **For global settings:** Edit `scripts/game_state.gd`
4. **For visuals/assets:** Check `assets/` folders

Use Ctrl+F (or Cmd+F) with the search terms in this guide to quickly find the code you need to modify.
