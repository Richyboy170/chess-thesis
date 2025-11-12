# CLAUDE.md - Development Guide for Chess Thesis Project

This document provides comprehensive guidance for AI assistants (Claude) working on this chess game project. It outlines project structure, architecture patterns, coding conventions, and development preferences.

---

## Project Overview

**Chess Thesis** is a mobile chess game built with Godot Engine 4.5+ featuring:
- Character-based chess gameplay with 4 unique themes
- Live2D Cubism integration for animated characters
- Full chess rule implementation with move validation
- Mobile-optimized UI (1080x1920 portrait)
- Real-time statistics and move history tracking

**Target Platform:** Mobile (Android/iOS)
**Engine:** Godot 4.5
**Primary Language:** GDScript
**Project Size:** 736 MB (includes assets and plugins)

---

## Project Structure

```
chess-thesis/
├── scripts/                      # Core game logic (40 GDScript files)
│   ├── game_state.gd            # Global state manager (autoload)
│   ├── chess_board.gd           # Chessboard logic & move validation
│   ├── chess_piece.gd           # Base chess piece class
│   ├── chess_pieces.gd          # Piece implementations (Pawn, Rook, etc.)
│   ├── main_game.gd             # Main game scene (2000+ lines)
│   ├── character_selection.gd   # Character selection UI
│   ├── theme_manager.gd         # Font and theme management (autoload)
│   ├── chessboard_storage.gd    # Global board instance (autoload)
│   ├── chessboard_factory.gd    # Board creation with validation
│   └── [other utility scripts]
│
├── scenes/                       # Godot scene files (.tscn)
│   ├── ui/                      # UI scenes (login, character selection)
│   ├── game/                    # Main game scene
│   ├── debug/                   # Debug and testing scenes
│   └── sandbox/                 # Live2D model testing
│
├── assets/                       # Game assets
│   ├── characters/              # 4 character themes (3 static + 1 Live2D)
│   ├── backgrounds/             # Background images
│   ├── chessboards/             # Chessboard theme images
│   └── fonts/                   # Custom fonts (Bangers-Regular.ttf)
│
├── addons/                       # Godot plugins
│   └── gd_cubism/               # Live2D Cubism SDK v0.9.1
│
├── project.godot                 # Godot engine configuration
├── README.md                     # Main project documentation
└── LIVE2D_SETUP.md              # Live2D plugin setup guide
```

---

## Architecture & Design Patterns

### Core Architectural Patterns

1. **Singleton Pattern (Autoload)**
   - Used for global state and service management
   - Key singletons:
     - `GameState` - Centralized game state
     - `ThemeManager` - Font and theme management
     - `ChessboardStorage` - Global board instance
     - `PieceEffects` - Visual effects management
     - `AnimationErrorDetector` - Error tracking
     - `GDExtensionErrorDetector` - Plugin tracking

2. **Factory Pattern**
   - `ChessboardFactory` - Creates validated chessboard instances
   - `ChessPieceSprite` - Creates piece visuals (PNG or scene-based)

3. **Class-Based Inheritance**
   - `ChessPiece` base class with specialized subclasses:
     - `ChessPieces.Pawn`, `ChessPieces.Rook`, `ChessPieces.Knight`
     - `ChessPieces.Bishop`, `ChessPieces.Queen`, `ChessPieces.King`

4. **Observer Pattern (Signals)**
   - Heavy use of Godot's signal system for event-driven architecture
   - `ChessBoard` emits: `piece_moved`, `piece_captured`, `turn_changed`, `game_over`, `check_detected`

5. **State Machine (Implicit)**
   - Game flow: Login → Character Selection → Main Game
   - Piece states: Selected/Unselected, Held/Released
   - Turn states: White/Black

### Component Organization

**Separation of Concerns:**
- **Logic Layer:** Chess rules, move validation (`chess_board.gd`, `chess_piece.gd`)
- **State Layer:** Game state management (`game_state.gd`, `chessboard_storage.gd`)
- **Presentation Layer:** UI rendering, animations (`main_game.gd`, scene files)
- **Factory Layer:** Object creation with validation (`chessboard_factory.gd`)

---

## Development Preferences

### Code Style & Conventions

**File Organization:**
- Scripts in `/scripts/` directory
- Scene files in `/scenes/` organized by category (ui, game, debug)
- Assets in `/assets/` organized by type (characters, backgrounds, etc.)

**Naming Conventions:**
- **Files:** snake_case (e.g., `chess_board.gd`, `main_game.tscn`)
- **Classes:** PascalCase (e.g., `ChessBoard`, `ChessPiece`)
- **Variables/Functions:** snake_case (e.g., `get_valid_moves()`, `current_turn`)
- **Constants:** UPPER_SNAKE_CASE (e.g., `PIECE_WHITE`, `BOARD_SIZE`)
- **Signals:** snake_case (e.g., `piece_moved`, `turn_changed`)

**GDScript Conventions:**
- Use type hints for all function parameters and return types
- Prefer composition over inheritance where appropriate
- Use signals for loose coupling between components
- Document complex functions with comments
- Keep functions focused and single-responsibility

**Example:**
```gdscript
# Good
func get_valid_moves(board: ChessBoard) -> Array[Vector2i]:
    var valid_moves: Array[Vector2i] = []
    # Implementation
    return valid_moves

# Bad (no type hints)
func get_valid_moves(board):
    var valid_moves = []
    return valid_moves
```

### Architecture Preferences

**When Adding New Features:**

1. **Use Existing Patterns:**
   - Follow established singleton pattern for global state
   - Use factory pattern for object creation with validation
   - Emit signals for cross-component communication

2. **Maintain Separation:**
   - Keep game logic separate from UI rendering
   - Use `GameState` for persistent data
   - Use scene-specific scripts for UI behavior

3. **Validation:**
   - Validate inputs at creation time (factory pattern)
   - Use validator classes for complex validation logic
   - Handle errors gracefully with clear error messages

4. **Mobile-First:**
   - Always consider touch input (no mouse-only interactions)
   - Test responsive layouts at 1080x1920 resolution
   - Optimize for mobile rendering pipeline

### File References

**When referencing code locations:**
- Use format: `file_path:line_number`
- Example: "The board creation logic is in scripts/chessboard_factory.gd:45"

**When reading files:**
- Always read existing files before modifying them
- Use the Read tool to understand current implementation
- Preserve existing code style and patterns

**When editing files:**
- Prefer Edit tool over Write for existing files
- Maintain consistent indentation (tabs in GDScript)
- Preserve existing comments and documentation

---

## Key Components Reference

### Core Game Logic

| Component | File | Responsibility |
|-----------|------|----------------|
| **GameState** | scripts/game_state.gd | Stores player selections, scores, timers, move history |
| **ChessBoard** | scripts/chess_board.gd | Manages 8x8 board state, move validation, turn logic |
| **ChessPiece** | scripts/chess_piece.gd | Base class with type, color, position, movement rules |
| **ChessPieces** | scripts/chess_pieces.gd | 6 piece classes with unique movement logic |
| **ChessboardStorage** | scripts/chessboard_storage.gd | Global singleton for board instance management |
| **ChessboardFactory** | scripts/chessboard_factory.gd | Creates boards with validation |

### UI & Rendering

| Component | File | Responsibility |
|-----------|------|----------------|
| **MainGame** | scripts/main_game.gd | Main game scene (2000+ lines) - board rendering, piece dragging, UI |
| **CharacterSelection** | scripts/character_selection.gd | Character selection UI with previews |
| **LoginPage** | scripts/login_page.gd | Landing page with timer configuration |
| **ThemeManager** | scripts/theme_manager.gd | Centralized font sizes and theme application |
| **BoardThemeLoader** | scripts/board_theme_loader.gd | Loads chessboard colors per character |
| **ChessPieceSprite** | scripts/chess_piece_sprite.gd | Creates visual piece representations |

### Animation & Effects

| Component | File | Responsibility |
|-----------|------|----------------|
| **PieceEffects** | scripts/piece_effects.gd | Scene-based held piece animations |
| **Live2DAnimationConfig** | scripts/live2d_animation_config.gd | Live2D character animation config |
| **Live2DDebugger** | scripts/live2d_debugger.gd | Live2D model debugging tools |
| **AnimationErrorDetector** | scripts/animation_error_detector.gd | Tracks animation loading errors |

---

## Common Development Tasks

### Adding a New Chess Feature

1. **Modify chess logic** in `scripts/chess_board.gd` or `scripts/chess_pieces.gd`
2. **Update GameState** if persistent data is needed (`scripts/game_state.gd`)
3. **Update UI** in `scripts/main_game.gd` to reflect changes
4. **Test** using debug scenes or manual gameplay
5. **Update README.md** if it's a major feature

### Adding a New Character

1. **Create character directory:** `assets/characters/character_N/`
2. **Add required assets:**
   - Piece images (PNG) or scene files (.tscn)
   - Animations (MP4, WebM, OGV, or GIF)
   - Background images
3. **Update GameState** character data dictionary
4. **Add theme configuration** to `BoardThemeLoader`
5. **Test** in character selection scene

### Modifying UI Layout

1. **Read existing scene** file first (`.tscn` in `scenes/` directory)
2. **Check main_game.gd** top comments for UI adjustment guide
3. **Maintain responsive design** for 1080x1920 portrait
4. **Test** with different screen sizes if possible
5. **Use ThemeManager** for consistent font sizing

### Adding Live2D Animations

1. **Place model files** in `assets/characters/character_N/`
2. **Configure** in `scripts/live2d_animation_config.gd`
3. **Test** using `scenes/sandbox/model_test.tscn`
4. **Debug** with Live2DDebugger (press 'D' in game)
5. **Refer to** LIVE2D_SETUP.md for plugin requirements

---

## Testing & Debugging

### Debug Features

**Built-in Debug Tools:**
- Press **'D'** during gameplay to toggle Live2D animation debugger
- Use `scenes/debug/asset_path_checker.tscn` for asset path validation
- Use `scenes/sandbox/model_test.tscn` for Live2D model testing
- Check `AnimationErrorDetector` singleton for animation errors
- Check `GDExtensionErrorDetector` singleton for plugin errors

**Manual Testing Approach:**
- No formal unit testing framework
- Test through gameplay and debug scenes
- Validate chess moves manually
- Check UI responsiveness at target resolution (1080x1920)

### Common Issues

**Live2D Not Loading:**
1. Check GDCubism plugin is enabled in Project Settings
2. Verify platform-specific binaries exist in `addons/gd_cubism/bin/`
3. Check `GDExtensionErrorDetector` for error messages
4. Review LIVE2D_SETUP.md for installation steps

**Asset Path Issues:**
- Use `scenes/debug/asset_path_checker.tscn` to validate paths
- Ensure paths use Godot format: `res://assets/...`
- Check asset exists in correct directory

**Chess Move Validation:**
- Review `chess_board.gd` move validation logic
- Check piece-specific `get_valid_moves()` in `chess_pieces.gd`
- Verify board state in debugger

---

## Documentation Standards

### Code Documentation

**Required Comments:**
- Complex algorithms or chess logic
- Non-obvious design decisions
- Public API functions (especially in autoload scripts)
- UI adjustment guides (see top of `main_game.gd`)

**Example:**
```gdscript
# Calculates all valid moves for this piece on the given board
# Takes into account piece movement rules, board boundaries, and captures
# Returns: Array of Vector2i positions representing valid destination squares
func get_valid_moves(board: ChessBoard) -> Array[Vector2i]:
    # Implementation
    pass
```

### File-Level Documentation

**Update when making significant changes:**
- **README.md** - For major features or architecture changes
- **LIVE2D_SETUP.md** - For Live2D integration changes
- **CLAUDE.md** (this file) - For new patterns or conventions

---

## Technology Stack

**Engine & Core:**
- Godot Engine 4.5 (GDScript)
- Mobile renderer with VRAM compression (ETC2/ASTC)
- Portrait orientation: 1080x1920

**Plugins & Extensions:**
- GDCubism v0.9.1 (Live2D Cubism SDK)
- GDExtension for native binary plugins

**Asset Formats:**
- Images: PNG
- Videos: MP4, WebM, OGV, GIF
- Fonts: TTF (Bangers-Regular.ttf)
- Models: Live2D .model3.json with .moc3
- Scenes: Godot .tscn (text-based)

---

## Autoload Singletons (Load Order)

These scripts are globally available and loaded at startup:

1. `GameState` → game_state.gd
2. `ChessPieces` → chess_pieces.gd
3. `ChessboardStorage` → chessboard_storage.gd
4. `ThemeManager` → theme_manager.gd
5. `PieceEffects` → piece_effects.gd
6. `AnimationErrorDetector` → animation_error_detector.gd
7. `GDExtensionErrorDetector` → gdextension_error_detector.gd

**Access Pattern:** `GameState.get_player_name(1)` or `ThemeManager.apply_theme()`

---

## Current Limitations & Future Work

### Known Limitations
- No castling or en passant moves
- No pawn promotion
- No multiplayer (local only)
- No persistent game saves
- No AI opponent

### Planned Features (from README)
- Implement castling and en passant
- Implement pawn promotion
- Add undo/redo functionality
- Add sound effects and music
- Create settings page
- Game save/load functionality
- Online multiplayer
- AI opponent with difficulty levels

---

## Development Workflow Preferences

### When Implementing Features:

1. **Research First:**
   - Read relevant existing files
   - Understand current architecture
   - Check for similar existing implementations

2. **Plan Implementation:**
   - Identify which files need modification
   - Consider impact on existing systems
   - Plan for validation and error handling

3. **Follow Patterns:**
   - Use established design patterns (singleton, factory, signals)
   - Maintain separation of concerns
   - Keep mobile optimization in mind

4. **Test Thoroughly:**
   - Manual gameplay testing
   - Use debug scenes for specific components
   - Verify mobile responsiveness

5. **Document Changes:**
   - Add/update code comments
   - Update README.md for major features
   - Note any breaking changes

### Code Quality Standards

**Prefer:**
- Type-safe code with explicit type hints
- Small, focused functions (single responsibility)
- Signal-based communication over direct coupling
- Validation at creation time (fail fast)
- Clear, descriptive variable and function names

**Avoid:**
- Magic numbers (use named constants)
- Deeply nested conditionals (refactor into functions)
- Direct references to UI nodes from logic scripts
- Hardcoded asset paths (use configuration)
- Duplicate code (extract to shared functions)

---

## Project Context & Goals

### Primary Goals:
- Create a polished mobile chess game experience
- Showcase character-based theming with Live2D integration
- Implement complete chess rules with proper validation
- Provide smooth touch-based gameplay
- Support multiple game modes and customization

### Design Philosophy:
- Mobile-first responsive design
- Clean separation of logic and presentation
- Robust error handling and validation
- Extensible character and theme system
- Performance-optimized for mobile devices

### User Experience Focus:
- Intuitive touch controls (drag-and-drop pieces)
- Clear visual feedback (valid moves, piece selection)
- Character personality through animations
- Comprehensive game statistics and history
- Responsive UI that adapts to different screens

---

## Quick Reference

### Important Paths
- Main game scene: `scenes/game/main_game.tscn`
- Entry point: `scenes/ui/login_page.tscn`
- Chess logic: `scripts/chess_board.gd`, `scripts/chess_pieces.gd`
- Global state: `scripts/game_state.gd`
- Character assets: `assets/characters/character_[1-4]/`
- Live2D model: `assets/characters/character_4/Scyka.model3.json`

### Key Configuration Files
- Godot config: `project.godot`
- Live2D plugin: `addons/gd_cubism/plugin.cfg`
- Main documentation: `README.md`
- Live2D setup: `LIVE2D_SETUP.md`

### Debug Commands
- Press **'D'** in game: Toggle Live2D debugger
- Run `asset_path_checker.tscn`: Validate asset paths
- Run `model_test.tscn`: Test Live2D models
- Check `AnimationErrorDetector.errors`: View animation errors
- Check `GDExtensionErrorDetector.extension_loaded`: Verify plugins

---

## Version Information

- **Godot Version:** 4.5+
- **GDCubism Version:** 0.9.1
- **Target Mobile OS:** Android/iOS
- **Screen Resolution:** 1080x1920 (portrait)
- **Minimum Godot:** 4.5 (required for GDExtension compatibility)

---

## Additional Resources

- **Godot Documentation:** https://docs.godotengine.org/en/stable/
- **GDScript Style Guide:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **Live2D Cubism SDK:** https://www.live2d.com/en/cubism/
- **GDCubism Plugin:** https://github.com/MizunagiKB/gd_cubism

---

**Last Updated:** 2025-11-12
**Project Status:** Mid-to-Late Development
**Maintainer:** See git repository for contributors
