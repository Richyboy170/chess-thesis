# Chess Piece Sprite System

## Overview

The Chess Piece Sprite system provides a unified way to create and manage chess piece visual representations using Sprite2D nodes. It intelligently handles two types of piece art:

1. **PNG-based pieces**: Simple image files (used by most pieces)
2. **Scene-based pieces**: Complex animated scenes with effects (e.g., Character 4's white_knight)

## Architecture

### File: `scripts/chess_piece_sprite.gd`

This script provides static methods for creating chess piece sprites with automatic detection and handling of PNG vs scene-based art.

### Key Methods

#### `create_piece_sprite(piece_type, character_id, is_held)`

Creates a Node2D containing the appropriate visual representation for a chess piece.

**Parameters:**
- `piece_type` (String): The piece type ("pawn", "knight", "bishop", "rook", "queen", "king")
- `character_id` (int): The character ID (1-4)
- `is_held` (bool): Whether this is a held piece (default: false)

**Returns:** Node2D containing either:
- A Sprite2D child with the PNG texture, OR
- An instantiated scene (for special pieces like white_knight)

**Example:**
```gdscript
# Create a regular board piece
var pawn = ChessPieceSprite.create_piece_sprite("pawn", 1, false)
pawn.position = Vector2(100, 100)
add_child(pawn)

# Create a held piece
var queen = ChessPieceSprite.create_piece_sprite("queen", 2, true)
queen.position = Vector2(200, 200)
add_child(queen)
```

#### `create_held_piece_sprite(piece_type, character_id)`

Convenience method for creating held pieces.

**Example:**
```gdscript
var held_knight = ChessPieceSprite.create_held_piece_sprite("knight", 4)
add_child(held_knight)
```

#### `is_scene_based_piece(piece_type, character_id, is_held)`

Checks whether a piece uses a scene file instead of a PNG.

**Returns:** `true` if scene-based, `false` if PNG-based

**Example:**
```gdscript
if ChessPieceSprite.is_scene_based_piece("knight", 4, true):
    print("This piece uses a scene!")
```

#### `get_piece_path(piece_type, character_id, is_held)`

Returns the file path for a piece (PNG or scene).

**Returns:** String path to the asset file

## If-Else Pattern

The system uses an if-else pattern to handle PNG vs scene-based pieces:

```gdscript
# Inside create_piece_sprite method:

if is_held and piece_type == "knight" and character_id == 4:
    # SCENE-BASED: Load and instantiate the white_knight scene
    var knight_scene_path = "res://assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn"
    var knight_scene = load(knight_scene_path)
    var scene_instance = knight_scene.instantiate()
    container.add_child(scene_instance)
    return container
else:
    # PNG-BASED: Load texture and apply to Sprite2D
    var sprite = Sprite2D.new()
    var piece_path = "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id, piece_type]
    var texture = load(piece_path)
    sprite.texture = texture
    container.add_child(sprite)
    return container
```

## Asset Structure

### PNG-Based Pieces (Standard)

Most pieces use simple PNG files:

```
assets/characters/character_X/pieces/
├── white_pawn.png
├── white_knight.png
├── white_bishop.png
├── white_rook.png
├── white_queen.png
├── white_king.png
└── held/
    ├── white_pawn.png
    ├── white_knight.png
    ├── white_bishop.png
    ├── white_rook.png
    ├── white_queen.png
    └── white_king.png
```

### Scene-Based Pieces (Special)

Character 4's white_knight uses a scene:

```
assets/characters/character_4/pieces/held/white_knight/
├── eye.png (sprite sheet)
├── ghost.png (particle texture)
├── ghost flip.png
├── purple piece.png (main body)
└── scene/
    └── hovereffect_scyka.tscn ← Scene with animations and effects
```

**Scene Structure:**
- **Eye (AnimatedSprite2D)**: Animated blinking eyes
- **Body (Sprite2D)**: Purple knight piece
- **Ghosts (GPUParticles2D)**: Floating ghost particles

## Usage Examples

### Example 1: Creating Board Pieces

```gdscript
func setup_chess_board():
    # Create various pieces
    var pieces = [
        {"type": "pawn", "char": 1, "pos": Vector2(100, 100)},
        {"type": "knight", "char": 2, "pos": Vector2(200, 100)},
        {"type": "queen", "char": 3, "pos": Vector2(300, 100)},
    ]

    for piece_info in pieces:
        var piece = ChessPieceSprite.create_piece_sprite(
            piece_info.type,
            piece_info.char,
            false  # Board piece
        )
        piece.position = piece_info.pos
        add_child(piece)
```

### Example 2: Handling Held Pieces

```gdscript
func on_piece_picked_up(piece_type: String, character_id: int):
    # Create held piece sprite
    var held_sprite = ChessPieceSprite.create_held_piece_sprite(piece_type, character_id)
    held_sprite.position = get_global_mouse_position()

    # Check if it's scene-based for special handling
    if ChessPieceSprite.is_scene_based_piece(piece_type, character_id, true):
        print("Scene-based piece! Has built-in animations.")
        # No need to add effects - scene has them
    else:
        print("PNG-based piece. Adding effects...")
        # Add custom effects (glow, scale, etc.)
        apply_custom_effects(held_sprite)

    add_child(held_sprite)
```

### Example 3: Comparing Different Characters

```gdscript
func create_knight_comparison():
    # PNG-based knight (Character 1)
    var png_knight = ChessPieceSprite.create_held_piece_sprite("knight", 1)
    png_knight.position = Vector2(100, 100)
    add_child(png_knight)

    # Scene-based knight (Character 4)
    var scene_knight = ChessPieceSprite.create_held_piece_sprite("knight", 4)
    scene_knight.position = Vector2(300, 100)
    add_child(scene_knight)

    # The scene-based knight automatically has:
    # - Animated blinking eyes
    # - Floating ghost particles
    # - Layered sprite effects
```

## Integration with Existing Systems

### Integration with piece_effects.gd

The ChessPieceSprite system complements the existing `piece_effects.gd`:

- **ChessPieceSprite**: Creates the initial piece visual (Sprite2D or scene)
- **piece_effects.gd**: Applies drag effects, glows, and transitions

Both systems use the same if-else pattern to detect scene-based pieces:

```gdscript
# In piece_effects.gd
if piece_type == "knight" and character_id == 4:
    # Skip standard effects - scene has built-in effects
    return

# In chess_piece_sprite.gd
if is_held and piece_type == "knight" and character_id == 4:
    # Load scene instead of PNG
    return scene_instance
```

### Integration with main_game.gd

Replace TextureRect-based piece creation with Sprite2D-based:

**Before (TextureRect):**
```gdscript
var piece_texture_rect = TextureRect.new()
piece_texture_rect.texture = load(piece_image_path)
add_child(piece_texture_rect)
```

**After (Sprite2D with ChessPieceSprite):**
```gdscript
var piece_sprite = ChessPieceSprite.create_piece_sprite(piece_type, character_id)
add_child(piece_sprite)
```

## Benefits

1. **Unified Interface**: Single method to create any piece type
2. **Automatic Detection**: Automatically detects PNG vs scene-based pieces
3. **Type Safety**: Uses Sprite2D nodes instead of TextureRect for better performance
4. **Extensible**: Easy to add new scene-based pieces for other characters
5. **Clean Code**: Centralizes piece creation logic in one place

## Future Extensions

### Adding New Scene-Based Pieces

To add a new scene-based piece:

1. Create the scene file (e.g., `white_queen/scene/queen_effect.tscn`)
2. Update `is_scene_based_piece()` method:
```gdscript
if is_held and piece_type == "queen" and character_id == 4:
    var scene_path = "res://assets/characters/character_4/pieces/held/white_queen/scene/queen_effect.tscn"
    return FileAccess.file_exists(scene_path)
```
3. Update `create_piece_sprite()` if-else logic similarly

### Supporting Other Characters

The system is designed to support scene-based pieces for any character:

```gdscript
# Example: Character 2 bishop scene
if is_held and piece_type == "bishop" and character_id == 2:
    var bishop_scene_path = "res://assets/characters/character_2/pieces/held/white_bishop/scene/bishop_effect.tscn"
    # Load and instantiate...
```

## Demo

Run the demo scene to see the system in action:

```
examples/chess_piece_sprite_demo.tscn
```

The demo shows:
- Creating PNG-based pieces (standard)
- Creating the white_knight scene (Character 4)
- Comparing different piece types
- Using the if-else pattern
- Checking piece types programmatically

## Technical Notes

### Node Structure

**PNG-based pieces:**
```
Node2D (container)
└── Sprite2D (piece visual)
```

**Scene-based pieces:**
```
Node2D (container)
└── [Scene Instance] (e.g., white_knight scene)
    ├── AnimatedSprite2D (eyes)
    ├── Sprite2D (body)
    └── GPUParticles2D (effects)
```

### Performance

- PNG-based pieces: Lightweight Sprite2D nodes
- Scene-based pieces: More complex but contained in single scene
- Both use texture caching via `load()` for efficiency

### Error Handling

The system includes comprehensive error handling:
- File existence checks before loading
- Fallback to regular pieces if held piece not found
- Error messages via `push_error()` and `push_warning()`
- Returns empty container instead of null on failure

## Summary

The Chess Piece Sprite system provides a robust, extensible solution for managing chess piece visuals with support for both simple PNG images and complex animated scenes. The if-else pattern ensures the correct handling for each piece type while maintaining a clean, unified API.
