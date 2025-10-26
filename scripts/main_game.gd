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

# Player character display areas (for video animations)
@onready var player1_character_display = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/CharacterDisplay
@onready var player2_character_display = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/CharacterDisplay

# Player area containers (for background images)
@onready var player1_area = $MainContainer/BottomPlayerArea
@onready var player2_area = $MainContainer/TopPlayerArea

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

# Reference to the piece currently being dragged (TextureRect or Label)
var dragging_piece: Control = null

# Offset from mouse position to piece center for smooth dragging
var drag_offset: Vector2 = Vector2.ZERO

# Original parent node to return piece to if drag is cancelled
var original_parent: Control = null

# Original scale of the piece before dragging
var original_scale: Vector2 = Vector2.ONE

# Flag indicating if a drag operation is in progress
var is_dragging: bool = false

# Shadow/glow effect node for visual feedback during drag
var drag_shadow: Control = null

# Highlight overlay nodes for valid moves
var highlight_overlays: Array = []

# Cached highlight textures (loaded once for performance)
var valid_move_texture: Texture2D = null
var capture_move_texture: Texture2D = null
var highlights_loaded: bool = false

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
	load_random_game_background() # Load random background for the game
	setup_chessboard()           # Create the 8x8 grid of squares
	update_character_displays()   # Show selected characters
	load_character_assets()       # Load themed assets (backgrounds, videos)
	validate_all_media()          # Validate all media assets and report errors
	update_board_display()        # Place pieces on the board
	update_score_display()        # Initialize score panel
	setup_score_toggle()          # Configure score panel toggle button
	initialize_timers()           # Set up game timers
	update_timer_display()        # Display initial timer values

	print("\n" + "=".repeat(60))
	print("MAIN GAME: Initialization complete ✓")
	print("=".repeat(60) + "\n")

	# Apply anime font theme to all UI elements
	ThemeManager.apply_theme_to_container(self, true)

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
	Pieces stick to the mouse/finger with smooth visual feedback.

	Args:
		event: The input event to process
	"""
	# Only process input if a piece is currently being dragged
	if is_dragging and dragging_piece:
		# Handle mouse movement or touch drag - update piece position
		if event is InputEventMouseMotion or event is InputEventScreenDrag:
			var mouse_pos = get_viewport().get_mouse_position()
			# Make piece stick to cursor with offset for natural feel
			dragging_piece.global_position = mouse_pos - drag_offset
			# Update shadow to follow the piece
			update_drag_shadow()

		# Handle mouse button release
		elif event is InputEventMouseButton:
			if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				end_drag(event.position)

		# Handle touch release (mobile)
		elif event is InputEventScreenTouch:
			if not event.pressed:
				end_drag(event.position)

# ============================================================================
# CHESSBOARD SETUP FUNCTIONS
# ============================================================================

func setup_chessboard():
	"""
	Creates the 8x8 chessboard grid with simple classic checkerboard pattern.
	Each square is a Panel node with custom styling.
	Uses a simpler, more reliable rendering method with unified theme.
	"""
	board_squares = []

	# Use classic chess colors for all squares
	var light_color = Color(0.9, 0.9, 0.8, 0.7)    # Cream with transparency
	var dark_color = Color(0.5, 0.4, 0.3, 0.7)     # Brown with transparency

	# Create 8x8 grid of squares using Panel nodes (lighter than Button)
	for row in range(8):
		var row_array = []
		for col in range(8):
			# Use Panel instead of Button for simpler, more reliable rendering
			var square = Panel.new()
			square.custom_minimum_size = Vector2(80, 80)
			square.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow mouse events to pass through

			# Create background style with classic colors
			var style_box = StyleBoxFlat.new()
			# Alternate light and dark squares for checkerboard pattern
			if (row + col) % 2 == 0:
				style_box.bg_color = light_color
			else:
				style_box.bg_color = dark_color

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
	print("Chessboard created with classic checkerboard pattern")

func load_character_assets():
	"""
	Loads themed assets for both players including:
	- Character background images (displayed in player area)
	- Character animation videos (.mp4) (displayed in CharacterDisplay)
	- Custom chess piece sprites
	This function will attempt to load assets from the assets/ folder structure.
	If assets are not found, it will use default placeholders.
	"""
	# Character folder paths
	var char1_path = "res://assets/characters/character_" + str(GameState.player1_character + 1) + "/"
	var char2_path = "res://assets/characters/character_" + str(GameState.player2_character + 1) + "/"

	# Load Player 1 assets
	var p1_anim_path = char1_path + "animations/"
	var p1_bg_path = char1_path + "backgrounds/character_background.png"
	load_character_media(player1_character_display, player1_area, p1_anim_path, p1_bg_path)

	# Load Player 2 assets
	var p2_anim_path = char2_path + "animations/"
	var p2_bg_path = char2_path + "backgrounds/character_background.png"
	load_character_media(player2_character_display, player2_area, p2_anim_path, p2_bg_path)

	print("Character assets loaded for Player 1 (", GameState.player1_character, ") and Player 2 (", GameState.player2_character, ")")

func load_random_game_background():
	"""
	Loads a random background image from the backgrounds folder and applies it
	to cover the entire game screen. The background is placed behind all other elements.
	"""
	var backgrounds_path = "res://assets/backgrounds/"
	var background_files = []

	# Get all files in the backgrounds directory
	var dir = DirAccess.open(backgrounds_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Check if it's a valid image file (not a directory or hidden file)
			if not dir.current_is_dir() and not file_name.begins_with(".") and not file_name.ends_with(".md"):
				# Check for valid image extensions
				if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
					background_files.append(backgrounds_path + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

	# If no backgrounds found, print warning and return
	if background_files.size() == 0:
		print("Warning: No background images found in ", backgrounds_path)
		print("Please add PNG or JPG images to the backgrounds folder")
		return

	# Select a random background
	var random_index = randi() % background_files.size()
	var selected_background = background_files[random_index]
	print("Selected random background: ", selected_background)

	# Load and display the background
	if FileAccess.file_exists(selected_background):
		var texture = load(selected_background)
		if texture:
			# Create TextureRect to cover the entire screen
			var background_rect = TextureRect.new()
			background_rect.texture = texture
			background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			background_rect.anchor_right = 1.0
			background_rect.anchor_bottom = 1.0
			background_rect.z_index = -100  # Place far behind everything
			background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

			# Add to the root control node (self)
			add_child(background_rect)
			move_child(background_rect, 0)  # Move to the very back
			print("Random game background loaded successfully")
		else:
			print("Error: Could not load background texture: ", selected_background)
	else:
		print("Error: Background file does not exist: ", selected_background)

func load_character_media(display_node: ColorRect, area_node: PanelContainer, animations_dir: String, bg_path: String):
	"""
	Helper function to load and display character media.
	- Video animations are displayed in the CharacterDisplay node
	- Background images are displayed in the player area container

	Args:
		display_node: The ColorRect node to display video animations
		area_node: The PanelContainer to display background images
		animations_dir: Path to the character's animations directory
		bg_path: Path to the character background image
	"""
	# Try to load video animation (only supported formats: .webm, .ogv)
	# Godot does NOT support .mp4 natively
	var supported_video_extensions = [".webm", ".ogv"]
	var video_loaded = false

	for ext in supported_video_extensions:
		var video_path = animations_dir + "character_idle" + ext
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
				print("Loaded character animation: ", video_path)
				video_loaded = true
				break

	if not video_loaded:
		print("No supported video animation found (checked .webm, .ogv)")

	# Load background image into player area
	if FileAccess.file_exists(bg_path):
		var texture = load(bg_path)
		if texture:
			# Create TextureRect to display the background behind everything
			var texture_rect = TextureRect.new()
			texture_rect.texture = texture
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			texture_rect.anchor_right = 1.0
			texture_rect.anchor_bottom = 1.0
			texture_rect.z_index = -1  # Place behind other elements
			area_node.add_child(texture_rect)
			area_node.move_child(texture_rect, 0)  # Move to back
			print("Loaded background image: ", bg_path)
	else:
		print("Warning: Character background not found: ", bg_path)

# ============================================================================
# MEDIA VALIDATION FUNCTIONS
# ============================================================================

class MediaValidationResult:
	"""
	Data structure to store media validation results.
	Tracks success/failure status and detailed error messages.
	"""
	var success: bool = true
	var errors: Array = []
	var warnings: Array = []
	var media_type: String = ""

	func add_error(message: String):
		"""Adds an error message and marks validation as failed."""
		errors.append(message)
		success = false

	func add_warning(message: String):
		"""Adds a warning message without failing validation."""
		warnings.append(message)

	func get_report() -> String:
		"""Returns a formatted report of the validation results."""
		var report = "=== %s VALIDATION REPORT ===" % media_type.to_upper()
		report += "\nStatus: " + ("PASS" if success else "FAIL")

		if errors.size() > 0:
			report += "\n\nERRORS:"
			for error in errors:
				report += "\n  - " + error

		if warnings.size() > 0:
			report += "\n\nWARNINGS:"
			for warning in warnings:
				report += "\n  - " + warning

		report += "\n" + "=".repeat(50)
		return report

func validate_game_background() -> MediaValidationResult:
	"""
	Validates that game background images exist and can be loaded.
	Checks the backgrounds folder for valid image files.

	Returns:
		MediaValidationResult with validation status and any errors/warnings
	"""
	var result = MediaValidationResult.new()
	result.media_type = "Game Background"

	var backgrounds_path = "res://assets/backgrounds/"
	var background_files = []

	# Check if backgrounds directory exists
	var dir = DirAccess.open(backgrounds_path)
	if not dir:
		result.add_error("Backgrounds directory not found: " + backgrounds_path)
		return result

	# Scan for valid image files
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and not file_name.begins_with(".") and not file_name.ends_with(".md"):
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
				background_files.append(backgrounds_path + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	# Validate that at least one background exists
	if background_files.size() == 0:
		result.add_warning("No background images found in " + backgrounds_path)
		result.add_warning("Add PNG or JPG images to display game backgrounds")
		return result

	# Validate each background file can be loaded
	var loaded_count = 0
	for bg_path in background_files:
		if FileAccess.file_exists(bg_path):
			var texture = load(bg_path)
			if texture:
				loaded_count += 1
			else:
				result.add_error("Failed to load background texture: " + bg_path)
		else:
			result.add_error("Background file does not exist: " + bg_path)

	if loaded_count > 0:
		result.add_warning("Successfully validated %d background image(s)" % loaded_count)

	return result

func validate_character_media(character_id: int, player_name: String) -> MediaValidationResult:
	"""
	Validates character-specific media assets (animations and backgrounds).
	Checks for supported video formats (.webm, .ogv) and PNG background image.
	Note: Godot does NOT support .mp4 natively - only .webm and .ogv are supported.

	Args:
		character_id: The character ID (0, 1, or 2)
		player_name: Display name for the player (for error messages)

	Returns:
		MediaValidationResult with validation status and any errors/warnings
	"""
	var result = MediaValidationResult.new()
	result.media_type = "Character %d Media (%s)" % [character_id + 1, player_name]

	var char_path = "res://assets/characters/character_" + str(character_id + 1) + "/"

	# Validate video animation (check for supported formats only)
	var supported_video_extensions = [".webm", ".ogv"]
	var video_found = false
	var animations_dir = char_path + "animations/"

	for ext in supported_video_extensions:
		var video_path = animations_dir + "character_idle" + ext
		if FileAccess.file_exists(video_path):
			var video_stream = load(video_path)
			if video_stream:
				result.add_warning("Video animation loaded successfully: " + video_path)
				video_found = true
				break
			else:
				result.add_error("Failed to load video animation: " + video_path)

	if not video_found:
		# Check if there's an unsupported MP4 file
		var mp4_path = animations_dir + "character_idle.mp4"
		if FileAccess.file_exists(mp4_path):
			result.add_warning("MP4 file found but not supported. Convert to .webm or .ogv: " + mp4_path)
		else:
			result.add_warning("No supported video animation found (checked .webm, .ogv)")

	# Validate background image
	var bg_path = char_path + "backgrounds/character_background.png"
	if FileAccess.file_exists(bg_path):
		var texture = load(bg_path)
		if texture:
			result.add_warning("Background image loaded successfully: " + bg_path)
		else:
			result.add_error("Failed to load background image: " + bg_path)
	else:
		result.add_error("Background image not found: " + bg_path)

	return result

func validate_all_media() -> void:
	"""
	Comprehensive validation of all media assets used in the game.
	Validates:
	- Game background images
	- Player 1 character media (animation + background)
	- Player 2 character media (animation + background)

	Prints detailed reports to console and shows error dialog if critical failures occur.
	"""
	print("\n" + "=".repeat(60))
	print("MEDIA VALIDATION: Starting comprehensive media check")
	print("=".repeat(60))

	var all_results = []
	var has_critical_errors = false

	# Validate game backgrounds
	var bg_result = validate_game_background()
	all_results.append(bg_result)
	print(bg_result.get_report())
	if not bg_result.success:
		has_critical_errors = true

	# Validate Player 1 character media
	var player1_name = GameState.get_player_display_name(1)
	var p1_result = validate_character_media(GameState.player1_character, player1_name)
	all_results.append(p1_result)
	print(p1_result.get_report())
	if not p1_result.success:
		has_critical_errors = true

	# Validate Player 2 character media
	var player2_name = GameState.get_player_display_name(2)
	var p2_result = validate_character_media(GameState.player2_character, player2_name)
	all_results.append(p2_result)
	print(p2_result.get_report())
	if not p2_result.success:
		has_critical_errors = true

	# Print summary
	print("\n" + "=".repeat(60))
	if has_critical_errors:
		print("MEDIA VALIDATION: FAILED - Critical errors detected")
		show_media_validation_error(all_results)
	else:
		print("MEDIA VALIDATION: PASSED - All media loaded successfully")
	print("=".repeat(60) + "\n")

func show_media_validation_error(results: Array):
	"""
	Displays a dialog showing media validation errors to the user.

	Args:
		results: Array of MediaValidationResult objects
	"""
	var error_dialog = AcceptDialog.new()
	error_dialog.title = "Media Asset Warning"

	var error_text = "Some media assets could not be loaded:\n\n"

	for result in results:
		if not result.success or result.warnings.size() > 0:
			error_text += result.media_type + ":\n"
			for error in result.errors:
				error_text += "  ERROR: " + error + "\n"
			for warning in result.warnings:
				error_text += "  INFO: " + warning + "\n"
			error_text += "\n"

	error_text += "The game will continue with fallback visuals."

	error_dialog.dialog_text = error_text
	error_dialog.ok_button_text = "Continue"
	add_child(error_dialog)
	error_dialog.popup_centered()

	print("Media validation error dialog displayed")

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
	Uses custom character-themed images from the assets folder.

	Args:
		piece: The ChessPiece object containing piece data
		pos: Board position (row, col) where the piece should be displayed
	"""
	# Determine which character's assets to use based on piece color
	var character_id = GameState.player1_character if piece.piece_color == ChessPiece.PieceColor.WHITE else GameState.player2_character

	# Get piece type name
	var piece_type_name = ChessPiece.PieceType.keys()[piece.piece_type].to_lower()

	# Construct path to piece image
	var piece_image_path = "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id + 1, piece_type_name]

	# Try to load the custom piece image
	if FileAccess.file_exists(piece_image_path):
		var texture = load(piece_image_path)
		if texture:
			# Create TextureRect to display the piece image
			var piece_texture_rect = TextureRect.new()
			piece_texture_rect.texture = texture
			piece_texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			piece_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			piece_texture_rect.mouse_filter = Control.MOUSE_FILTER_PASS

			# Center the piece within its square using anchors
			piece_texture_rect.anchor_left = 0.0
			piece_texture_rect.anchor_top = 0.0
			piece_texture_rect.anchor_right = 1.0
			piece_texture_rect.anchor_bottom = 1.0
			piece_texture_rect.offset_left = 0
			piece_texture_rect.offset_top = 0
			piece_texture_rect.offset_right = 0
			piece_texture_rect.offset_bottom = 0
			piece_texture_rect.grow_horizontal = Control.GROW_DIRECTION_BOTH
			piece_texture_rect.grow_vertical = Control.GROW_DIRECTION_BOTH

			# Apply color modulation for black pieces
			if piece.piece_color == ChessPiece.PieceColor.BLACK:
				# Define theme-based tint colors for black pieces
				var tint_colors = {
					"classic": Color(0.3, 0.3, 0.3),    # Dark gray
					"modern": Color(0.2, 0.3, 0.5),     # Dark blue
					"fantasy": Color(0.5, 0.2, 0.4)     # Dark purple
				}
				var piece_style = piece.character_style
				if piece_style in tint_colors:
					piece_texture_rect.modulate = tint_colors[piece_style]
				else:
					piece_texture_rect.modulate = Color(0.3, 0.3, 0.3)  # Default dark gray

			# Add piece to the board square and track it
			board_squares[pos.x][pos.y].add_child(piece_texture_rect)
			visual_pieces.append(piece_texture_rect)
			return

	# Fallback to Unicode symbols if image not found
	var piece_label = Label.new()
	piece_label.text = piece.get_piece_symbol()
	piece_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	piece_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	piece_label.add_theme_font_size_override("font_size", 56)
	piece_label.mouse_filter = Control.MOUSE_FILTER_PASS

	# Center the piece label within its square using anchors
	piece_label.anchor_left = 0.0
	piece_label.anchor_top = 0.0
	piece_label.anchor_right = 1.0
	piece_label.anchor_bottom = 1.0
	piece_label.offset_left = 0
	piece_label.offset_top = 0
	piece_label.offset_right = 0
	piece_label.offset_bottom = 0
	piece_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	piece_label.grow_vertical = Control.GROW_DIRECTION_BOTH

	# Apply theme-based colors to pieces
	var style_colors = {
		"classic": {"white": Color(1, 1, 1), "black": Color(0.2, 0.2, 0.2)},
		"modern": {"white": Color(0.8, 0.9, 1), "black": Color(0.1, 0.2, 0.4)},
		"fantasy": {"white": Color(1, 0.9, 0.7), "black": Color(0.4, 0.1, 0.3)}
	}

	var piece_theme_style = piece.character_style
	if not piece_theme_style in style_colors:
		piece_theme_style = "classic"

	var color_key = "white" if piece.piece_color == ChessPiece.PieceColor.WHITE else "black"
	piece_label.add_theme_color_override("font_color", style_colors[piece_theme_style][color_key])

	# Add piece to the board square and track it
	board_squares[pos.x][pos.y].add_child(piece_label)
	visual_pieces.append(piece_label)

	print("Warning: Could not load piece image: ", piece_image_path, " - using Unicode fallback")

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
	# Ignore clicks if game has ended
	if game_ended:
		return

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
	If successful, highlights valid moves and starts drag operation.

	Args:
		pos: The board position to select from
	"""
	# Ignore selection attempts if game has ended
	if game_ended:
		return

	clear_highlights()
	if chess_board.select_piece(pos):
		selected_square = pos
		highlight_valid_moves()
		# Start drag operation with visual feedback
		start_drag(pos)

# ============================================================================
# BOARD HIGHLIGHTING FUNCTIONS
# ============================================================================

func highlight_valid_moves():
	"""
	Highlights the selected piece and all its valid moves on the board.
	Uses image-based highlights with glow effects for enhanced visuals.
	- Selected square: Yellow highlight
	- Valid moves: Green glowing highlight
	- Capture moves: Red glowing highlight
	"""
	# Load highlight textures on first use
	if not highlights_loaded:
		load_highlight_textures()

	# Highlight the currently selected square in yellow
	var selected = board_squares[selected_square.x][selected_square.y]
	var highlight_style = StyleBoxFlat.new()
	highlight_style.bg_color = Color(1, 1, 0, 0.5)  # Semi-transparent yellow
	selected.add_theme_stylebox_override("panel", highlight_style)

	# Highlight all valid moves for the selected piece
	for move in chess_board.valid_moves:
		var square = board_squares[move.x][move.y]
		var is_capture = chess_board.get_piece_at(move) != null

		# Create highlight overlay (image or fallback visual effect)
		create_highlight_overlay(square, is_capture)

func load_highlight_textures():
	"""
	Loads highlight images from the assets folder.
	If images don't exist, the system will use fallback visual effects.
	Called once on first highlight to cache the textures.
	"""
	highlights_loaded = true

	# Try to load valid move highlight
	var valid_move_path = "res://assets/ui/highlights/valid_move.png"
	if FileAccess.file_exists(valid_move_path):
		valid_move_texture = load(valid_move_path)
		if valid_move_texture:
			print("Loaded valid move highlight texture")

	# Try to load capture move highlight
	var capture_move_path = "res://assets/ui/highlights/capture_move.png"
	if FileAccess.file_exists(capture_move_path):
		capture_move_texture = load(capture_move_path)
		if capture_move_texture:
			print("Loaded capture move highlight texture")

	# Log fallback if textures not found
	if not valid_move_texture or not capture_move_texture:
		print("Using fallback glow effects for highlights (no images found)")

func create_highlight_overlay(square: Panel, is_capture: bool):
	"""
	Creates a visual highlight overlay on a chess square.
	Uses images if available, otherwise creates a glowing effect with ColorRect.

	Args:
		square: The square panel to add the highlight to
		is_capture: True for capture moves (red), False for regular moves (green)
	"""
	var overlay: Control = null

	# Determine which texture/color to use
	var use_texture = capture_move_texture if is_capture else valid_move_texture
	var fallback_color = Color(1, 0.3, 0.3, 0.6) if is_capture else Color(0.3, 1, 0.3, 0.6)

	if use_texture:
		# Use image-based highlight
		var texture_rect = TextureRect.new()
		texture_rect.texture = use_texture
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# Fill the entire square
		texture_rect.anchor_left = 0.0
		texture_rect.anchor_top = 0.0
		texture_rect.anchor_right = 1.0
		texture_rect.anchor_bottom = 1.0

		overlay = texture_rect
	else:
		# Use fallback glow effect with ColorRect
		var color_rect = ColorRect.new()
		color_rect.color = fallback_color
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# Fill the entire square
		color_rect.anchor_left = 0.0
		color_rect.anchor_top = 0.0
		color_rect.anchor_right = 1.0
		color_rect.anchor_bottom = 1.0

		# Add pulsing animation for glow effect
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(color_rect, "color:a", 0.3, 0.8)
		tween.tween_property(color_rect, "color:a", 0.6, 0.8)

		overlay = color_rect

	# Add overlay to square and track it for cleanup
	square.add_child(overlay)
	highlight_overlays.append(overlay)

func clear_highlights():
	"""
	Removes all move highlights and restores the classic chessboard colors.
	This includes removing image overlays and resetting square colors.
	This function is called after a move is made or selection is cancelled.
	"""
	# Remove all highlight overlays
	for overlay in highlight_overlays:
		if overlay and is_instance_valid(overlay):
			overlay.queue_free()
	highlight_overlays.clear()

	# Use classic chess colors (must match setup_chessboard)
	var light_color = Color(0.9, 0.9, 0.8, 0.7)    # Cream with transparency
	var dark_color = Color(0.5, 0.4, 0.3, 0.7)     # Brown with transparency

	# Restore classic colors to all squares
	for row in range(8):
		for col in range(8):
			var square = board_squares[row][col]

			var style_box = StyleBoxFlat.new()
			# Restore checkerboard pattern with classic colors
			if (row + col) % 2 == 0:
				style_box.bg_color = light_color
			else:
				style_box.bg_color = dark_color

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
	Shows piece images in the player info areas at top and bottom of screen.
	Captured pieces are displayed using the same images as the pieces on the board.
	Called whenever a piece is captured.
	"""
	# Clear existing captured pieces
	for child in player1_captured_container.get_children():
		child.queue_free()
	for child in player2_captured_container.get_children():
		child.queue_free()

	# Display pieces captured by Player 1 (Black pieces that were captured)
	for piece in chess_board.get_captured_by_white():
		var captured_piece_visual = create_captured_piece_visual(piece)
		if captured_piece_visual:
			player1_captured_container.add_child(captured_piece_visual)

	# Display pieces captured by Player 2 (White pieces that were captured)
	for piece in chess_board.get_captured_by_black():
		var captured_piece_visual = create_captured_piece_visual(piece)
		if captured_piece_visual:
			player2_captured_container.add_child(captured_piece_visual)

func create_captured_piece_visual(piece: ChessPiece) -> Control:
	"""
	Creates a visual representation of a captured piece using the same image as on the board.

	Args:
		piece: The captured ChessPiece object

	Returns:
		A Control node with the piece image, or null if image not found
	"""
	# Determine which character's assets to use based on piece color
	var character_id = GameState.player1_character if piece.piece_color == ChessPiece.PieceColor.WHITE else GameState.player2_character

	# Get piece type name
	var piece_type_name = ChessPiece.PieceType.keys()[piece.piece_type].to_lower()

	# Construct path to piece image
	var piece_image_path = "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id + 1, piece_type_name]

	# Try to load the custom piece image
	if FileAccess.file_exists(piece_image_path):
		var texture = load(piece_image_path)
		if texture:
			# Create TextureRect to display the captured piece image
			var visual_piece = TextureRect.new()
			visual_piece.texture = texture
			visual_piece.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			visual_piece.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			visual_piece.custom_minimum_size = Vector2(30, 30)  # Smaller size for captured pieces
			visual_piece.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

			# Apply color modulation for black pieces (same as on board)
			if piece.piece_color == ChessPiece.PieceColor.BLACK:
				# Define theme-based tint colors for black pieces
				var tint_colors = {
					"classic": Color(0.3, 0.3, 0.3),
					"modern": Color(0.2, 0.3, 0.5),
					"fantasy": Color(0.5, 0.2, 0.4)
				}
				var captured_piece_style = piece.character_style
				if captured_piece_style in tint_colors:
					visual_piece.modulate = tint_colors[captured_piece_style]
				else:
					visual_piece.modulate = Color(0.3, 0.3, 0.3)

			return visual_piece

	# Fallback to Unicode symbol if image not found
	var label = Label.new()
	label.text = piece.get_piece_symbol()
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	return label

# ============================================================================
# DRAG AND DROP FUNCTIONS
# ============================================================================

func create_drag_shadow(piece_node: Control):
	"""
	Creates a shadow/glow effect behind the dragged piece for visual feedback.
	The shadow follows the piece during dragging.

	Args:
		piece_node: The piece node being dragged
	"""
	# Remove any existing shadow
	if drag_shadow:
		drag_shadow.queue_free()
		drag_shadow = null

	# Create a ColorRect as shadow
	drag_shadow = ColorRect.new()
	drag_shadow.color = Color(0, 0, 0, 0.3)  # Semi-transparent black shadow
	drag_shadow.z_index = 99  # Just behind the dragged piece

	# Match the piece's size and position
	drag_shadow.custom_minimum_size = piece_node.size
	drag_shadow.size = piece_node.size
	drag_shadow.global_position = piece_node.global_position + Vector2(5, 5)  # Offset for shadow effect

	# Add shadow to the scene
	add_child(drag_shadow)

func update_drag_shadow():
	"""
	Updates the shadow position to follow the dragged piece.
	Called during dragging in _input().
	"""
	if drag_shadow and dragging_piece:
		drag_shadow.global_position = dragging_piece.global_position + Vector2(8, 8)  # Shadow offset

func remove_drag_shadow():
	"""
	Removes the drag shadow effect when dragging ends.
	"""
	if drag_shadow:
		drag_shadow.queue_free()
		drag_shadow = null

func start_drag(pos: Vector2i):
	"""
	Initiates a drag operation for the piece at the given position.
	Adds visual feedback including scaling, transparency, and shadow effect.
	Works with both TextureRect (images) and Label (Unicode fallback) pieces.

	Args:
		pos: Board position of the piece to start dragging
	"""
	# Don't allow dragging if game has ended
	if game_ended:
		return

	var square = board_squares[pos.x][pos.y]
	if square.get_child_count() > 0:
		var piece_node = square.get_child(0)

		# Support both TextureRect and Label pieces
		if piece_node is TextureRect or piece_node is Label:
			# Store reference to the piece and its original position
			dragging_piece = piece_node
			original_parent = square
			original_scale = piece_node.scale

			# Get current mouse/touch position
			var mouse_pos = get_viewport().get_mouse_position()

			# Calculate offset from mouse to piece center for smooth dragging
			var piece_center = piece_node.global_position + (piece_node.size / 2)
			drag_offset = piece_center - mouse_pos

			# Create shadow/glow effect behind the piece
			create_drag_shadow(piece_node)

			# Apply visual effects for dragging
			# 1. Scale up slightly (1.2x) for emphasis
			var tween_scale = create_tween()
			tween_scale.tween_property(piece_node, "scale", original_scale * 1.2, 0.1)

			# 2. Make piece semi-transparent (80% opacity)
			piece_node.modulate = Color(1, 1, 1, 0.8)

			# 3. Bring piece to front (above all other elements)
			piece_node.z_index = 100

			# Update drag state
			is_dragging = true

			print("Started dragging piece at ", pos)

func end_drag(drop_position: Vector2):
	"""
	Ends a drag operation and attempts to place the piece on a square.
	Restores visual effects (scale, opacity, shadow) and validates the move.
	If the move is valid, the piece is moved. Otherwise, it returns to its original position.

	Args:
		drop_position: The screen position where the piece was dropped
	"""
	if not is_dragging or dragging_piece == null:
		return

	# Don't allow piece placement if game has ended
	if game_ended:
		return_piece_to_original_position()
		return

	# Remove the shadow effect
	remove_drag_shadow()

	# Restore piece appearance with smooth animation
	if dragging_piece:
		# Restore scale to original with animation
		var tween_scale = create_tween()
		tween_scale.tween_property(dragging_piece, "scale", original_scale, 0.1)

		# Restore full opacity
		dragging_piece.modulate = Color(1, 1, 1, 1)

		# Reset z-index to normal
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
			print("Piece moved successfully to ", dropped_on_square)
		else:
			# Move invalid - flash red and return piece
			if dropped_on_square != Vector2i(-1, -1):
				flash_square_red(dropped_on_square)
			return_piece_to_original_position()
			print("Invalid move attempted to ", dropped_on_square)
	else:
		# Dropped outside board - return piece to original position
		return_piece_to_original_position()
		print("Piece dropped outside board - returning to origin")

func return_piece_to_original_position():
	"""
	Returns a dragged piece back to its original square with smooth animation.
	Animates the piece flying back to its original position when an invalid move is attempted.
	Restores all visual effects (scale, opacity, shadow).
	Called when a drag operation is cancelled or an invalid move is attempted.
	"""
	# Remove shadow effect
	remove_drag_shadow()

	if dragging_piece and original_parent:
		# Calculate the target position (center of original square)
		var target_position = original_parent.global_position + (original_parent.size / 2) - (dragging_piece.size / 2)

		# Create animation tween for smooth return
		var tween = create_tween()
		tween.set_parallel(true)  # Run all animations simultaneously
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)  # "Bounce back" effect

		# Animate position back to original square
		tween.tween_property(dragging_piece, "global_position", target_position, 0.3)

		# Restore scale to original with animation
		tween.tween_property(dragging_piece, "scale", original_scale, 0.3)

		# Restore full opacity with animation
		tween.tween_property(dragging_piece, "modulate", Color(1, 1, 1, 1), 0.3)

		# After animation completes, clean up drag state
		tween.chain().tween_callback(func():
			if dragging_piece:
				dragging_piece.z_index = 0
			dragging_piece = null
			is_dragging = false
			original_parent = null
			clear_highlights()
			selected_square = Vector2i(-1, -1)
			print("Piece returned to original position")
		)
	else:
		# Fallback if no dragging_piece or original_parent
		if dragging_piece:
			dragging_piece.modulate = Color(1, 1, 1, 1)
			dragging_piece.z_index = 0

		# Reset all drag state
		dragging_piece = null
		is_dragging = false
		original_parent = null
		clear_highlights()
		selected_square = Vector2i(-1, -1)

		print("Piece returned to original position (fallback)")

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

	# Get the original classic color for this square
	var light_color = Color(0.9, 0.9, 0.8, 0.7)    # Cream with transparency
	var dark_color = Color(0.5, 0.4, 0.3, 0.7)     # Brown with transparency
	var original_color = light_color if (pos.x + pos.y) % 2 == 0 else dark_color

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

func _on_piece_moved(from_pos: Vector2i, to_pos: Vector2i, _piece: ChessPiece):
	"""
	Called when a piece is successfully moved on the board.
	Connected to the chess_board.piece_moved signal.

	Args:
		from_pos: Starting position of the piece
		to_pos: Ending position of the piece
		_piece: The piece that was moved (unused)
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
	var p1_minutes = int(GameState.player1_time_remaining / 60)
	var p1_seconds = int(GameState.player1_time_remaining) % 60
	player1_timer_label.text = "Time: %02d:%02d" % [p1_minutes, p1_seconds]

	# Format Player 2's time as MM:SS
	var p2_minutes = int(GameState.player2_time_remaining / 60)
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
	# Use player names (username or "Player 1/2") instead of White/Black
	var player1_name = GameState.get_player_display_name(1)
	var player2_name = GameState.get_player_display_name(2)

	var result_text = ""
	match result:
		"checkmate_white":
			result_text = "Checkmate! " + player1_name + " Wins!"
		"checkmate_black":
			result_text = "Checkmate! " + player2_name + " Wins!"
		"stalemate":
			result_text = "Stalemate! It's a Draw!"
		"draw":
			result_text = "Draw!"
		"timeout_white_wins":
			result_text = "Time's Up! " + player1_name + " Wins!"
		"timeout_black_wins":
			result_text = "Time's Up! " + player2_name + " Wins!"
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
	var history_text_label = Label.new()
	var moves_text = ""
	for i in range(GameState.move_history.size()):
		var move_num = int(i / 2) + 1  # Calculate move number
		if i % 2 == 0:
			# White's move
			moves_text += str(move_num) + ". " + GameState.move_history[i]
			if i + 1 < GameState.move_history.size():
				# Add black's move on the same line
				moves_text += "  " + GameState.move_history[i + 1] + "\n"
			else:
				moves_text += "\n"

	history_text_label.text = moves_text
	history_text_label.add_theme_font_size_override("font_size", 16)
	history_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	scroll.add_child(history_text_label)
	content.add_child(scroll)

	# Add content to dialog and show it
	dialog.add_child(content)
	add_child(dialog)
	dialog.popup_centered()

	# Return to menu when dialog is closed
	dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/login_page.tscn"))
