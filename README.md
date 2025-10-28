# Chess Thesis Project

A mobile chess game built with Godot Engine featuring customizable characters and themed chess pieces.

## Project Overview

This is a chess game for mobile devices where players can select main characters that influence the appearance of their chess pieces during gameplay.

## Features

### Pages

1. **Login/Landing Page** (`scenes/ui/login_page.tscn`)
   - Simple entry point with a "PLAY" button
   - Navigates to character selection

2. **Character Selection Page** (`scenes/ui/character_selection.tscn`)
   - Player 1 character selection (top section)
   - Player 2 character selection (bottom section)
   - 3 characters available for each player
   - "START GAME" button (enabled only when both players select characters)
   - "BACK" button to return to login page

3. **Main Game Page** (`scenes/game/main_game.tscn`)
   - **Top Player Area**: Displays Player 2's character and info
   - **Chessboard**: 8x8 chess grid in the center
   - **Bottom Player Area**: Displays Player 1's character and info
   - **Score Panel**: Shows current scores, move count, captured pieces, and menu button

## Project Structure

```
chess-thesis/
├── scenes/
│   ├── ui/
│   │   ├── login_page.tscn          # Landing page
│   │   └── character_selection.tscn # Character selection
│   └── game/
│       └── main_game.tscn           # Main game scene
├── scripts/
│   ├── game_state.gd                # Global game state (autoload)
│   ├── login_page.gd                # Login page logic
│   ├── character_selection.gd       # Character selection logic
│   └── main_game.gd                 # Main game logic
├── assets/
│   ├── characters/                  # Character artwork (placeholder)
│   ├── chess_pieces/                # Chess piece artwork (placeholder)
│   └── fonts/                       # Game fonts (placeholder)
├── project.godot                    # Godot project configuration
└── README.md                        # This file
```

## Global State Management

The game uses an autoload singleton (`GameState`) to manage:
- Selected characters for both players
- Game scores
- Move count
- Captured pieces count
- Character data and piece styles

## Setup Instructions

1. Install [Godot Engine 4.3](https://godotengine.org/download) or later
2. **For Live2D support:** Follow the [Live2D Setup Guide](LIVE2D_SETUP.md) to install GDCubism binaries
3. Open the project in Godot by selecting the `project.godot` file
4. Run the project (F5) or export for mobile platforms

**Note:** The project will work without Live2D binaries - Character 4 will display as a static image instead of an animated model.

## Mobile Configuration

The project is configured for mobile with:
- Portrait orientation (1080x1920)
- Mobile renderer
- Touch input support
- Responsive layouts using anchors and containers

## Chess Logic Implementation

The game now includes full chess logic with:

### Chess Pieces
- **Base ChessPiece class** (`scripts/chess_piece.gd`): Foundation for all pieces with common functionality
- **Individual piece classes** (`scripts/chess_pieces.gd`):
  - Pawn: Forward movement, double move from start, diagonal capture
  - Rook: Horizontal and vertical movement
  - Knight: L-shaped jumps
  - Bishop: Diagonal movement
  - Queen: Combined rook and bishop movement
  - King: One square in any direction

### Game Features
- **Turn-based gameplay**: Alternates between white and black players
- **Valid move highlighting**:
  - Selected pieces highlighted in yellow
  - Valid moves shown in green
  - Capture moves shown in red
- **Capture system**: Captured pieces displayed in opponent's area
- **Score tracking**: Point values for captured pieces (Pawn=1, Knight/Bishop=3, Rook=5, Queen=9)
- **Move counter**: Tracks total moves made
- **Turn indicator**: Shows whose turn it is
- **Character-based piece styling**:
  - Classic: Traditional white/black colors
  - Modern: Blue-tinted color scheme
  - Fantasy: Gold/purple color scheme

### Responsive Design
- Adaptive layout for different screen sizes
- Flexible player areas and score panel
- Resizable window with proper aspect ratio handling
- Touch-friendly interface optimized for mobile

## Recent Updates

### Chessboard UI Improvements
- **Zoom to Center**: Chessboard zooms to its center point using mouse wheel
- **Pan Support**:
  - Mouse drag: Hold middle mouse button and drag to pan the chessboard
  - Touch: Use two-finger drag to pan the chessboard
- **Pinch-to-Zoom**: Two-finger pinch gesture for touch devices to zoom in/out
- **Scoreboard Toggle Repositioned**: Moved to the bottom of the chessboard container for better accessibility

### Character Animations
- **Enhanced Animation Support**:
  - Supports both video (.mp4, .webm, .ogv) and GIF formats for all animations
  - Character idle animations display continuously during gameplay
  - Victory animations play when a player wins
  - Defeat animations play when a player loses
  - Capture effect animations play when pieces are captured
- **Animation Files**:
  - `character_idle.mp4/.gif` - Idle animation (required)
  - `character_victory.mp4/.gif` - Victory animation (optional)
  - `character_defeat.mp4/.gif` - Defeat animation (optional)
  - `piece_capture_effect.mp4/.gif` - Capture effect (optional)

### Player Container Enhancements
- **Doubled Container Size**: Player areas increased from 120px to 240px height for better visibility
- **Doubled Character Display**: Character animations now 400x400px (doubled from 200x200px)
- **Doubled Font Sizes**:
  - Player names: 48px (doubled from 24px)
  - Character names: 40px (doubled from 20px)
  - Timers: 56px (doubled from 28px)
  - Captured pieces label: 36px (doubled from 18px)
- **Inverse Layout**: Player 2 container is designed as an inverse mirror of Player 1
  - Player 1: Character left, info right (left-aligned text)
  - Player 2: Info left, character right (right-aligned text)

### Chess Piece Animation
- **Drag and Drop**: Chess pieces now follow the player's finger or mouse cursor when picked up
- **Smooth Movement**: Pieces stick to the cursor during dragging for intuitive gameplay
- **Visual Feedback**: Valid moves are highlighted in green, captures in red

### Game Ending Logic
- **Checkmate Detection**: Automatically detects when a king is captured or checkmated
- **Stalemate Detection**: Identifies stalemate situations when no valid moves are available
- **Check Detection**: Monitors if kings are under attack

### Game Summarization
- **Move History**: Complete record of all moves in algebraic notation
- **Game Statistics**: Displays total moves, scores, and captured pieces
- **End Game Dialog**: Beautiful popup showing game results and full move history
- **Scrollable History**: View all moves made during the game

### Responsive Design
- **Orientation Support**: Supports both portrait and landscape orientations
- **Auto-Resize**: UI automatically adapts when device is rotated
- **Flexible Layout**: Maintains playability across different screen sizes
- **Aspect Ratio**: Chessboard maintains proper square proportions

## Future Enhancements

- Add character artwork and custom piece designs
- Implement castling and en passant moves
- Implement pawn promotion
- Add undo/redo functionality
- Add sound effects and music
- Create settings page (volume, difficulty, etc.)
- Add game save/load functionality
- Implement online multiplayer
- Add AI opponent with difficulty levels
- Add time controls and chess clock

## Character System

Each character will have:
- Unique visual appearance
- Associated chess piece art style
- Special visual effects (future)

Chess pieces will change their appearance based on the character selected by each player, making the game more personalized and engaging.

## Development Notes

- Built with Godot 4.2
- Target platform: Mobile (Android/iOS)
- UI uses responsive containers for different screen sizes
- Game flow: Login → Character Selection → Main Game

## License

This is a thesis project for educational purposes.
