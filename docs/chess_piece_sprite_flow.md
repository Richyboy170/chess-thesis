# Chess Piece Sprite System - Flow Diagram

## Main Flow: create_piece_sprite()

```
┌─────────────────────────────────────────────────────────────┐
│  create_piece_sprite(piece_type, character_id, is_held)    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
            ┌─────────────────────────────┐
            │  Create Node2D container    │
            │  (holds the visual)         │
            └─────────────┬───────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │  Is this a scene-based piece?       │
        │                                     │
        │  CHECK:                             │
        │  • is_held == true?                 │
        │  • piece_type == "knight"?          │
        │  • character_id == 4?               │
        └─────────┬───────────────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼ YES               ▼ NO
  ┌──────────────┐    ┌──────────────────┐
  │ SCENE-BASED  │    │   PNG-BASED      │
  │   PIECE      │    │     PIECE        │
  └──────┬───────┘    └────────┬─────────┘
         │                     │
         ▼                     ▼
```

### SCENE-BASED BRANCH (White Knight - Character 4)

```
┌────────────────────────────────────────────────────────┐
│  Load scene file:                                      │
│  "character_4/pieces/held/white_knight/scene/          │
│   hovereffect_scyka.tscn"                             │
└─────────────────────┬──────────────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────┐
        │  Does scene file exist? │
        └────────┬────────────────┘
                 │
        ┌────────┴────────┐
        ▼ YES             ▼ NO
  ┌─────────────┐   ┌─────────────────┐
  │ Load scene  │   │ Print warning   │
  │ using       │   │ Fall through to │
  │ load()      │   │ PNG branch      │
  └──────┬──────┘   └────────┬────────┘
         │                   │
         ▼                   │
  ┌──────────────┐           │
  │ Instantiate  │           │
  │ scene        │           │
  └──────┬───────┘           │
         │                   │
         ▼                   │
  ┌──────────────────┐       │
  │ Add to container │       │
  └──────┬───────────┘       │
         │                   │
         └───────┬───────────┘
                 │
                 ▼
        ┌────────────────┐
        │ Return         │
        │ container with │
        │ SCENE CHILD    │
        └────────────────┘

  Scene Contains:
  ├── Eye (AnimatedSprite2D)
  │   └── 8-frame blinking animation
  ├── Body (Sprite2D)
  │   └── Purple knight piece
  └── Ghosts (GPUParticles2D)
      └── Floating ghost effects
```

### PNG-BASED BRANCH (All Other Pieces)

```
┌────────────────────────────────────────────────────────┐
│  Determine PNG path:                                   │
│                                                        │
│  IF is_held == true:                                   │
│    "character_X/pieces/held/white_PIECE.png"          │
│  ELSE:                                                 │
│    "character_X/pieces/white_PIECE.png"               │
└─────────────────────┬──────────────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────┐
        │  Does PNG file exist?   │
        └────────┬────────────────┘
                 │
        ┌────────┴────────┐
        ▼ YES             ▼ NO (held piece not found)
  ┌─────────────┐   ┌───────────────────────┐
  │ Use this    │   │ Try regular piece PNG │
  │ PNG path    │   │ (fallback)            │
  └──────┬──────┘   └────────┬──────────────┘
         │                   │
         └──────────┬────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  Load texture using   │
        │  load()               │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  Create Sprite2D      │
        │  sprite.texture = tex │
        │  sprite.centered=true │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  Add sprite to        │
        │  container            │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  Return               │
        │  container with       │
        │  SPRITE2D CHILD       │
        └───────────────────────┘
```

## If-Else Decision Tree

```
                    START
                      │
                      ▼
        ┌─────────────────────────┐
        │   is_held == true?      │
        └─────────┬───────────────┘
                  │
         ┌────────┴────────┐
         │                 │
        YES               NO
         │                 │
         ▼                 ▼
    ┌─────────┐     ┌──────────────┐
    │ Is it   │     │ LOAD REGULAR │
    │ knight? │     │ BOARD PIECE  │
    └────┬────┘     │ (PNG)        │
         │          └──────────────┘
    ┌────┴────┐
   YES       NO
    │         │
    ▼         ▼
┌────────┐ ┌──────────┐
│ Is it  │ │ LOAD     │
│ char 4?│ │ HELD PNG │
└───┬────┘ └──────────┘
    │
┌───┴───┐
│      YES
│       │
▼       ▼
LOAD   LOAD
HELD   SCENE
PNG    (.tscn)
```

## Code Comparison

### Old System (TextureRect)

```gdscript
# Old way - TextureRect with manual path construction
var piece_texture_rect = TextureRect.new()
var piece_image_path = "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id + 1, piece_type_name]

if FileAccess.file_exists(piece_image_path):
    var texture = load(piece_image_path)
    if texture:
        piece_texture_rect.texture = texture
        piece_texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
        piece_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        # ... more setup code
```

### New System (Sprite2D with ChessPieceSprite)

```gdscript
# New way - Automatic handling of PNG and scenes
var piece_sprite = ChessPieceSprite.create_piece_sprite(piece_type, character_id, is_held)

# That's it! The system automatically:
# ✓ Detects if it's PNG or scene-based
# ✓ Loads the correct asset
# ✓ Creates proper node structure
# ✓ Handles fallbacks
# ✓ Returns ready-to-use container
```

## The If-Else Pattern in Code

```gdscript
# The core if-else logic in create_piece_sprite()

if is_held and piece_type == "knight" and character_id == 4:
    # ═══════════════════════════════════════════════
    # BRANCH A: SCENE-BASED PIECE (White Knight C4)
    # ═══════════════════════════════════════════════
    var scene_path = "res://assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn"

    if FileAccess.file_exists(scene_path):
        var scene = load(scene_path)
        if scene:
            var scene_instance = scene.instantiate()
            scene_instance.name = "WhiteKnightScene"
            container.add_child(scene_instance)
            print("Created scene-based piece: white_knight")
            return container

else:
    # ═══════════════════════════════════════════════
    # BRANCH B: PNG-BASED PIECE (All Others)
    # ═══════════════════════════════════════════════
    var sprite = Sprite2D.new()
    sprite.name = "PieceSprite"

    # Build path based on held vs board piece
    var piece_path = ""
    if is_held:
        piece_path = "res://assets/characters/character_%d/pieces/held/white_%s.png" % [character_id, piece_type]
        # Fallback to regular if held doesn't exist
        if not FileAccess.file_exists(piece_path):
            piece_path = "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id, piece_type]
    else:
        piece_path = "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id, piece_type]

    # Load and apply texture
    if FileAccess.file_exists(piece_path):
        var texture = load(piece_path)
        if texture:
            sprite.texture = texture
            sprite.centered = true
            container.add_child(sprite)
            print("Created PNG-based piece: %s" % piece_type)
            return container

# Return container (may be empty if loading failed)
return container
```

## Decision Matrix

| Piece Type | Character | is_held | Result Type | Asset Path |
|-----------|-----------|---------|-------------|------------|
| knight    | 4         | true    | **SCENE**   | `character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn` |
| knight    | 4         | false   | PNG         | `character_4/pieces/white_knight.png` |
| knight    | 1-3       | true    | PNG         | `character_X/pieces/held/white_knight.png` |
| knight    | 1-3       | false   | PNG         | `character_X/pieces/white_knight.png` |
| pawn      | any       | any     | PNG         | `character_X/pieces/[held/]white_pawn.png` |
| queen     | any       | any     | PNG         | `character_X/pieces/[held/]white_queen.png` |
| king      | any       | any     | PNG         | `character_X/pieces/[held/]white_king.png` |
| rook      | any       | any     | PNG         | `character_X/pieces/[held/]white_rook.png` |
| bishop    | any       | any     | PNG         | `character_X/pieces/[held/]white_bishop.png` |

## Node Hierarchy Comparison

### PNG-Based Piece Node Tree
```
Node2D (Container "PieceSprite_knight")
└─ Sprite2D (PieceSprite)
   └─ texture: white_knight.png
```

### Scene-Based Piece Node Tree
```
Node2D (Container "PieceSprite_knight")
└─ Node2D (WhiteKnightScene - instantiated from hovereffect_scyka.tscn)
   ├─ AnimatedSprite2D (Eye) [z_index: 1]
   │  └─ AnimatedSprite2D (Eye child)
   ├─ Sprite2D (Body) [z_index: 2]
   │  └─ Sprite2D (PurplePiece)
   │     └─ texture: purple piece.png
   └─ GPUParticles2D (Ghosts) [z_index: 1]
      └─ texture: ghost flip.png
```

## Summary

The if-else pattern provides:

1. **Automatic Detection**: One line of code to check: `is_held and piece_type == "knight" and character_id == 4`

2. **Branching Logic**:
   - **IF** condition is true → Load scene, instantiate, add to container
   - **ELSE** (default) → Load PNG, create Sprite2D, add to container

3. **Graceful Fallback**: If scene file not found, falls through to PNG branch

4. **Extensible Design**: Easy to add more scene-based pieces by adding more conditions

5. **Single Return Point**: Both branches return the same Node2D container type, making it easy to use in game code
