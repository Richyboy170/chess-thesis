extends Control

# ============================================================================
# NODE REFERENCES
# ============================================================================
# These @onready variables store references to UI nodes in the scene tree
# They are automatically assigned when the scene is loaded

# Chessboard and game area references
@onready var chessboard = $MainContainer/GameArea/ChessboardContainer/MarginContainer/VBoxContainer/AspectRatioContainer/Chessboard

# Player info labels (character names)
@onready var player1_character_label = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/CharacterName
@onready var player2_character_label = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/CharacterName

# Score panel elements
@onready var player1_score_label = $MainContainer/GameArea/ScorePanel/MarginContainer/VBoxContainer/Player1Score/ScoreValue
@onready var player2_score_label = $MainContainer/GameArea/ScorePanel/MarginContainer/VBoxContainer/Player2Score/ScoreValue
@onready var moves_label = $MainContainer/GameArea/ScorePanel/MarginContainer/VBoxContainer/GameStats/MovesLabel
@onready var captured_label = $MainContainer/GameArea/ScorePanel/MarginContainer/VBoxContainer/GameStats/CapturedLabel
@onready var turn_indicator = $MainContainer/GameArea/ScorePanel/MarginContainer/VBoxContainer/TurnIndicator

# Captured pieces display containers
@onready var player1_captured_container = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/CapturedPieces
@onready var player2_captured_container = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/CapturedPieces

# Score panel and toggle button
@onready var score_panel = $MainContainer/GameArea/ScorePanel
@onready var score_toggle_button = $MainContainer/GameArea/ScoreToggleButton

# Player timer labels
@onready var player1_timer_label = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/TimerLabel
@onready var player2_timer_label = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/TimerLabel

# Player character display areas (for video backgrounds)
@onready var player1_character_display = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/CharacterDisplay
@onready var player2_character_display = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/CharacterDisplay

# ============================================================================
# GAME STATE VARIABLES
# ============================================================================

# Core chess game logic instance
var chess_board: ChessBoard

# Visual representation of chess pieces on the board
var visual_pieces: Array = []

# 2D array of button nodes representing board squares [row][col]
var board_squares: Array = []

# Currently selected square position (-1, -1 means no selection)
var selected_square: Vector2i = Vector2i(-1, -1)

# Score panel visibility state
var score_panel_visible: bool = false  # Hidden by default

# Game state flag
var game_ended: bool = false

# ============================================================================
# DRAG AND DROP SYSTEM VARIABLES
# ============================================================================

# Reference to the piece currently being dragged
var dragging_piece: Label = null

# Offset from mouse position to piece center for smooth dragging
var drag_offset: Vector2 = Vector2.ZERO

# Original parent node to return piece to if drag is cancelled
var original_parent: Control = null

# Flag indicating if a drag operation is in progress
var is_dragging: bool = false

# ============================================================================
# INITIALIZATION FUNCTIONS
# ============================================================================

func _ready():
	"""
	Called when the node is added to the scene tree.
	Initializes the chess game, connects signals, and sets up the UI.
	Uses the new ChessboardFactory and ChessboardStorage infrastructure
	with full validation and error reporting.
	"""
	print("\n" + "=".repeat(60))
	print("MAIN GAME: Starting initialization")
	print("=".repeat(60))

	# STEP 1: Create and validate the chessboard using the factory
	print("\nSTEP 1: Creating chessboard with factory pattern...")
	var creation_success = ChessboardStorage.create_and_store_chessboard()

	# STEP 2: Check if chessboard was created successfully
	if not creation_success:
		_handle_chessboard_creation_failure()
		return  # Stop initialization if board creation failed

	print("\nSTEP 2: Chessboard creation verified ✓")

	# STEP 3: Retrieve the validated chessboard from storage
	chess_board = ChessboardStorage.get_chessboard()

	if chess_board == null:
		push_error("CRITICAL: ChessboardStorage returned null despite successful creation!")
		_handle_chessboard_creation_failure()
		return

	print("STEP 3: Chessboard retrieved from storage ✓")

	# STEP 4: Add the validated board to the scene tree
	add_child(chess_board)
	print("STEP 4: Chessboard added to scene tree ✓")

	# STEP 5: Perform final health check
	if not ChessboardStorage.health_check():
		push_error("CRITICAL: Chessboard failed health check!")
		_handle_chessboard_creation_failure()
		return

	print("STEP 5: Health check passed ✓")

	# STEP 6: Connect chess board signals to our handler functions
	chess_board.piece_moved.connect(_on_piece_moved)
	chess_board.piece_captured.connect(_on_piece_captured)
	chess_board.turn_changed.connect(_on_turn_changed)
	chess_board.game_over.connect(_on_game_over)
	print("STEP 6: Signals connected ✓")

	# STEP 7: Initialize all game components
	print("\nSTEP 7: Initializing game components...")
	setup_chessboard()           # Create the 8x8 grid of squares
	update_character_displays()   # Show selected characters
	load_character_assets()       # Load themed assets (backgrounds, videos)
	update_board_display()        # Place pieces on the board
	update_score_display()        # Initialize score panel
	setup_score_toggle()          # Configure score panel toggle button
	initialize_timers()           # Set up game timers
	update_timer_display()        # Display initial timer values

	print("\n" + "=".repeat(60))
	print("MAIN GAME: Initialization complete ✓")
	print("=".repeat(60) + "\n")

	# Print final status
	ChessboardStorage.print_status()

func _handle_chessboard_creation_failure():
	"""
	Handles the critical failure case where chessboard creation or validation failed.
	Displays error information and provides fallback behavior.
	"""
	print("\n" + "!".repeat(60))
	print("CRITICAL ERROR: Chessboard creation failed!")
	print("!".repeat(60))

	# Get detailed error report
	var result = ChessboardStorage.get_last_result()
	if result != null:
		print(result.get_error_report())
	else:
		print("No error details available")

	# Print storage status
	ChessboardStorage.print_status()

	# Display error to user via dialog
	var error_dialog = AcceptDialog.new()
	error_dialog.title = "Chessboard Initialization Error"

	var error_text = "Failed to create the chessboard!\n\n"
	if result != null:
		error_text += result.error_message + "\n\n"
		if result.validation_details.size() > 0:
			error_text += "Details:\n"
			for detail in result.validation_details:
				error_text += "• " + detail + "\n"

	error_text += "\nThe game cannot start. Please restart the application."

	error_dialog.dialog_text = error_text
	error_dialog.ok_button_text = "Close"
	add_child(error_dialog)
	error_dialog.popup_centered()

	# Connect to close button to return to main menu
	error_dialog.confirmed.connect(_on_error_dialog_closed)

	print("Error dialog displayed to user")
	print("!".repeat(60) + "\n")

func _on_error_dialog_closed():
	"""
	Called when the user closes the error dialog.
	Returns to the main menu/login page.
	"""
	print("User acknowledged error - returning to login page")
	get_tree().change_scene_to_file("res://scenes/ui/login_page.tscn")

# ============================================================================
# FRAME UPDATE FUNCTIONS
# ============================================================================

func _process(delta):
	"""
	Called every frame. Updates game timers if a timed game is in progress.

	Args:
		delta: Time elapsed since the previous frame in seconds
	"""
	# Only update timers if game is active and timers are enabled
	if not game_ended and GameState.player_time_limit > 0:
		# Decrement the current player's remaining time
		if chess_board.is_white_turn:
			GameState.player1_time_remaining -= delta
			# Check if Player 1 (White) ran out of time
			if GameState.player1_time_remaining <= 0:
				GameState.player1_time_remaining = 0
				handle_time_expired(true)
		else:
			GameState.player2_time_remaining -= delta
			# Check if Player 2 (Black) ran out of time
			if GameState.player2_time_remaining <= 0:
				GameState.player2_time_remaining = 0
				handle_time_expired(false)

		# Update timer display to show new values
		update_timer_display()

# ============================================================================
# INPUT HANDLING FUNCTIONS
# ============================================================================

func _input(event):
	"""
	Handles all input events, primarily for drag-and-drop piece movement.
	Supports both mouse (desktop) and touch (mobile) input.
	Currently disabled in favor of click-to-move interface.

	Args:
		event: The input event to process
	"""
	# Drag-and-drop functionality temporarily disabled
	# Using simple click-to-select, click-to-move interface instead
	pass

	# # Only process input if a piece is currently being dragged
	# if is_dragging and dragging_piece:
	# 	# Handle mouse movement or touch drag - update piece position
	# 	if event is InputEventMouseMotion or event is InputEventScreenDrag:
	# 		var mouse_pos = get_viewport().get_mouse_position()
	# 		dragging_piece.global_position = mouse_pos - drag_offset
	#
	# 	# Handle mouse button release
	# 	elif event is InputEventMouseButton:
	# 		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
	# 			end_drag(event.position)
	#
	# 	# Handle touch release (mobile)
	# 	elif event is InputEventScreenTouch:
	# 		if not event.pressed:
	# 			end_drag(event.position)

# ============================================================================
# CHESSBOARD SETUP FUNCTIONS
# ============================================================================

func setup_chessboard():
	"""
	Creates the 8x8 chessboard grid with themed backgrounds.
	The board is split in half vertically:
	- Bottom half (rows 0-3): Player 1's theme
	- Top half (rows 4-7): Player 2's theme
	Each square is a Panel node with custom styling.
	Uses a simpler, more reliable rendering method.
	"""
	board_squares = []

	# Get player character themes for split board coloring
	var player1_theme = GameState.get_character_piece_style(GameState.player1_character)
	var player2_theme = GameState.get_character_piece_style(GameState.player2_character)

	# Define theme color schemes for board squares
	var theme_colors = {
		"classic": {
			"light": Color(0.9, 0.9, 0.8, 1),    # Cream
			"dark": Color(0.5, 0.4, 0.3, 1)      # Brown
		},
		"modern": {
			"light": Color(0.85, 0.92, 0.98, 1), # Light blue
			"dark": Color(0.2, 0.3, 0.5, 1)      # Dark blue
		},
		"fantasy": {
			"light": Color(0.95, 0.9, 0.75, 1),  # Golden
			"dark": Color(0.5, 0.2, 0.4, 1)      # Purple
		}
	}

	# Create 8x8 grid of squares using Panel nodes (lighter than Button)
	for row in range(8):
		var row_array = []
		for col in range(8):
			# Use Panel instead of Button for simpler, more reliable rendering
			var square = Panel.new()
			square.custom_minimum_size = Vector2(80, 80)
			square.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow mouse events to pass through

			# Determine which player's theme to use based on row
			# Rows 0-3 (bottom): Player 1's theme
			# Rows 4-7 (top): Player 2's theme
			var current_theme = player1_theme if row < 4 else player2_theme
			var colors = theme_colors.get(current_theme, theme_colors["classic"])

			# Create background style with theme colors
			var style_box = StyleBoxFlat.new()
			# Alternate light and dark squares for checkerboard pattern
			if (row + col) % 2 == 0:
				style_box.bg_color = colors["light"]
			else:
				style_box.bg_color = colors["dark"]

			# Apply style to panel
			square.add_theme_stylebox_override("panel", style_box)

			# Store board position in metadata for later reference
			square.set_meta("board_pos", Vector2i(row, col))

			# Add square to the chessboard container
			chessboard.add_child(square)
			row_array.append(square)

		board_squares.append(row_array)

	# Setup input detection on the chessboard container
	chessboard.mouse_filter = Control.MOUSE_FILTER_PASS
	chessboard.gui_input.connect(_on_chessboard_input)

	# Ensure chessboard is visible
	chessboard.visible = true
	print("Chessboard created with themed backgrounds: ", player1_theme, " (bottom) and ", player2_theme, " (top)")

func load_character_assets():
	"""
	Loads themed assets for both players including:
	- Character background images
	- Character animation videos (.mp4)
	- Custom chess piece sprites
	This function will attempt to load assets from the assets/ folder structure.
	If assets are not found, it will use default placeholders.
	"""
	# Character folder paths
	var char1_path = "res://assets/characters/character_" + str(GameState.player1_character + 1) + "/"
	var char2_path = "res://assets/characters/character_" + str(GameState.player2_character + 1) + "/"

	# Try to load Player 1 character video/background
	var p1_video_path = char1_path + "animations/character_idle.mp4"
	var p1_bg_path = char1_path + "backgrounds/character_background.png"
	load_character_media(player1_character_display, p1_video_path, p1_bg_path)

	# Try to load Player 2 character video/background
	var p2_video_path = char2_path + "animations/character_idle.mp4"
	var p2_bg_path = char2_path + "backgrounds/character_background.png"
	load_character_media(player2_character_display, p2_video_path, p2_bg_path)

	print("Character assets loaded for Player 1 (", GameState.player1_character, ") and Player 2 (", GameState.player2_character, ")")

func load_character_media(display_node: ColorRect, video_path: String, bg_path: String):
	"""
	Helper function to load and display character media (video or background image).

	Args:
		display_node: The ColorRect node to display the media on
		video_path: Path to the character's .mp4 video file
		bg_path: Fallback path to a background image if video is not available
	"""
	# Try to load video file first
	if FileAccess.file_exists(video_path):
		var video_stream = load(video_path)
		if video_stream:
			# Create VideoStreamPlayer to display the animation
			var video_player = VideoStreamPlayer.new()
			video_player.stream = video_stream
			video_player.autoplay = true
			video_player.loop = true
			video_player.expand = true
			video_player.anchor_right = 1.0
			video_player.anchor_bottom = 1.0
			display_node.add_child(video_player)
			print("Loaded video: ", video_path)
			return

	# Fallback to background image if video not found
	if FileAccess.file_exists(bg_path):
		var texture = load(bg_path)
		if texture:
			# Create TextureRect to display the background
			var texture_rect = TextureRect.new()
			texture_rect.texture = texture
			texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.anchor_right = 1.0
			texture_rect.anchor_bottom = 1.0
			display_node.add_child(texture_rect)
			print("Loaded background image: ", bg_path)
	else:
		print("Character media not found: ", video_path, " or ", bg_path)

# ============================================================================
# CHARACTER AND UI UPDATE FUNCTIONS
# ============================================================================

func update_character_displays():
	"""
	Updates the character name labels to show which character each player selected.
	"""
	var character_names = ["Character 1", "Character 2", "Character 3"]

	# Update Player 1 character display
	if GameState.player1_character >= 0 and GameState.player1_character < character_names.size():
		player1_character_label.text = "Character: " + character_names[GameState.player1_character]

	# Update Player 2 character display
	if GameState.player2_character >= 0 and GameState.player2_character < character_names.size():
		player2_character_label.text = "Character: " + character_names[GameState.player2_character]

func update_board_display():
	"""
	Refreshes the visual representation of all chess pieces on the board.
	This function:
	1. Clears all existing visual pieces
	2. Queries the chess board logic for current piece positions
	3. Creates new visual representations for each piece
	Called after every move or board state change.
	"""
	# Clear existing visual pieces from previous render
	for piece in visual_pieces:
		piece.queue_free()
	visual_pieces.clear()

	# Remove piece labels from all squares
	for row in range(8):
		for col in range(8):
			var square = board_squares[row][col]
			for child in square.get_children():
				child.queue_free()

	# Create fresh visual pieces based on current board state
	for row in range(8):
		for col in range(8):
			var piece = chess_board.get_piece_at(Vector2i(row, col))
			if piece != null:
				create_visual_piece(piece, Vector2i(row, col))

func create_visual_piece(piece: ChessPiece, pos: Vector2i):
	"""
	Creates a visual representation of a chess piece at the specified position.
	Currently uses Unicode symbols (♔♕♖♗♘♙) but can be extended to use
	custom images/sprites from the assets folder.

	Args:
		piece: The ChessPiece object containing piece data
		pos: Board position (row, col) where the piece should be displayed
	"""
	# Create a Label to display the piece (using Unicode symbol for now)
	var visual_piece = Label.new()
	visual_piece.text = piece.get_piece_symbol()
	visual_piece.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	visual_piece.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	visual_piece.add_theme_font_size_override("font_size", 56)
	visual_piece.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow drag events

	# Center the piece label within its square using anchors
	visual_piece.anchor_left = 0.0
	visual_piece.anchor_top = 0.0
	visual_piece.anchor_right = 1.0
	visual_piece.anchor_bottom = 1.0
	visual_piece.offset_left = 0
	visual_piece.offset_top = 0
	visual_piece.offset_right = 0
	visual_piece.offset_bottom = 0
	visual_piece.grow_horizontal = Control.GROW_DIRECTION_BOTH
	visual_piece.grow_vertical = Control.GROW_DIRECTION_BOTH

	# Apply theme-based colors to pieces
	var style_colors = {
		"classic": {"white": Color(1, 1, 1), "black": Color(0.2, 0.2, 0.2)},
		"modern": {"white": Color(0.8, 0.9, 1), "black": Color(0.1, 0.2, 0.4)},
		"fantasy": {"white": Color(1, 0.9, 0.7), "black": Color(0.4, 0.1, 0.3)}
	}

	var style = piece.character_style
	if not style in style_colors:
		style = "classic"  # Fallback to classic if theme not found

	# Determine piece color and apply appropriate theme color
	var color_key = "white" if piece.piece_color == ChessPiece.PieceColor.WHITE else "black"
	visual_piece.add_theme_color_override("font_color", style_colors[style][color_key])

	# Add piece to the board square and track it
	board_squares[pos.x][pos.y].add_child(visual_piece)
	visual_pieces.append(visual_piece)

	# TODO: Replace Unicode symbols with custom sprite/image when assets are available
	# Example: load texture from res://assets/characters/character_X/pieces/white_king.png

# ============================================================================
# SQUARE CLICK AND PIECE SELECTION FUNCTIONS
# ============================================================================

func _on_chessboard_input(event: InputEvent):
	"""
	Handles all input events on the chessboard using a unified input handler.
	Detects which square was clicked by calculating position from mouse coordinates.
	This replaces the old button-based system with a more reliable approach.

	Args:
		event: The input event to process
	"""
	# Only respond to mouse clicks
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Convert mouse position to board coordinates
			var board_pos = get_square_from_position(event.position)
			if board_pos != Vector2i(-1, -1):
				_on_square_clicked(board_pos)

func get_square_from_position(local_pos: Vector2) -> Vector2i:
	"""
	Converts a local mouse position within the chessboard to board coordinates.

	Args:
		local_pos: Mouse position relative to the chessboard container

	Returns:
		Vector2i with (row, col) or (-1, -1) if outside the board
	"""
	# Check each square to see if the position is within it
	for row in range(8):
		for col in range(8):
			var square = board_squares[row][col]
			var rect = Rect2(square.position, square.size)
			if rect.has_point(local_pos):
				return Vector2i(row, col)

	return Vector2i(-1, -1)

func _on_square_clicked(pos: Vector2i):
	"""
	Handles clicks on chess board squares.
	Two-click interface: First click selects a piece, second click moves it.
	Also initiates drag-and-drop when a piece is clicked.

	Args:
		pos: The board position (row, col) that was clicked
	"""
	# Ignore clicks during drag operations
	if is_dragging:
		return

	# If a piece is already selected, try to move it to the clicked square
	if selected_square != Vector2i(-1, -1):
		if chess_board.try_move_piece(selected_square, pos):
			# Move successful
			clear_highlights()
			selected_square = Vector2i(-1, -1)
			update_board_display()
			update_score_display()
		else:
			# Move invalid, try selecting a different piece
			attempt_select_piece(pos)
	else:
		# No piece selected yet, try to select the clicked piece
		attempt_select_piece(pos)

func attempt_select_piece(pos: Vector2i):
	"""
	Attempts to select a chess piece at the given position.
	If successful, highlights valid moves.

	Args:
		pos: The board position to select from
	"""
	clear_highlights()
	if chess_board.select_piece(pos):
		selected_square = pos
		highlight_valid_moves()
		# Drag functionality disabled for now - using click-to-move interface
		# start_drag(pos)

# ============================================================================
# BOARD HIGHLIGHTING FUNCTIONS
# ============================================================================

func highlight_valid_moves():
	"""
	Highlights the selected piece and all its valid moves on the board.
	- Selected square: Yellow highlight
	- Valid moves: Green highlight
	- Capture moves: Red highlight
	"""
	# Highlight the currently selected square in yellow
	var selected = board_squares[selected_square.x][selected_square.y]
	var highlight_style = StyleBoxFlat.new()
	highlight_style.bg_color = Color(1, 1, 0, 0.5)  # Semi-transparent yellow
	selected.add_theme_stylebox_override("panel", highlight_style)

	# Highlight all valid moves for the selected piece
	for move in chess_board.valid_moves:
		var square = board_squares[move.x][move.y]
		var move_style = StyleBoxFlat.new()

		# Use red for capture moves, green for regular moves
		if chess_board.get_piece_at(move) != null:
			move_style.bg_color = Color(1, 0.3, 0.3, 0.5)  # Red (capture)
		else:
			move_style.bg_color = Color(0.3, 1, 0.3, 0.5)  # Green (move)

		square.add_theme_stylebox_override("panel", move_style)

func clear_highlights():
	"""
	Removes all move highlights and restores the themed chessboard colors.
	This function is called after a move is made or selection is cancelled.
	"""
	# Get player themes for restoring themed colors
	var player1_theme = GameState.get_character_piece_style(GameState.player1_character)
	var player2_theme = GameState.get_character_piece_style(GameState.player2_character)

	# Theme color definitions (must match setup_chessboard)
	var theme_colors = {
		"classic": {
			"light": Color(0.9, 0.9, 0.8, 1),
			"dark": Color(0.5, 0.4, 0.3, 1)
		},
		"modern": {
			"light": Color(0.85, 0.92, 0.98, 1),
			"dark": Color(0.2, 0.3, 0.5, 1)
		},
		"fantasy": {
			"light": Color(0.95, 0.9, 0.75, 1),
			"dark": Color(0.5, 0.2, 0.4, 1)
		}
	}

	# Restore themed colors to all squares
	for row in range(8):
		for col in range(8):
			var square = board_squares[row][col]

			# Determine theme based on row (bottom half = player1, top half = player2)
			var current_theme = player1_theme if row < 4 else player2_theme
			var colors = theme_colors.get(current_theme, theme_colors["classic"])

			var style_box = StyleBoxFlat.new()
			# Restore checkerboard pattern with themed colors
			if (row + col) % 2 == 0:
				style_box.bg_color = colors["light"]
			else:
				style_box.bg_color = colors["dark"]

			square.add_theme_stylebox_override("panel", style_box)

func update_score_display():
	"""
	Updates all score panel labels with current game statistics.
	This includes player scores, move count, and captured pieces count.
	"""
	player1_score_label.text = str(GameState.player1_score)
	player2_score_label.text = str(GameState.player2_score)
	moves_label.text = "Moves: " + str(GameState.move_count)
	captured_label.text = "Captured Pieces: " + str(GameState.captured_pieces)

func update_captured_display():
	"""
	Updates the visual display of captured pieces for both players.
	Shows piece symbols in the player info areas at top and bottom of screen.
	Called whenever a piece is captured.
	"""
	# Clear existing captured pieces labels
	for child in player1_captured_container.get_children():
		child.queue_free()
	for child in player2_captured_container.get_children():
		child.queue_free()

	# Display pieces captured by Player 1 (White pieces captured)
	for piece in chess_board.get_captured_by_white():
		var label = Label.new()
		label.text = piece.get_piece_symbol()
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		player1_captured_container.add_child(label)

	# Display pieces captured by Player 2 (Black pieces captured)
	for piece in chess_board.get_captured_by_black():
		var label = Label.new()
		label.text = piece.get_piece_symbol()
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		player2_captured_container.add_child(label)

# ============================================================================
# DRAG AND DROP FUNCTIONS
# ============================================================================

func start_drag(pos: Vector2i):
	"""
	Initiates a drag operation for the piece at the given position.
	Uses a simpler approach without reparenting to avoid layout issues.

	Args:
		pos: Board position of the piece to start dragging
	"""
	var square = board_squares[pos.x][pos.y]
	if square.get_child_count() > 0:
		var piece_label = square.get_child(0)
		if piece_label is Label:
			# Store reference to the piece and its original position
			dragging_piece = piece_label
			original_parent = square

			# Get current mouse/touch position
			var mouse_pos = get_viewport().get_mouse_position()

			# Calculate offset from mouse to piece center for smooth dragging
			var piece_center = piece_label.global_position + (piece_label.size / 2)
			drag_offset = piece_center - mouse_pos

			# Make piece semi-transparent during drag
			piece_label.modulate = Color(1, 1, 1, 0.7)

			# Bring piece to front
			piece_label.z_index = 100

			# Update drag state
			is_dragging = true

func end_drag(drop_position: Vector2):
	"""
	Ends a drag operation and attempts to place the piece on a square.
	If the move is valid, the piece is moved. Otherwise, it returns to its original position.

	Args:
		drop_position: The screen position where the piece was dropped
	"""
	if not is_dragging or dragging_piece == null:
		return

	# Restore piece appearance
	if dragging_piece:
		dragging_piece.modulate = Color(1, 1, 1, 1)
		dragging_piece.z_index = 0

	# Find which square the piece was dropped on
	var dropped_on_square = Vector2i(-1, -1)
	for row in range(8):
		for col in range(8):
			var square = board_squares[row][col]
			var rect = Rect2(square.global_position, square.size)
			if rect.has_point(drop_position):
				dropped_on_square = Vector2i(row, col)
				break
		if dropped_on_square != Vector2i(-1, -1):
			break

	# Attempt to move the piece to the dropped square
	if dropped_on_square != Vector2i(-1, -1) and selected_square != Vector2i(-1, -1):
		if chess_board.try_move_piece(selected_square, dropped_on_square):
			# Move successful - update game state
			clear_highlights()
			selected_square = Vector2i(-1, -1)
			dragging_piece = null
			is_dragging = false
			original_parent = null
			update_board_display()
			update_score_display()
		else:
			# Move invalid - flash red and return piece
			if dropped_on_square != Vector2i(-1, -1):
				flash_square_red(dropped_on_square)
			return_piece_to_original_position()
	else:
		# Dropped outside board - return piece to original position
		return_piece_to_original_position()

func return_piece_to_original_position():
	"""
	Returns a dragged piece back to its original square.
	Called when a drag operation is cancelled or an invalid move is attempted.
	"""
	if dragging_piece:
		dragging_piece.modulate = Color(1, 1, 1, 1)
		dragging_piece.z_index = 0

	# Reset all drag state
	dragging_piece = null
	is_dragging = false
	original_parent = null
	clear_highlights()
	selected_square = Vector2i(-1, -1)

# ============================================================================
# VISUAL FEEDBACK FUNCTIONS
# ============================================================================

func flash_square_red(pos: Vector2i):
	"""
	Flashes a square red to indicate an invalid move attempt.
	The square fades from red back to its original color over 1 second.

	Args:
		pos: The board position to flash
	"""
	# Validate position
	if pos.x < 0 or pos.x >= 8 or pos.y < 0 or pos.y >= 8:
		return

	var square = board_squares[pos.x][pos.y]

	# Get the original themed color for this square
	var player1_theme = GameState.get_character_piece_style(GameState.player1_character)
	var player2_theme = GameState.get_character_piece_style(GameState.player2_character)
	var current_theme = player1_theme if pos.x < 4 else player2_theme

	var theme_colors = {
		"classic": {
			"light": Color(0.9, 0.9, 0.8, 1),
			"dark": Color(0.5, 0.4, 0.3, 1)
		},
		"modern": {
			"light": Color(0.85, 0.92, 0.98, 1),
			"dark": Color(0.2, 0.3, 0.5, 1)
		},
		"fantasy": {
			"light": Color(0.95, 0.9, 0.75, 1),
			"dark": Color(0.5, 0.2, 0.4, 1)
		}
	}

	var colors = theme_colors.get(current_theme, theme_colors["classic"])
	var original_color = colors["light"] if (pos.x + pos.y) % 2 == 0 else colors["dark"]

	# Apply bright red flash
	var red_style = StyleBoxFlat.new()
	red_style.bg_color = Color(1, 0, 0, 0.7)
	square.add_theme_stylebox_override("panel", red_style)

	# Animate transition back to original color
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Gradually lerp from red to original color over 1 second
	tween.tween_method(func(value: float):
		var current_style = StyleBoxFlat.new()
		current_style.bg_color = Color(1, 0, 0, 0.7).lerp(original_color, value)
		square.add_theme_stylebox_override("panel", current_style)
	, 0.0, 1.0, 1.0)

	# Ensure original color is fully restored at the end
	tween.tween_callback(func():
		var final_style = StyleBoxFlat.new()
		final_style.bg_color = original_color
		square.add_theme_stylebox_override("panel", final_style)
	)

# ============================================================================
# CHESS BOARD EVENT HANDLERS (SIGNALS)
# ============================================================================

func _on_piece_moved(from_pos: Vector2i, to_pos: Vector2i, piece: ChessPiece):
	"""
	Called when a piece is successfully moved on the board.
	Connected to the chess_board.piece_moved signal.

	Args:
		from_pos: Starting position of the piece
		to_pos: Ending position of the piece
		piece: The piece that was moved
	"""
	print("Piece moved from ", from_pos, " to ", to_pos)

func _on_piece_captured(piece: ChessPiece, captured_by: ChessPiece):
	"""
	Called when a piece is captured.
	Updates the captured pieces display.
	Connected to the chess_board.piece_captured signal.

	Args:
		piece: The piece that was captured
		captured_by: The piece that captured it
	"""
	print(captured_by.get_piece_name(), " captured ", piece.get_piece_name())
	update_captured_display()

func _on_turn_changed(is_white_turn: bool):
	"""
	Called when the turn changes between players.
	Updates the turn indicator in the score panel.
	Connected to the chess_board.turn_changed signal.

	Args:
		is_white_turn: True if it's now white's turn, False for black's turn
	"""
	var turn_text = "White's Turn" if is_white_turn else "Black's Turn"
	turn_indicator.text = turn_text
	print(turn_text)

func _on_game_over(result: String):
	"""
	Called when the game ends (checkmate, stalemate, etc.).
	Shows the game summary dialog.
	Connected to the chess_board.game_over signal.

	Args:
		result: The game result string (e.g., "checkmate_white", "stalemate")
	"""
	print("Game Over! Result: ", result)
	game_ended = true
	show_game_summary(result)

# ============================================================================
# TIMER FUNCTIONS
# ============================================================================

func initialize_timers():
	"""
	Initializes the game timers based on the selected time limit.
	If no time limit was selected, timers are hidden.
	"""
	if GameState.player_time_limit > 0:
		# Set timer values from configured limit
		GameState.player1_time_remaining = float(GameState.player_time_limit)
		GameState.player2_time_remaining = float(GameState.player_time_limit)
	else:
		# No timer set - hide timer labels
		GameState.player1_time_remaining = 0.0
		GameState.player2_time_remaining = 0.0
		player1_timer_label.visible = false
		player2_timer_label.visible = false

func update_timer_display():
	"""
	Updates the timer display labels with current remaining time.
	Colors the timer text based on urgency:
	- Green: > 60 seconds remaining
	- Yellow: 30-60 seconds remaining
	- Red: < 30 seconds remaining
	"""
	# Skip if no timer is active
	if GameState.player_time_limit == 0:
		return

	# Format Player 1's time as MM:SS
	var p1_minutes = int(GameState.player1_time_remaining) / 60
	var p1_seconds = int(GameState.player1_time_remaining) % 60
	player1_timer_label.text = "Time: %02d:%02d" % [p1_minutes, p1_seconds]

	# Format Player 2's time as MM:SS
	var p2_minutes = int(GameState.player2_time_remaining) / 60
	var p2_seconds = int(GameState.player2_time_remaining) % 60
	player2_timer_label.text = "Time: %02d:%02d" % [p2_minutes, p2_seconds]

	# Apply color coding to Player 1's timer
	if GameState.player1_time_remaining <= 30:
		player1_timer_label.add_theme_color_override("font_color", Color(1, 0, 0, 1))  # Red
	elif GameState.player1_time_remaining <= 60:
		player1_timer_label.add_theme_color_override("font_color", Color(1, 1, 0, 1))  # Yellow
	else:
		player1_timer_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))  # Green

	# Apply color coding to Player 2's timer
	if GameState.player2_time_remaining <= 30:
		player2_timer_label.add_theme_color_override("font_color", Color(1, 0, 0, 1))  # Red
	elif GameState.player2_time_remaining <= 60:
		player2_timer_label.add_theme_color_override("font_color", Color(1, 1, 0, 1))  # Yellow
	else:
		player2_timer_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))  # Green

func handle_time_expired(is_white: bool):
	"""
	Handles the event when a player's time runs out.
	The player who ran out of time loses the game.

	Args:
		is_white: True if white player ran out of time, False if black player
	"""
	if game_ended:
		return

	# Set game as ended
	game_ended = true
	var result = "timeout_black_wins" if is_white else "timeout_white_wins"
	GameState.game_result = result

	# Show game over dialog
	show_game_summary(result)

# ============================================================================
# SCORE PANEL FUNCTIONS
# ============================================================================

func setup_score_toggle():
	"""
	Initializes the score panel toggle button.
	The score panel starts hidden by default and can be toggled with a floating button.
	The toggle button is positioned as a floating element that doesn't affect layout.
	"""
	# Hide score panel by default
	score_panel.visible = false

	# Make toggle button floating (independent of layout)
	score_toggle_button.position = Vector2(score_toggle_button.position.x, score_toggle_button.position.y)
	score_toggle_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	score_toggle_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# Connect the toggle button signal
	score_toggle_button.pressed.connect(_on_score_toggle_pressed)

	# Set initial text - panel is hidden, so show expand arrow
	score_toggle_button.text = ">"

	print("Score panel initialized as hidden")

func _on_score_toggle_pressed():
	"""
	Handles clicks on the score panel toggle button.
	Toggles the score panel visibility state.
	"""
	score_panel_visible = !score_panel_visible
	toggle_score_panel()

func toggle_score_panel():
	"""
	Animates the score panel sliding in/out.
	When hidden, the panel slides out to the right.
	When shown, the panel slides in from its original position (not from far left).
	The panel stays in the same place in the layout - it just becomes visible/invisible.
	"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	if score_panel_visible:
		# Show panel - fade in at current position
		score_panel.visible = true
		score_panel.modulate.a = 0.0
		tween.tween_property(score_panel, "modulate:a", 1.0, 0.3)
	else:
		# Hide panel - fade out at current position
		tween.tween_property(score_panel, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): score_panel.visible = false)

	update_score_toggle_text()

func update_score_toggle_text():
	"""
	Updates the toggle button text based on panel visibility.
	< means panel is visible (click to hide)
	> means panel is hidden (click to show)
	"""
	if score_panel_visible:
		score_toggle_button.text = "<"
	else:
		score_toggle_button.text = ">"

# ============================================================================
# MENU AND GAME OVER FUNCTIONS
# ============================================================================

func _on_menu_button_pressed():
	"""
	Handles the MENU button press in the score panel.
	Returns the player to the login/main menu screen.
	"""
	get_tree().change_scene_to_file("res://scenes/ui/login_page.tscn")

func show_game_summary(result: String):
	"""
	Displays the game over dialog with complete game statistics.
	Shows the result, scores, move count, and full move history.
	When closed, returns to the main menu.

	Args:
		result: The game result string (e.g., "checkmate_white", "stalemate", "timeout_black_wins")
	"""
	# Create popup dialog
	var dialog = AcceptDialog.new()
	dialog.title = "Game Over!"
	dialog.dialog_autowrap = true
	dialog.size = Vector2(600, 800)

	# Determine result message based on game outcome
	var result_text = ""
	match result:
		"checkmate_white":
			result_text = "Checkmate! White Wins!"
		"checkmate_black":
			result_text = "Checkmate! Black Wins!"
		"stalemate":
			result_text = "Stalemate! It's a Draw!"
		"draw":
			result_text = "Draw!"
		"timeout_white_wins":
			result_text = "Time's Up! White Wins!"
		"timeout_black_wins":
			result_text = "Time's Up! Black Wins!"
		_:
			result_text = "Game Over!"

	# Create content container
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 15)

	# Display result heading
	var result_label = Label.new()
	result_label.text = result_text
	result_label.add_theme_font_size_override("font_size", 28)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(result_label)

	# Add separator
	var sep1 = HSeparator.new()
	content.add_child(sep1)

	# Game statistics section
	var stats_label = Label.new()
	stats_label.text = "Game Statistics"
	stats_label.add_theme_font_size_override("font_size", 22)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(stats_label)

	# Display game statistics
	var stats_text = Label.new()
	stats_text.text = "Total Moves: " + str(GameState.move_count) + "\n"
	stats_text.text += "Player 1 Score: " + str(GameState.player1_score) + "\n"
	stats_text.text += "Player 2 Score: " + str(GameState.player2_score) + "\n"
	stats_text.text += "Total Captures: " + str(GameState.captured_pieces)
	stats_text.add_theme_font_size_override("font_size", 18)
	stats_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(stats_text)

	# Add separator
	var sep2 = HSeparator.new()
	content.add_child(sep2)

	# Move history section
	var history_label = Label.new()
	history_label.text = "Move History"
	history_label.add_theme_font_size_override("font_size", 22)
	history_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(history_label)

	# Create scrollable container for move history
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(550, 300)

	# Format move history in chess notation style
	var moves_label = Label.new()
	var moves_text = ""
	for i in range(GameState.move_history.size()):
		var move_num = (i / 2) + 1  # Calculate move number
		if i % 2 == 0:
			# White's move
			moves_text += str(move_num) + ". " + GameState.move_history[i]
			if i + 1 < GameState.move_history.size():
				# Add black's move on the same line
				moves_text += "  " + GameState.move_history[i + 1] + "\n"
			else:
				moves_text += "\n"

	moves_label.text = moves_text
	moves_label.add_theme_font_size_override("font_size", 16)
	moves_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	scroll.add_child(moves_label)
	content.add_child(scroll)

	# Add content to dialog and show it
	dialog.add_child(content)
	add_child(dialog)
	dialog.popup_centered()

	# Return to menu when dialog is closed
	dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/login_page.tscn"))
