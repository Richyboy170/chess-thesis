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

1. Install [Godot Engine 4.2](https://godotengine.org/download) or later
2. Open the project in Godot by selecting the `project.godot` file
3. Run the project (F5) or export for mobile platforms

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

## Future Enhancements

- Add character artwork and animations
- Implement castling and en passant moves
- Add check and checkmate detection
- Implement pawn promotion
- Add move history and undo functionality
- Add sound effects and music
- Create settings page
- Add game save/load functionality
- Implement online multiplayer
- Add AI opponent

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
