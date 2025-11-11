# White Knight Hover Effect - Sizing & Functioning Functions

This document provides a comprehensive reference for all functions and parameters that control the sizing and behavior of the white knight hover effect scene.

**Scene File:** `assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn`

---

## Table of Contents
1. [Scene Structure & Built-in Parameters](#scene-structure--built-in-parameters)
2. [Core Sizing Functions](#core-sizing-functions)
3. [Scene Loading & Detection Functions](#scene-loading--detection-functions)
4. [Effect Application Functions](#effect-application-functions)
5. [Dynamic Scaling During Gameplay](#dynamic-scaling-during-gameplay)
6. [Particle System Parameters](#particle-system-parameters)
7. [Quick Reference Table](#quick-reference-table)

---

## Scene Structure & Built-in Parameters

### Root Node: `hovereffect_Scyka` (Node2D)
**File Location:** `hovereffect_scyka.tscn:97-98`

```gdscript
scale = Vector2(0.1, 0.1)
```

**Purpose:** Master scale for the entire hover effect
**Adjustable:** Yes - modify directly in scene file
**Impact:** Affects all child nodes (eyes, body, particles)
**Recommended Range:** 0.05 - 0.2

---

### Eye Animation (AnimatedSprite2D)
**File Location:** `hovereffect_scyka.tscn:100-111`

```gdscript
position = Vector2(0, -400)  # Eye position relative to root
scale = Vector2(0.8, 0.8)    # Eye sprite scale
```

**Animation Properties:**
- **Texture Atlas:** `eye.png` (5000x1000, split into 1000x1000 frames)
- **Frame Count:** 8 frames
- **Animation Speed:** 5.0 fps
- **Loop:** true

**Adjustable Parameters:**
- `position.y`: Vertical eye placement (-600 to -200)
- `scale`: Eye size (0.5 to 1.2 recommended)
- `speed`: Animation playback speed (1.0 to 10.0)

---

### Purple Piece Body (Sprite2D)
**File Location:** `hovereffect_scyka.tscn:117-120`

```gdscript
position = Vector2(0, 0)     # Body position
scale = Vector2(1.27, 1.27)  # Body scale
```

**Purpose:** Main visual body of the knight piece
**Texture:** `purple piece.png`
**Adjustable Parameters:**
- `scale`: Body size (1.0 to 2.0 recommended)
- `position`: Body offset for alignment

---

### Ghost Particles (GPUParticles2D)
**File Location:** `hovereffect_scyka.tscn:122-129`

```gdscript
position = Vector2(0, -100)
lifetime = 20.0
speed_scale = 5.0
randomness = 0.3
```

**Particle Process Material Parameters:**
- `emission_sphere_radius = 360.0` - Spawn area size
- `initial_velocity_min = 50.0` - Min particle speed
- `initial_velocity_max = 100.0` - Max particle speed
- `scale_max = 1.5` - Maximum particle size
- `linear_accel_min/max = 4.999/9.999` - Acceleration

**See:** [Particle System Parameters](#particle-system-parameters) for detailed adjustments

---

## Core Sizing Functions

### 1. `apply_drag_effects()`
**Location:** `scripts/piece_effects.gd:28-99`

```gdscript
func apply_drag_effects(piece_node: Node, piece_data: Dictionary = {}, square_size: float = 0.0)
```

**Purpose:** Swaps board piece to hover effect scene and scales it to fit the chess square

**Parameters:**
- `piece_node`: The chess piece container node
- `piece_data`: Dictionary containing `type`, `color`, `character_id`
- `square_size`: Size of the chess board square (critical for proper scaling)

**Scaling Logic:**
```gdscript
# Line 74-92
if square_size > 0.0:
    var texture_size = 200.0  # Default fallback

    # Search for Sprite2D to get actual texture size
    # Looks through scene instance and children

    var scale_factor = square_size / texture_size
    piece_node.scale = Vector2(scale_factor, scale_factor)
```

**Key Points:**
- Automatically detects texture size from scene
- Scales entire piece_node to fit square
- Default texture_size fallback: 200.0 pixels
- Formula: `scale_factor = square_size / texture_size`

**Where Called:** `scripts/main_game.gd:2809`

---

### 2. `remove_drag_effects()`
**Location:** `scripts/piece_effects.gd:100-136`

```gdscript
func remove_drag_effects(piece_node: Node)
```

**Purpose:** Removes hover effect scene and restores original board piece

**Process:**
1. Retrieves stored original piece data
2. Removes hover effect scene children
3. Recreates board piece using `ChessPieceSprite.create_piece_sprite()`
4. Restores original scaling and appearance

---

## Scene Loading & Detection Functions

### 3. `find_piece_scene()`
**Location:** `scripts/chess_piece_sprite.gd:21-54`

```gdscript
static func find_piece_scene(piece_type: String, character_id: int, is_held: bool) -> String
```

**Purpose:** Locates the hover effect scene file

**Search Path for White Knight:**
```
res://assets/characters/character_4/pieces/held/white_knight/scene/
```

**Searched Filenames (in order):**
1. `hovereffect_scyka.tscn` ✓ (Found for white knight)
2. `scene.tscn`
3. `piece.tscn`
4. `white_knight.tscn`

**Returns:** Full path to scene file or empty string if not found

---

### 4. `is_scene_based_piece()`
**Location:** `scripts/chess_piece_sprite.gd:159-164`

```gdscript
static func is_scene_based_piece(piece_type: String, character_id: int, is_held: bool = false) -> bool
```

**Purpose:** Checks if a piece uses a scene file instead of PNG

**Returns:** `true` if scene file exists (white knight returns `true`)

**Used By:** `piece_effects.gd:51` to determine if hover effect swap should occur

---

### 5. `create_piece_sprite()`
**Location:** `scripts/chess_piece_sprite.gd:67-134`

```gdscript
static func create_piece_sprite(piece_type: String, character_id: int, is_held: bool = false) -> Node2D
```

**Purpose:** Creates visual representation of chess piece

**Process for Scene-Based Pieces:**
1. Calls `find_piece_scene()` to locate scene file
2. Loads scene using `load(scene_path)`
3. Instantiates scene with `scene.instantiate()`
4. Adds to Node2D container
5. Returns container with scene

**Note:** This function creates the initial structure but does NOT handle square-based scaling

---

## Effect Application Functions

### 6. Board Piece Placement Scaling
**Location:** `scripts/main_game.gd:2301-2312`

```gdscript
# Scale the piece to fit the square based on actual texture size
var square_size = square.size.x
var texture_size = 200.0  # Default fallback size

# Get the actual texture size from the sprite
for child in piece_sprite.get_children():
    if child is Sprite2D and child.texture:
        texture_size = child.texture.get_size().x
        break

var scale_factor = square_size / texture_size
piece_sprite.scale = Vector2(scale_factor, scale_factor)
```

**Purpose:** Scales pieces when initially placed on the board

**Key Variables:**
- `square_size`: Determined by chessboard dimensions
- `texture_size`: Auto-detected or defaults to 200.0
- `scale_factor`: Calculated ratio

**Called During:** Initial board setup and piece placement

---

### 7. Drag Start Scaling
**Location:** `scripts/main_game.gd:2806-2809`

```gdscript
var square = board_squares[pos.x][pos.y]
var square_size = square.size.x
piece_effects.apply_drag_effects(piece_node, piece_data, square_size)
```

**Purpose:** Applies hover effect when piece is picked up

**Flow:**
1. Gets square size from board_squares array
2. Passes square_size to `apply_drag_effects()`
3. Hover effect scene is loaded and scaled appropriately

---

## Dynamic Scaling During Gameplay

### 8. Character Animation Debugger (Runtime Scaling)
**Location:** `scripts/main_game.gd:528-540` (Player 1), `573-585` (Player 2)

**Note:** This controls Live2D character scaling, NOT piece hover effects

```gdscript
# Scale slider for character animations
var p1_scale_slider = HSlider.new()
p1_scale_slider.min_value = 0.5
p1_scale_slider.max_value = 3.0
p1_scale_slider.step = 0.1
p1_scale_slider.value = 1.0
```

**Purpose:** Runtime adjustment of character animations (not hover effects)
**Access:** Press 'D' during gameplay to open debugger

---

### 9. Live2D Model Scaling
**Location:** `scripts/main_game.gd:1449` and `1590`

```gdscript
live2d_model.scale = Vector2(1.0/7.0, 1.0/7.0)  # Character 4
live2d_model.scale = Vector2(2.0/7.0, 2.0/7.0)  # Other characters
```

**Purpose:** Sets default scale for Live2D character models

**To Adjust:**
- Increase numerator for larger: `Vector2(3.0/7.0, 3.0/7.0)`
- Decrease numerator for smaller: `Vector2(0.5/7.0, 0.5/7.0)`

**Note:** Affects character display, not piece hover effects

---

## Particle System Parameters

### Adjustable Particle Properties
**Location:** `hovereffect_scyka.tscn:78-95`

```gdscript
[sub_resource type="ParticleProcessMaterial" id="ParticleProcessMaterial_krfyl"]
lifetime_randomness = 0.5
particle_flag_align_y = true
particle_flag_rotate_y = true
particle_flag_disable_z = true
emission_shape = 1
emission_sphere_radius = 360.0
angle_min = 1.0728835e-05
angle_max = 1.0728835e-05
spread = 180.0
initial_velocity_min = 50.0
initial_velocity_max = 100.0
gravity = Vector3(0, 0, 0)
linear_accel_min = 4.9999976
linear_accel_max = 9.999997
scale_max = 1.5
```

### Particle Sizing Parameters

| Parameter | Current Value | Purpose | Recommended Range |
|-----------|---------------|---------|-------------------|
| `emission_sphere_radius` | 360.0 | Spawn area size | 200-500 |
| `initial_velocity_min` | 50.0 | Min particle speed | 20-100 |
| `initial_velocity_max` | 100.0 | Max particle speed | 50-200 |
| `scale_max` | 1.5 | Max particle size | 0.5-3.0 |
| `linear_accel_min` | 5.0 | Min acceleration | 0-20 |
| `linear_accel_max` | 10.0 | Max acceleration | 5-30 |

### Main Particle Node Parameters

| Parameter | Current Value | Purpose | Recommended Range |
|-----------|---------------|---------|-------------------|
| `position` | Vector2(0, -100) | Particle spawn point | Y: -200 to 0 |
| `lifetime` | 20.0 | Particle lifespan (seconds) | 10-40 |
| `speed_scale` | 5.0 | Overall speed multiplier | 1-10 |
| `randomness` | 0.3 | Variation in timing | 0.0-1.0 |

---

## Quick Reference Table

### Primary Sizing Controls

| What to Adjust | File | Line | Variable/Node | Impact |
|----------------|------|------|---------------|--------|
| **Overall hover effect size** | `hovereffect_scyka.tscn` | 98 | Root node `scale` | Entire effect |
| **Eye size** | `hovereffect_scyka.tscn` | 103 | Eye `scale` | Eye sprite only |
| **Eye position** | `hovereffect_scyka.tscn` | 102 | Eye `position` | Eye placement |
| **Body size** | `hovereffect_scyka.tscn` | 119 | PurplePiece `scale` | Main body sprite |
| **Particle spawn area** | `hovereffect_scyka.tscn` | 84 | `emission_sphere_radius` | Ghost particle spread |
| **Particle size** | `hovereffect_scyka.tscn` | 93 | `scale_max` | Individual particle size |
| **Dynamic square fitting** | `piece_effects.gd` | 90-91 | `scale_factor` calculation | Auto-scaling to board |
| **Default texture size** | `piece_effects.gd` | 75 | `texture_size` fallback | Scaling calculation base |

### Function Call Chain (When Piece is Dragged)

```
User clicks piece
    ↓
main_game.gd:_on_board_square_clicked()
    ↓
main_game.gd:2809 → piece_effects.apply_drag_effects(piece_node, piece_data, square_size)
    ↓
piece_effects.gd:51 → ChessPieceSprite.is_scene_based_piece() [Check if scene exists]
    ↓
piece_effects.gd:65 → ChessPieceSprite.find_piece_scene() [Get scene path]
    ↓
piece_effects.gd:67-71 → load() + instantiate() [Load hover effect scene]
    ↓
piece_effects.gd:74-92 → Calculate and apply scale_factor
    ↓
Hover effect displayed at correct size
```

---

## Common Adjustments

### Make the entire hover effect bigger/smaller
**Edit:** `hovereffect_scyka.tscn` line 98
```gdscript
# Current
scale = Vector2(0.1, 0.1)

# Larger (2x)
scale = Vector2(0.2, 0.2)

# Smaller (half)
scale = Vector2(0.05, 0.05)
```

### Adjust purple knight body size independently
**Edit:** `hovereffect_scyka.tscn` line 119
```gdscript
# Current
scale = Vector2(1.27, 1.27)

# Larger
scale = Vector2(1.5, 1.5)

# Smaller
scale = Vector2(1.0, 1.0)
```

### Change particle density
**Edit:** `hovereffect_scyka.tscn` line 84
```gdscript
# Current (360 pixel radius)
emission_sphere_radius = 360.0

# More concentrated
emission_sphere_radius = 200.0

# More spread out
emission_sphere_radius = 500.0
```

### Adjust automatic square-fitting behavior
**Edit:** `scripts/piece_effects.gd` line 75
```gdscript
# Current fallback
var texture_size = 200.0

# If hover effect appears too small
var texture_size = 150.0  # Will scale UP more

# If hover effect appears too large
var texture_size = 250.0  # Will scale DOWN more
```

---

## Notes & Best Practices

1. **Scene scale vs. Runtime scale:**
   - Scene file `scale` (line 98) is the base size
   - Runtime `scale_factor` (piece_effects.gd:90) adjusts to fit board squares
   - Final size = `scene_scale × scale_factor`

2. **Texture size detection:**
   - System auto-detects texture size from Sprite2D nodes
   - Searches through scene hierarchy for first Sprite2D with texture
   - Falls back to 200.0 if no texture found

3. **Coordinate system:**
   - All positions are relative to parent node
   - Negative Y moves UP (Y-axis inverted in 2D)
   - Center is (0, 0)

4. **Testing changes:**
   - Modify scene file values
   - Save the scene
   - Pick up white knight in-game to see effect
   - No code recompilation needed for scene changes

5. **Character-specific paths:**
   - Character 4 is hardcoded in path: `character_4/pieces/held/white_knight/`
   - Other characters follow same pattern: `character_X/pieces/held/white_PIECE/`

---

## Related Documentation

- `scripts/piece_effects.gd` - Main hover effect system
- `scripts/chess_piece_sprite.gd` - Piece loading and scene detection
- `scripts/main_game.gd` - Board setup and piece placement
- `PIECE_EFFECTS_README.md` - General piece effects documentation

---

**Last Updated:** 2025-11-11
**Scene File Version:** hovereffect_scyka.tscn (Character 4 - White Knight)
