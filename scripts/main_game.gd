extends Control

# ============================================================================
# NODE REFERENCES - UI ADJUSTMENT GUIDE
# ============================================================================
# These @onready variables store references to UI nodes in the scene tree.
# They are automatically assigned when the scene is loaded.
#
# **HOW TO ADJUST THE MAIN GAME UI:**
#
# 1. CHESSBOARD SIZE & POSITION:
#    - Node path: $MainContainer/GameArea/ChessboardContainer
#    - To adjust: Modify the scene file (main_game.tscn) or adjust in setup_chessboard()
#    - Zoom functionality: Use mouse wheel (implemented in zoom_chessboard() function)
#
# 2. PLAYER AREAS (Top & Bottom sections):
#    - Player 1 (Bottom): $MainContainer/BottomPlayerArea
#    - Player 2 (Top): $MainContainer/TopPlayerArea
#    - To adjust: Modify size_flags, custom_minimum_size in the scene file
#
# 3. CHARACTER ANIMATIONS (Live2D & Video):
#    - Player 1: $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/CharacterDisplayWrapper/CharacterDisplay
#    - Player 2: $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/CharacterDisplayWrapper/CharacterDisplay
#    - To adjust size: Modify 'custom_minimum_size' in scenes/game/main_game.tscn (lines ~87, 95, 242, 250)
#    - Current size: 400x400px (increased to show full Live2D character)
#    - Recommended range: 300-600px (adjust both CharacterDisplayWrapper and CharacterDisplay to same value)
#    - Aspect ratio: 1:1 (square) enforced by AspectRatioContainer
#    - For Live2D scale/position adjustments: Use Character Animation Debugger (Press 'D' in game)
#    - Code location: load_character_media() function (line ~957)
#
# 4. PLAYER INFO LABELS (Names, Timers, Captured Pieces):
#    - Located in: $MainContainer/BottomPlayerArea/.../PlayerInfo
#    - To adjust: Modify font sizes via add_theme_font_size_override() in update functions
#    - Timer colors: Adjust in update_timer_display() (line ~1634)
#
# 5. SCORE PANEL:
#    - Node path: $MainContainer/GameArea/ScorePanel
#    - Toggle button: $MainContainer/GameArea/ChessboardContainer/ScoreToggleButton
#    - To adjust: Modify setup_score_toggle() (line ~2238) and toggle_score_panel() (line ~2271)
#    - Visibility: Hidden by default, toggle with button
#    - Animation: Smooth zoom effect on chessboard when toggled (scales to 0.85x when open)
#
# 6. GAME BACKGROUNDS:
#    - Loaded in: load_random_background() (line ~99) and load_random_game_background() (line ~471)
#    - Background folder: res://assets/backgrounds/
#    - Z-index: -100 (behind all UI elements)
#
# 7. CHESSBOARD COLORS & STYLING:
#    - Square colors: Defined in setup_chessboard() (line ~430)
#    - Light squares: Color(0.9, 0.9, 0.8, 0.7)
#    - Dark squares: Color(0.5, 0.4, 0.3, 0.7)
#    - To adjust: Modify light_color and dark_color variables
#
# 8. PIECE IMAGES:
#    - Loaded in: create_visual_piece() (line ~873)
#    - Asset path: res://assets/characters/character_X/pieces/
#    - To adjust piece size: Modify custom_minimum_size in create_visual_piece()
# ============================================================================

# Chessboard and game area references
@onready var chessboard = $MainContainer/GameArea/ChessboardContainer/MarginContainer/AspectRatioContainer/Chessboard
@onready var chessboard_container = $MainContainer/GameArea/ChessboardContainer

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
@onready var score_toggle_button = $MainContainer/GameArea/ChessboardContainer/ScoreToggleButton

# Player timer labels
@onready var player1_timer_label = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/TimerLabel
@onready var player2_timer_label = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/TimerLabel

# Player character display areas (for video animations)
# UI ADJUSTMENT: To change character animation size, use the debugger (Press 'D') or modify custom_minimum_size in load_character_media()
@onready var player1_character_display = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/CharacterDisplayWrapper/CharacterDisplay
@onready var player2_character_display = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/CharacterDisplayWrapper/CharacterDisplay

# Player area containers (for background images)
# UI ADJUSTMENT: Character backgrounds are disabled in Main Game. To re-enable, uncomment code in load_character_media() (line ~637)
@onready var player1_area = $MainContainer/BottomPlayerArea
@onready var player2_area = $MainContainer/TopPlayerArea
@onready var game_area = $MainContainer/GameArea
@onready var main_container = $MainContainer

# ============================================================================
# GAME STATE VARIABLES
# ============================================================================

# Core chess game logic instance
var chess_board: ChessBoard

# Visual representation of chess pieces on the board
var visual_pieces: Array = []

# Node2D layer for chess piece sprites (Sprite2D nodes)
var pieces_layer: Node2D = null

# 2D array of button nodes representing board squares [row][col]
var board_squares: Array = []

# Currently selected square position (-1, -1 means no selection)
var selected_square: Vector2i = Vector2i(-1, -1)

# Score panel visibility state
var score_panel_visible: bool = false  # Hidden by default

# Game state flag
var game_ended: bool = false

# ============================================================================
# CHESSBOARD ZOOM AND PAN VARIABLES
# ============================================================================
# Current zoom level (1.0 = 100%, 0.7 = 70%, 0.8 = 80%, 0.9 = 90%)
var chessboard_zoom: float = 1.0
# Minimum zoom level (70%)
const MIN_ZOOM: float = 0.7
# Maximum zoom level (100% - full screen fit)
const MAX_ZOOM: float = 1.0
# Zoom step per scroll wheel notch (allows 70%, 80%, 90%, 100%)
const ZOOM_STEP: float = 0.1

# Chessboard panning variables
var is_panning: bool = false
var pan_start_position: Vector2 = Vector2.ZERO
var chessboard_offset: Vector2 = Vector2.ZERO
var last_chessboard_position: Vector2 = Vector2.ZERO
# Track touch points for pinch-to-zoom and two-finger drag
var touch_points: Dictionary = {}
var initial_touch_distance: float = 0.0
var initial_zoom: float = 1.0

# ============================================================================
# CHARACTER ANIMATION DEBUGGER VARIABLES
# ============================================================================
# Debug panel for character animations
var animation_debug_panel: PanelContainer = null
# Toggle visibility of debug panel
var animation_debug_visible: bool = false

# ============================================================================
# LIVE2D DEBUGGER VARIABLES
# ============================================================================
# Debug panel for Live2D characters
var live2d_debug_panel: PanelContainer = null
# Toggle visibility of Live2D debug panel
var live2d_debug_visible: bool = false

# ============================================================================
# Animation Error Viewer
var error_viewer: PanelContainer = null
var error_viewer_visible: bool = false

# ============================================================================
# PIECE EFFECTS SYSTEM
# ============================================================================
# Reference to piece effects system for drag animations
var piece_effects: Node = null

# Held piece scale multiplier - adjust this value to scale all held pieces
# Default: 1.0 (100% size), increase for larger held pieces, decrease for smaller
# Example: 1.2 = 120% size, 0.8 = 80% size
var held_piece_scale_multiplier: float = 1.0

# ============================================================================
# DRAG AND DROP SYSTEM VARIABLES
# ============================================================================

# Reference to the piece currently being dragged (TextureRect or Label)
var dragging_piece: Node2D = null

# Offset from mouse position to piece center for smooth dragging
var drag_offset: Vector2 = Vector2.ZERO

# Original parent node to return piece to if drag is cancelled
var original_parent: Node2D = null

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
# HELPER FUNCTIONS
# ============================================================================

## Helper function to repeat strings (GDScript compatibility)
static func repeat_string(s: String, count: int) -> String:
	var result = ""
	for i in count:
		result += s
	return result

# ============================================================================
# INITIALIZATION FUNCTIONS
# ============================================================================

func load_random_background():
	"""
	Loads a random background (image or video) from the game backgrounds folder
	and applies it to cover the entire screen. The background is placed behind all other elements.
	Supports static images (PNG, JPG) and dynamic videos (WebM, OGV).
	"""
	var backgrounds_path = "res://assets/backgrounds/"
	var background_files = []

	# Get all files in the backgrounds directory
	var dir = DirAccess.open(backgrounds_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Check if it's a valid file (not a directory or hidden file)
			if not dir.current_is_dir() and not file_name.begins_with(".") and not file_name.ends_with(".md"):
				# Check for valid image and video extensions
				if (file_name.ends_with(".png") or file_name.ends_with(".jpg") or
					file_name.ends_with(".jpeg") or file_name.ends_with(".webm") or
					file_name.ends_with(".ogv")):
					background_files.append(backgrounds_path + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

	# If no backgrounds found, print warning and return
	if background_files.size() == 0:
		print("Warning: No background files found in ", backgrounds_path)
		return

	# Select a random background
	var random_index = randi() % background_files.size()
	var selected_background = background_files[random_index]
	print("Selected random background: ", selected_background)

	# Determine if it's a video or image
	var is_video = selected_background.ends_with(".webm") or selected_background.ends_with(".ogv")

	# Load and display the background
	if FileAccess.file_exists(selected_background):
		if is_video:
			# Load video background
			var video_stream = load(selected_background)
			if video_stream:
				var video_player = VideoStreamPlayer.new()
				video_player.stream = video_stream
				video_player.autoplay = true
				video_player.loop = true
				video_player.expand = true
				video_player.anchor_right = 1.0
				video_player.anchor_bottom = 1.0
				video_player.z_index = -100  # Place far behind everything
				video_player.mouse_filter = Control.MOUSE_FILTER_IGNORE

				# Add to the root control node (self)
				add_child(video_player)
				move_child(video_player, 0)  # Move to the very back
				print("Random video background loaded successfully")
			else:
				print("Error: Could not load video stream: ", selected_background)
		else:
			# Load image background
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
				print("Random image background loaded successfully")
			else:
				print("Error: Could not load background texture: ", selected_background)
	else:
		print("Error: Background file does not exist: ", selected_background)

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

	# Load random background for the game
	load_random_background()

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
	chess_board.check_detected.connect(_on_check_detected)
	print("STEP 6: Signals connected ✓")

	# STEP 7: Initialize all game components
	print("\nSTEP 7: Initializing game components...")
	load_random_game_background() # Load random background for the game
	setup_chessboard()           # Create the 8x8 grid of squares
	update_character_displays()   # Show selected characters
	load_character_assets()       # Load themed assets (backgrounds, videos)
	validate_all_media()          # Validate all media assets and report errors
	# Wait for one frame to ensure Control nodes have their final positions/sizes
	await get_tree().process_frame
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

	# Initialize character animation debugger
	create_animation_debugger()

	# Initialize Live2D debugger
	create_live2d_debugger()

	# Initialize animation error viewer
	create_error_viewer()

	# Initialize piece effects system
	piece_effects = preload("res://scripts/piece_effects.gd").new()
	add_child(piece_effects)
	print("PIECE EFFECTS: System initialized ✓")

	# Print final status
	ChessboardStorage.print_status()

	# Setup responsive layout
	setup_responsive_layout()

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
# CHARACTER ANIMATION DEBUGGER FUNCTIONS
# ============================================================================

func create_animation_debugger():
	"""
	Creates a floating debug panel for character animations in Main Game.
	This panel allows you to:
	- Adjust character animation position (X, Y offset)
	- Adjust character animation scale
	- Adjust character animation opacity
	- Toggle visibility
	- View current properties

	Press 'D' key to toggle the debug panel visibility.
	"""
	# Create main panel container
	animation_debug_panel = PanelContainer.new()
	animation_debug_panel.name = "AnimationDebugPanel"
	animation_debug_panel.position = Vector2(10, 100)
	animation_debug_panel.custom_minimum_size = Vector2(350, 500)
	animation_debug_panel.visible = false  # Hidden by default
	animation_debug_panel.z_index = 1000  # Always on top

	# Create a stylebox for the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.3, 0.6, 1.0, 1.0)
	animation_debug_panel.add_theme_stylebox_override("panel", panel_style)

	# Create main VBoxContainer for content
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	animation_debug_panel.add_child(vbox)

	# Add margin container for padding
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	vbox.add_child(margin)

	# Create content container
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 15)
	margin.add_child(content)

	# Title
	var title = Label.new()
	title.text = "CHARACTER ANIMATION DEBUGGER"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.3, 0.6, 1.0, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)

	# Separator
	var sep1 = HSeparator.new()
	content.add_child(sep1)

	# Instructions
	var instructions = Label.new()
	instructions.text = "Press 'D' to toggle this panel\nAdjust character animations below:"
	instructions.add_theme_font_size_override("font_size", 12)
	instructions.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	content.add_child(instructions)

	# Player 1 Section
	var p1_label = Label.new()
	p1_label.text = "PLAYER 1 (Bottom) Animation"
	p1_label.add_theme_font_size_override("font_size", 14)
	p1_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.5, 1.0))
	content.add_child(p1_label)

	# Player 1 Scale
	var p1_scale_label = Label.new()
	p1_scale_label.text = "Scale: 1.0x"
	p1_scale_label.add_theme_font_size_override("font_size", 11)
	content.add_child(p1_scale_label)

	var p1_scale_slider = HSlider.new()
	p1_scale_slider.min_value = 0.5
	p1_scale_slider.max_value = 3.0
	p1_scale_slider.step = 0.1
	p1_scale_slider.value = 1.0
	p1_scale_slider.custom_minimum_size = Vector2(300, 20)
	content.add_child(p1_scale_slider)

	# Player 1 Opacity
	var p1_opacity_label = Label.new()
	p1_opacity_label.text = "Opacity: 100%"
	p1_opacity_label.add_theme_font_size_override("font_size", 11)
	content.add_child(p1_opacity_label)

	var p1_opacity_slider = HSlider.new()
	p1_opacity_slider.min_value = 0.0
	p1_opacity_slider.max_value = 1.0
	p1_opacity_slider.step = 0.05
	p1_opacity_slider.value = 1.0
	p1_opacity_slider.custom_minimum_size = Vector2(300, 20)
	content.add_child(p1_opacity_slider)

	# Player 1 Visibility Toggle
	var p1_visibility = CheckButton.new()
	p1_visibility.text = "Visible"
	p1_visibility.button_pressed = true
	content.add_child(p1_visibility)

	# Separator
	var sep2 = HSeparator.new()
	content.add_child(sep2)

	# Player 2 Section
	var p2_label = Label.new()
	p2_label.text = "PLAYER 2 (Top) Animation"
	p2_label.add_theme_font_size_override("font_size", 14)
	p2_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.5, 1.0))
	content.add_child(p2_label)

	# Player 2 Scale
	var p2_scale_label = Label.new()
	p2_scale_label.text = "Scale: 1.0x"
	p2_scale_label.add_theme_font_size_override("font_size", 11)
	content.add_child(p2_scale_label)

	var p2_scale_slider = HSlider.new()
	p2_scale_slider.min_value = 0.5
	p2_scale_slider.max_value = 3.0
	p2_scale_slider.step = 0.1
	p2_scale_slider.value = 1.0
	p2_scale_slider.custom_minimum_size = Vector2(300, 20)
	content.add_child(p2_scale_slider)

	# Player 2 Opacity
	var p2_opacity_label = Label.new()
	p2_opacity_label.text = "Opacity: 100%"
	p2_opacity_label.add_theme_font_size_override("font_size", 11)
	content.add_child(p2_opacity_label)

	var p2_opacity_slider = HSlider.new()
	p2_opacity_slider.min_value = 0.0
	p2_opacity_slider.max_value = 1.0
	p2_opacity_slider.step = 0.05
	p2_opacity_slider.value = 1.0
	p2_opacity_slider.custom_minimum_size = Vector2(300, 20)
	content.add_child(p2_opacity_slider)

	# Player 2 Visibility Toggle
	var p2_visibility = CheckButton.new()
	p2_visibility.text = "Visible"
	p2_visibility.button_pressed = true
	content.add_child(p2_visibility)

	# Connect signals for Player 1
	p1_scale_slider.value_changed.connect(func(value):
		p1_scale_label.text = "Scale: %.1fx" % value
		var model = get_live2d_model_from_display(player1_character_display)
		if model:
			model.scale = Vector2(value, value)
	)

	p1_opacity_slider.value_changed.connect(func(value):
		p1_opacity_label.text = "Opacity: %d%%" % int(value * 100)
		var model = get_live2d_model_from_display(player1_character_display)
		if model:
			model.modulate.a = value
	)

	p1_visibility.toggled.connect(func(pressed):
		var model = get_live2d_model_from_display(player1_character_display)
		if model:
			model.visible = pressed
	)

	# Connect signals for Player 2
	p2_scale_slider.value_changed.connect(func(value):
		p2_scale_label.text = "Scale: %.1fx" % value
		var model = get_live2d_model_from_display(player2_character_display)
		if model:
			model.scale = Vector2(value, value)
	)

	p2_opacity_slider.value_changed.connect(func(value):
		p2_opacity_label.text = "Opacity: %d%%" % int(value * 100)
		var model = get_live2d_model_from_display(player2_character_display)
		if model:
			model.modulate.a = value
	)

	p2_visibility.toggled.connect(func(pressed):
		var model = get_live2d_model_from_display(player2_character_display)
		if model:
			model.visible = pressed
	)

	# Add panel to scene
	add_child(animation_debug_panel)

	print("Character Animation Debugger created. Press 'D' to toggle.")

func create_error_viewer():
	"""
	Creates the Animation Error Viewer panel for debugging animation errors.
	Press 'F9' to toggle the error viewer.
	"""
	# Load the error viewer script
	var ErrorViewerScript = preload("res://scripts/animation_error_viewer.gd")

	# Create error viewer panel
	error_viewer = PanelContainer.new()
	error_viewer.name = "AnimationErrorViewer"
	error_viewer.position = Vector2(100, 100)
	error_viewer.custom_minimum_size = Vector2(650, 500)
	error_viewer.visible = false  # Hidden by default
	error_viewer.z_index = 1001  # Always on top (above animation debugger)

	# Create a stylebox for the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.1, 0.1, 0.95)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1.0, 0.3, 0.3, 1.0)
	error_viewer.add_theme_stylebox_override("panel", panel_style)

	# Create main container
	var margin = MarginContainer.new()
	margin.name = "MarginContainer"
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	error_viewer.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Header
	var header = HBoxContainer.new()
	header.name = "Header"
	vbox.add_child(header)

	var title = Label.new()
	title.text = "ANIMATION ERROR DETECTOR"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1.0))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var summary_label = Label.new()
	summary_label.name = "SummaryLabel"
	summary_label.add_theme_font_size_override("font_size", 12)
	header.add_child(summary_label)

	var close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "X"
	close_button.pressed.connect(toggle_error_viewer)
	header.add_child(close_button)

	# Instructions
	var instructions = Label.new()
	instructions.text = "F9: Toggle | F10: Export | F11: Clear"
	instructions.add_theme_font_size_override("font_size", 11)
	instructions.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	vbox.add_child(instructions)

	# Error list
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.custom_minimum_size = Vector2(600, 350)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var error_list = RichTextLabel.new()
	error_list.name = "ErrorList"
	error_list.bbcode_enabled = true
	error_list.fit_content = true
	scroll.add_child(error_list)

	# Buttons
	var button_container = HBoxContainer.new()
	button_container.name = "ButtonContainer"
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(button_container)

	var refresh_button = Button.new()
	refresh_button.name = "RefreshButton"
	refresh_button.text = "Refresh (F9)"
	refresh_button.pressed.connect(refresh_error_viewer)
	button_container.add_child(refresh_button)

	var export_button = Button.new()
	export_button.name = "ExportButton"
	export_button.text = "Export (F10)"
	export_button.pressed.connect(export_errors)
	button_container.add_child(export_button)

	var clear_button = Button.new()
	clear_button.name = "ClearButton"
	clear_button.text = "Clear (F11)"
	clear_button.pressed.connect(clear_errors)
	button_container.add_child(clear_button)

	# Set script
	error_viewer.set_script(ErrorViewerScript)

	# Add to scene
	add_child(error_viewer)

	# Connect to error detector signals
	if AnimationErrorDetector:
		AnimationErrorDetector.error_logged.connect(_on_error_logged)

	print("Animation Error Viewer created. Press 'F9' to toggle.")

func toggle_error_viewer():
	"""Toggles the visibility of the animation error viewer."""
	if error_viewer:
		error_viewer_visible = !error_viewer_visible
		error_viewer.visible = error_viewer_visible
		if error_viewer_visible:
			refresh_error_viewer()
			print("Animation Error Viewer: VISIBLE")
		else:
			print("Animation Error Viewer: HIDDEN")

func refresh_error_viewer():
	"""Refreshes the error viewer display."""
	if not error_viewer or not AnimationErrorDetector:
		return

	var summary_label = error_viewer.find_child("SummaryLabel", true, false)
	var error_list = error_viewer.find_child("ErrorList", true, false)

	if not summary_label or not error_list:
		return

	# Update summary
	var error_count = AnimationErrorDetector.get_error_count()
	var has_critical = AnimationErrorDetector.has_critical_errors()

	if error_count == 0:
		summary_label.text = "✓ No errors"
		summary_label.add_theme_color_override("font_color", Color.GREEN)
	elif has_critical:
		summary_label.text = "%d errors (CRITICAL)" % error_count
		summary_label.add_theme_color_override("font_color", Color.RED)
	else:
		summary_label.text = "%d errors" % error_count
		summary_label.add_theme_color_override("font_color", Color.YELLOW)

	# Update error list
	error_list.clear()

	if error_count == 0:
		error_list.append_text("[color=green]✓ No animation errors detected[/color]\n\n")
		error_list.append_text("All character animations loaded successfully!")
		return

	# Display error summary by type
	error_list.append_text("[b][color=white]Error Summary[/color][/b]\n")
	error_list.append_text(repeat_string("=", 50) + "\n\n")

	# Count by type
	for type in AnimationErrorDetector.ErrorType.values():
		var count = AnimationErrorDetector.get_error_count_by_type(type)
		if count > 0:
			var type_name = AnimationErrorDetector.ErrorType.keys()[type]
			var icon = AnimationErrorDetector.get_error_icon(type)
			error_list.append_text("%s [color=yellow]%s[/color]: %d\n" % [icon, type_name, count])

	error_list.append_text("\n" + repeat_string("=", 50) + "\n\n")

	# Display recent errors (last 10)
	error_list.append_text("[b][color=white]Recent Errors[/color][/b]\n\n")

	var recent_errors = AnimationErrorDetector.get_recent_errors(10)
	for i in recent_errors.size():
		var error = recent_errors[i]
		var type_name = AnimationErrorDetector.ErrorType.keys()[error.error_type]
		var icon = AnimationErrorDetector.get_error_icon(error.error_type)

		error_list.append_text("[b]%s Error #%d[/b]\n" % [icon, i + 1])
		error_list.append_text("[color=gray]%s[/color]\n" % error.timestamp)
		error_list.append_text("[color=yellow]Type:[/color] %s\n" % type_name)
		error_list.append_text("[color=cyan]Message:[/color] %s\n" % error.message)

		if not error.context.is_empty():
			error_list.append_text("[color=cyan]Context:[/color]\n")
			for key in error.context:
				error_list.append_text("  • %s: %s\n" % [key, error.context[key]])

		error_list.append_text("\n" + repeat_string("-", 50) + "\n\n")

	# Show total count
	if error_count > 10:
		error_list.append_text("[color=gray][i]Showing 10 of %d total errors[/i][/color]\n" % error_count)

func export_errors():
	"""Exports all errors to files."""
	if not AnimationErrorDetector:
		return

	var text_success = AnimationErrorDetector.export_errors_to_file()
	var json_success = AnimationErrorDetector.export_errors_as_json()

	if text_success and json_success:
		print("✓ Errors exported successfully")
		print("  - Text: ", AnimationErrorDetector.error_log_path)
		print("  - JSON: user://animation_errors.json")

func clear_errors():
	"""Clears all logged errors."""
	if not AnimationErrorDetector:
		return

	AnimationErrorDetector.clear_errors()
	refresh_error_viewer()
	print("✓ All animation errors cleared")

func _on_error_logged(_error):
	"""Called when a new error is logged."""
	if error_viewer_visible:
		refresh_error_viewer()

func _unhandled_key_input(event):
	"""
	Handles keyboard shortcuts for the debug panels.
	Press 'D' to toggle the character animation debugger.
	Press 'L' to toggle the Live2D character debugger.
	Press 'F9' to toggle the animation error viewer.
	Press 'F10' to export errors to file.
	Press 'F11' to clear all errors.
	"""
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_D:
				toggle_animation_debugger()
			KEY_L:
				toggle_live2d_debugger()
			KEY_F9:
				toggle_error_viewer()
			KEY_F10:
				export_errors()
			KEY_F11:
				clear_errors()

func toggle_animation_debugger():
	"""
	Toggles the visibility of the character animation debug panel.
	"""
	if animation_debug_panel:
		animation_debug_visible = !animation_debug_visible
		animation_debug_panel.visible = animation_debug_visible
		if animation_debug_visible:
			print("Character Animation Debugger: VISIBLE")
		else:
			print("Character Animation Debugger: HIDDEN")

func create_live2d_debugger():
	"""
	Creates the Live2D character debug panel.
	"""
	live2d_debug_panel = Live2DDebugger.create_debug_panel(self)
	print("Live2D Debugger created. Press 'L' to toggle.")

func toggle_live2d_debugger():
	"""
	Toggles the visibility of the Live2D debug panel.
	"""
	if live2d_debug_panel:
		live2d_debug_visible = !live2d_debug_visible
		live2d_debug_panel.visible = live2d_debug_visible
		if live2d_debug_visible:
			print("Live2D Debugger: VISIBLE")
			# Update the panel with current character info
			update_live2d_debug_info()
		else:
			print("Live2D Debugger: HIDDEN")

func update_live2d_debug_info():
	"""
	Updates the Live2D debug panel with current character information.
	"""
	if not live2d_debug_panel:
		return

	var info_label = live2d_debug_panel.find_child("InfoLabel", true, false)
	if info_label:
		var info_text = "[b]Current Game Characters:[/b]\n\n"

		# Player 1 info
		info_text += "[color=cyan]Player 1:[/color] Character %d\n" % (GameState.player1_character + 1)
		if Live2DDebugger.is_live2d_character(GameState.player1_character):
			var char_info = Live2DDebugger.get_character_info(GameState.player1_character)
			info_text += "  Name: %s (Live2D)\n" % char_info["name"]
			info_text += "  Status: %s\n" % Live2DDebugger.get_status_message(GameState.player1_character)
		else:
			info_text += "  Type: Standard (Video/Image)\n"

		info_text += "\n"

		# Player 2 info
		info_text += "[color=cyan]Player 2:[/color] Character %d\n" % (GameState.player2_character + 1)
		if Live2DDebugger.is_live2d_character(GameState.player2_character):
			var char_info = Live2DDebugger.get_character_info(GameState.player2_character)
			info_text += "  Name: %s (Live2D)\n" % char_info["name"]
			info_text += "  Status: %s\n" % Live2DDebugger.get_status_message(GameState.player2_character)
		else:
			info_text += "  Type: Standard (Video/Image)\n"

		info_text += "\n[color=yellow]Click buttons above to debug specific Live2D characters.[/color]\n"
		info_text += "[color=yellow]Check the console output for detailed reports.[/color]"

		info_label.text = info_text

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
	Handles all input events for:
	- Drag-and-drop piece movement
	- Chessboard zooming (mouse wheel and pinch-to-zoom)
	- Chessboard panning (mouse drag and two-finger drag)
	Supports both mouse (desktop) and touch (mobile) input.

	Args:
		event: The input event to process
	"""
	# Handle touch events for pinch-to-zoom and two-finger drag
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
			# Check for two-finger gestures
			if touch_points.size() == 2:
				var points = touch_points.values()
				initial_touch_distance = points[0].distance_to(points[1])
				initial_zoom = chessboard_zoom
				is_panning = true
				pan_start_position = (points[0] + points[1]) / 2.0
		else:
			touch_points.erase(event.index)
			if touch_points.size() < 2:
				is_panning = false
				initial_touch_distance = 0.0

	# Handle touch drag for two-finger pan and pinch-to-zoom
	elif event is InputEventScreenDrag:
		touch_points[event.index] = event.position

		if touch_points.size() == 2:
			var points = touch_points.values()
			var current_distance = points[0].distance_to(points[1])
			var current_center = (points[0] + points[1]) / 2.0

			# Handle pinch-to-zoom
			if initial_touch_distance > 0:
				var zoom_factor = current_distance / initial_touch_distance
				var new_zoom = clamp(initial_zoom * zoom_factor, MIN_ZOOM, MAX_ZOOM)
				if new_zoom != chessboard_zoom:
					zoom_chessboard_to_center(new_zoom - chessboard_zoom)

			# Handle two-finger pan
			if is_panning:
				var delta = current_center - pan_start_position
				pan_chessboard(delta)
				pan_start_position = current_center

			get_viewport().set_input_as_handled()
			return

	# Handle mouse wheel for chessboard zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Zoom in
			zoom_chessboard_to_center(ZOOM_STEP)
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Zoom out
			zoom_chessboard_to_center(-ZOOM_STEP)
			get_viewport().set_input_as_handled()
			return
		# Handle middle mouse button for panning
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_position = event.position
			else:
				is_panning = false
			get_viewport().set_input_as_handled()
			return

	# Handle mouse motion for panning (when middle button is held)
	if event is InputEventMouseMotion:
		if is_panning and not is_dragging:
			var delta = event.position - pan_start_position
			pan_chessboard(delta)
			pan_start_position = event.position
			get_viewport().set_input_as_handled()
			return

	# Only process input if a piece is currently being dragged
	if is_dragging and dragging_piece:
		# Handle mouse movement or touch drag - update piece position
		if event is InputEventMouseMotion or event is InputEventScreenDrag:
			var mouse_pos = get_viewport().get_mouse_position()
			# Convert global mouse position to pieces_layer local coordinates
			var local_mouse = pieces_layer.get_global_transform().affine_inverse() * mouse_pos
			# Make piece stick to cursor with offset for natural feel
			dragging_piece.position = local_mouse - drag_offset
			# Update shadow to follow the piece
			update_drag_shadow()

		# Handle mouse button release
		elif event is InputEventMouseButton:
			if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				end_drag(event.position)

		# Handle touch release (mobile)
		elif event is InputEventScreenTouch:
			if not event.pressed and touch_points.size() <= 1:
				end_drag(event.position)

# ============================================================================
# CHESSBOARD SETUP FUNCTIONS
# ============================================================================

func zoom_chessboard_to_center(delta: float):
	"""
	Adjusts the chessboard zoom level by the specified delta, zooming to center.
	Uses smooth animation for a polished feel.

	Args:
		delta: The amount to change the zoom by (positive = zoom in, negative = zoom out)
	"""
	# Calculate new zoom level
	var new_zoom = clamp(chessboard_zoom + delta, MIN_ZOOM, MAX_ZOOM)

	# Only animate if zoom actually changed
	if new_zoom != chessboard_zoom:
		chessboard_zoom = new_zoom

		# Get the chessboard container (parent of the Chessboard)
		var container = chessboard.get_parent().get_parent()

		# Calculate the center point for zoom
		var container_rect = container.get_global_rect()

		# Animate the scale change smoothly
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(container, "scale", Vector2(chessboard_zoom, chessboard_zoom), 0.2)

		# Apply the offset to keep zoom centered
		container.pivot_offset = container_rect.size / 2.0

		print("Chessboard zoom: ", int(chessboard_zoom * 100), "%")

func pan_chessboard(delta: Vector2):
	"""
	Pans the chessboard by the specified delta.

	Args:
		delta: The amount to pan by (in pixels)
	"""
	# Get the chessboard container
	var container = chessboard.get_parent().get_parent()

	# Update the chessboard position
	chessboard_offset += delta
	container.position = chessboard_offset

func setup_chessboard():
	"""
	Creates the 8x8 chessboard grid with simple classic checkerboard pattern.
	Each square is a Panel node with custom styling.
	Uses a simpler, more reliable rendering method with unified theme.
	Supports custom board themes including background images.

	UI ADJUSTMENT GUIDE - CHESSBOARD APPEARANCE:
	- Square size: Modify custom_minimum_size below (currently 60x60)
	- Colors: Adjust light_color and dark_color below or use theme config files
	- Transparency: Change the 4th value (alpha) in the Color() definitions
	- Board position: Adjust in the scene file (main_game.tscn)
	- Board scale: Use mouse wheel zoom (scroll up/down)
	- Background images: Place board_theme.png in character's chessboard folder
	"""
	board_squares = []

	# Load theme for bottom player's (Player 1) character using BoardThemeLoader
	var theme_data = BoardThemeLoader.load_theme(GameState.player1_character)
	var light_color = theme_data.light_color
	var dark_color = theme_data.dark_color

	# If theme has a background image, create it as a lower layer
	if theme_data.has_image and theme_data.image_texture != null:
		print("Setting up chessboard with background image theme")
		var background_layer = TextureRect.new()
		background_layer.name = "BoardThemeBackground"
		background_layer.texture = theme_data.image_texture
		background_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		background_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background_layer.z_index = -10  # Behind board squares

		# Size the background to match the chessboard grid
		background_layer.custom_minimum_size = Vector2(1040, 1040)  # 130px * 8 squares
		background_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		background_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL

		# Add background as first child so it renders behind everything
		chessboard.add_child(background_layer)
		chessboard.move_child(background_layer, 0)

		print("Board theme background image loaded and positioned")

	# Determine square opacity based on whether image is present
	var square_opacity = theme_data.square_opacity
	if theme_data.has_image:
		square_opacity = theme_data.image_mode_square_opacity
		print("Using image mode with square opacity: ", square_opacity)

	# Create 8x8 grid of squares using Panel nodes (lighter than Button)
	for row in range(8):
		var row_array = []
		for col in range(8):
			# Use Panel instead of Button for simpler, more reliable rendering
			var square = Panel.new()
			square.custom_minimum_size = Vector2(130, 130)
			square.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			square.size_flags_vertical = Control.SIZE_EXPAND_FILL
			square.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow mouse events to pass through

			# Create background style with theme colors
			var style_box = StyleBoxFlat.new()
			# Alternate light and dark squares for checkerboard pattern
			var base_color: Color
			if (row + col) % 2 == 0:
				base_color = light_color
			else:
				base_color = dark_color

			# Apply opacity override if using image mode
			if theme_data.has_image:
				base_color.a = square_opacity

			style_box.bg_color = base_color

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

	# Create Node2D layer for Sprite2D chess pieces
	pieces_layer = Node2D.new()
	pieces_layer.name = "PiecesLayer"
	chessboard.add_child(pieces_layer)

	# Ensure chessboard is visible
	chessboard.visible = true
	if theme_data.has_image:
		print("Chessboard created with custom image background theme")
	else:
		print("Chessboard created with color-based theme")
	print("Pieces layer created for Sprite2D nodes")

func find_character_background(char_path: String) -> String:
	"""
	Finds a character background image with support for multiple image formats.

	Args:
		char_path: Path to the character folder

	Returns:
		Full path to the background image, or empty string if not found
	"""
	var supported_bg_extensions = [".png", ".jpg", ".jpeg", ".webp"]
	for ext in supported_bg_extensions:
		var test_path = char_path + "backgrounds/character_background" + ext
		if FileAccess.file_exists(test_path):
			return test_path
	return ""

func load_character_assets():
	"""
	Loads themed assets for both players including:
	- Character background images (displayed in player area)
	- Character animation videos (.mp4) (displayed in CharacterDisplay)
	- Live2D models (for character 4)
	- Custom chess piece sprites
	This function will attempt to load assets from the assets/ folder structure.
	If assets are not found, it will use default placeholders.
	"""
	# Character folder paths
	var char1_path = "res://assets/characters/character_" + str(GameState.player1_character + 1) + "/"
	var char2_path = "res://assets/characters/character_" + str(GameState.player2_character + 1) + "/"

	# Find Player 1 background (support multiple image formats)
	var p1_anim_path = char1_path + "animations/"
	var p1_bg_path = find_character_background(char1_path)
	load_character_media(player1_character_display, player1_area, p1_anim_path, p1_bg_path, GameState.player1_character)

	# Find Player 2 background (support multiple image formats)
	var p2_anim_path = char2_path + "animations/"
	var p2_bg_path = find_character_background(char2_path)
	load_character_media(player2_character_display, player2_area, p2_anim_path, p2_bg_path, GameState.player2_character)

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

func get_live2d_model_from_display(display_node: Control):
	"""
	Helper function to get the Live2D model from a CharacterDisplay node.

	Args:
		display_node: The CharacterDisplay Control node

	Returns:
		The Live2D model instance, or null if not found
	"""
	if display_node.get_child_count() == 0:
		return null

	var container = display_node.get_child(0)  # Live2DContainer
	if container.get_child_count() == 0:
		return null

	var viewport = container.get_child(0)  # Live2DViewport
	if viewport.get_child_count() == 0:
		return null

	return viewport.get_child(0)  # Live2DCharacter

func load_scyka_live2d(display_node: Control, character_id: int) -> bool:
	"""
	Loads Scyka Live2D character using exact functions from scyka_model_test.
	This dedicated function ensures Scyka is loaded with the same detailed
	diagnostics and configuration as the test sandbox.

	Args:
		display_node: The Control node to display the Live2D model
		character_id: The character ID (should be 4 for Scyka, but we use character_id from GameState which is 3)

	Returns:
		bool: True if Scyka Live2D model was loaded successfully, False otherwise
	"""
	const SCYKA_CHARACTER_ID = 4  # Scyka is character 4 in the system

	print("\n" + "=".repeat(70))
	print("--- Loading Scyka (Character 4) Live2D Model ---")
	print("=".repeat(70))

	# GDExtension diagnostics
	print("\n🔍 GDExtension Check:")
	if not ClassDB.class_exists("GDCubismUserModel"):
		print("   ❌ CRITICAL: GDCubismUserModel class not found!")
		print("   GDCubism plugin not loaded!")
		print("=".repeat(70))
		return false
	print("   ✓ GDCubismUserModel available")

	# Get Scyka's model path
	print("\n📂 Loading Scyka Model:")
	var model_path = Live2DDebugger.get_model_path(SCYKA_CHARACTER_ID)
	if model_path.is_empty():
		print("   ❌ ERROR: Could not find Scyka model path")
		return false

	print("   Model path: %s" % model_path)

	if not FileAccess.file_exists(model_path):
		print("   ❌ ERROR: Model file does not exist!")
		return false
	print("   ✓ Model file exists")

	# Create a wrapper container for the Live2D model
	print("\n🏗️ Creating Container Structure:")
	var model_container = SubViewportContainer.new()
	model_container.name = "Live2DContainer"
	model_container.anchor_right = 1.0
	model_container.anchor_bottom = 1.0
	model_container.stretch = true
	model_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	print("   ✓ Container created")

	# Create SubViewport for isolated rendering with 1:1 aspect ratio
	var viewport = SubViewport.new()
	viewport.name = "Live2DViewport"
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.size = Vector2(200, 200)  # Square viewport to prevent cropping
	print("   ✓ Viewport created")

	# Create Live2D model instance
	print("\n🎭 Creating Model Instance:")
	var live2d_model = ClassDB.instantiate("GDCubismUserModel")
	if not live2d_model:
		print("   ❌ ERROR: Failed to instantiate model")
		return false
	print("   ✓ Model instance created")

	# Configure model
	print("\n⚙️ Configuring Model:")
	live2d_model.assets = model_path
	live2d_model.name = "Live2DCharacter"
	print("   ✓ Assets path set")

	if "auto_scale" in live2d_model:
		live2d_model.auto_scale = 2  # AUTO_SCALE_FORCE_INSIDE
		print("   ✓ Auto-scale enabled")

	# Position model at center of square viewport
	live2d_model.position = Vector2(100, 100)
	print("   ✓ Initial position set")

	# ═══════════════════════════════════════════════════════════════════
	# 📏 LIVE2D CHARACTER BOUNDING BOX SIZE ADJUSTMENT
	# ═══════════════════════════════════════════════════════════════════
	# This controls how large the Live2D character appears on screen.
	#
	# TO ADJUST THE SIZE:
	# Change the scale factor below (currently 2.0/7.0)
	# - LARGER character: Increase the numerator (e.g., 3.0/7.0, 4.0/7.0)
	# - SMALLER character: Decrease the numerator (e.g., 1.5/7.0, 1.0/7.0)
	#
	# Examples:
	#   Vector2(1.0/7.0, 1.0/7.0)  → Original small size
	#   Vector2(2.0/7.0, 2.0/7.0)  → 2x larger (current)
	#   Vector2(3.0/7.0, 3.0/7.0)  → 3x larger
	#   Vector2(4.0/7.0, 4.0/7.0)  → 4x larger
	# ═══════════════════════════════════════════════════════════════════
	live2d_model.scale = Vector2(1.0/7.0, 1.0/7.0)
	print("   ✓ Scale set to 2/7 (2x larger)")

	# Store character ID as metadata
	live2d_model.set_meta("character_id", SCYKA_CHARACTER_ID)
	print("   ✓ Metadata stored")

	# Connect signals
	print("\n🔔 Connecting Signals:")
	if live2d_model.has_signal("motion_finished"):
		live2d_model.motion_finished.connect(_on_live2d_motion_finished.bind(live2d_model, SCYKA_CHARACTER_ID))
		print("   ✓ motion_finished signal connected")
	else:
		print("   ⚠️ motion_finished signal not available")

	# Build the hierarchy
	print("\n🏗️ Adding to Scene:")
	viewport.add_child(live2d_model)
	model_container.add_child(viewport)
	display_node.add_child(model_container)
	print("   ✓ Model added to scene tree")

	# Connect to container resize
	model_container.resized.connect(func():
		var new_size = model_container.size
		viewport.size = new_size
		live2d_model.position = new_size / 2
		print("   ✓ Live2D viewport resized to: ", new_size)
	)
	print("   ✓ Resize handler connected")

	# Load animation configuration
	print("\n🎬 Loading Scyka Animation Config:")
	var anim_config = Live2DAnimationConfig.load_animation_config(SCYKA_CHARACTER_ID)
	if not anim_config.is_empty():
		print("   Character: %s" % anim_config.get("character_name", "Unknown"))
		print("   Available animations:")
		if anim_config.has("animations"):
			for anim_name in anim_config["animations"].keys():
				var anim = anim_config["animations"][anim_name]
				var motion_file = anim.get("motion_file", "N/A")
				var loop = anim.get("loop", false)
				print("     - %s: file='%s', loop=%s" % [anim_name, motion_file, loop])

	# Start idle animation
	print("\n▶️ Starting Idle Animation:")
	if live2d_model.has_method("start_motion"):
		var default_action = Live2DAnimationConfig.get_default_animation(SCYKA_CHARACTER_ID)
		var success = Live2DAnimationConfig.play_animation(live2d_model, SCYKA_CHARACTER_ID, default_action)
		if success:
			print("   ✓ Animation started from JSON config: " + default_action)
			live2d_model.set_meta("current_animation", default_action)
		else:
			# Fallback to hardcoded idle if config fails
			live2d_model.start_motion_loop("Idle", 0, 2, true, true)
			print("   ✓ Started fallback Idle animation")
			live2d_model.set_meta("current_animation", "idle")

	print("\n✅ SUCCESS: Scyka Live2D model ready")
	print("=".repeat(70) + "\n")

	return true

func load_live2d_character(display_node: Control, character_id: int) -> bool:
	"""
	Loads a Live2D character model into the display node.

	Args:
		display_node: The Control node to display the Live2D model
		character_id: The character ID (3, 4, or 5 for Live2D characters)

	Returns:
		bool: True if the Live2D model was loaded successfully, False otherwise
	"""
	print("\n===== LOADING LIVE2D CHARACTER =====")
	print("Character ID: ", character_id)

	# Run debug check first
	var debug_report = Live2DDebugger.debug_character(character_id)
	print(debug_report._to_string())

	if not debug_report.success:
		print("✗ Live2D character failed debug check")
		return false

	# Get model path
	var model_path = Live2DDebugger.get_model_path(character_id)
	print("Model path: ", model_path)

	# Check if GDCubism is available
	if not ClassDB.class_exists("GDCubismUserModel"):
		print("✗ GDCubism plugin not available")
		return false

	# Create a wrapper container for the Live2D model to ensure proper boundaries
	var model_container = SubViewportContainer.new()
	model_container.name = "Live2DContainer"
	model_container.anchor_right = 1.0
	model_container.anchor_bottom = 1.0
	model_container.stretch = true
	model_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Create SubViewport for isolated rendering with proper boundaries
	var viewport = SubViewport.new()
	viewport.name = "Live2DViewport"
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	# Set viewport size to match container (200x200 for 1:1 square aspect ratio)
	# We'll update this dynamically when the container resizes
	viewport.size = Vector2(200, 200)  # Square viewport, will be adjusted

	# Create Live2D model instance
	var live2d_model = ClassDB.instantiate("GDCubismUserModel")
	if not live2d_model:
		print("✗ Failed to instantiate GDCubismUserModel")
		return false

	# Configure the Live2D model
	live2d_model.assets = model_path
	live2d_model.name = "Live2DCharacter"

	# Position the model in the center of the viewport
	live2d_model.position = Vector2(100, 100)  # Center position for square viewport, will be adjusted

	# ═══════════════════════════════════════════════════════════════════
	# 📏 LIVE2D CHARACTER BOUNDING BOX SIZE ADJUSTMENT
	# ═══════════════════════════════════════════════════════════════════
	# This controls how large the Live2D character appears on screen.
	#
	# TO ADJUST THE SIZE:
	# Change the scale factor below (currently 2.0/7.0)
	# - LARGER character: Increase the numerator (e.g., 3.0/7.0, 4.0/7.0)
	# - SMALLER character: Decrease the numerator (e.g., 1.5/7.0, 1.0/7.0)
	#
	# Examples:
	#   Vector2(1.0/7.0, 1.0/7.0)  → Original small size
	#   Vector2(2.0/7.0, 2.0/7.0)  → 2x larger (current)
	#   Vector2(3.0/7.0, 3.0/7.0)  → 3x larger
	#   Vector2(4.0/7.0, 4.0/7.0)  → 4x larger
	# ═══════════════════════════════════════════════════════════════════
	live2d_model.scale = Vector2(2.0/7.0, 2.0/7.0)

	# Try to set auto_scale if available (makes model fit the container)
	if "auto_scale" in live2d_model:
		live2d_model.auto_scale = 2  # AUTO_SCALE_FORCE_INSIDE
		print("✓ Auto-scale enabled for Live2D model")

	# Store character ID as metadata for later animation triggers
	live2d_model.set_meta("character_id", character_id)

	# Connect motion_finished signal for animation transitions
	print("\n🔔 Connecting Signals:")
	if live2d_model.has_signal("motion_finished"):
		live2d_model.motion_finished.connect(_on_live2d_motion_finished.bind(live2d_model, character_id))
		print("   ✓ motion_finished signal connected")
	else:
		print("   ⚠️ motion_finished signal not available")

	# Start with idle animation using JSON configuration
	if live2d_model.has_method("start_motion"):
		var default_action = Live2DAnimationConfig.get_default_animation(character_id)
		var success = Live2DAnimationConfig.play_animation(live2d_model, character_id, default_action)
		if success:
			print("✓ Started animation from JSON config: " + default_action)
			# Store current animation in metadata
			live2d_model.set_meta("current_animation", default_action)
		else:
			# Fallback to hardcoded idle if config fails
			live2d_model.start_motion_loop("Idle", 0, 2, true, true)
			print("✓ Started fallback Idle animation")
			live2d_model.set_meta("current_animation", "idle")

	# Build the hierarchy: display_node -> model_container -> viewport -> live2d_model
	viewport.add_child(live2d_model)
	model_container.add_child(viewport)
	display_node.add_child(model_container)

	# Connect to container resize to update viewport size dynamically
	model_container.resized.connect(func():
		var new_size = model_container.size
		viewport.size = new_size
		# Re-center the model when viewport resizes
		live2d_model.position = new_size / 2
		print("✓ Live2D viewport resized to: ", new_size)
	)

	print("✓ Live2D model added to scene with proper boundaries")

	return true

func load_character_media(display_node: Control, _area_node: Control, animations_dir: String, _bg_path: String, character_id: int = -1):
	"""
	Helper function to load and display character media.
	- Video/GIF animations are displayed in the CharacterDisplay node (enlarged to fill more space)
	- Live2D models are displayed for characters 4, 5, 6 (character IDs 3, 4, 5)
	- Background images are NOT loaded in Main Game (only animations are shown)
	- Supports idle, victory, defeat, and capture effect animations

	Args:
		display_node: The Control node to display video/GIF animations or Live2D models
		_area_node: The Control node to display background images (unused in Main Game)
		animations_dir: Path to the character's animations directory
		_bg_path: Path to the character background image (unused in Main Game)
		character_id: The character ID (0-5), used to determine if Live2D should be loaded
	"""
	print("\n===== LOADING CHARACTER MEDIA =====")
	print("Character ID: ", character_id)
	print("Animations dir: ", animations_dir)

	# Convert 0-indexed GameState character_id to 1-indexed actual character_id
	var actual_character_id = character_id + 1

	# CONDITIONAL IMPORT FOR SCYKA (Character 4)
	# If Scyka is selected, check if it's Live2D and use dedicated loading function
	if actual_character_id == 4:  # Scyka
		print("=== SCYKA CHARACTER DETECTED ===")
		# Check if Scyka should be loaded as Live2D
		if Live2DDebugger.is_live2d_character(actual_character_id):
			print("→ Loading Scyka as Live2D character")
			if load_scyka_live2d(display_node, character_id):
				print("✓ Scyka Live2D character loaded successfully")
				return
			else:
				print("⚠ Scyka Live2D load failed, falling back to video/image")
		else:
			print("→ Loading Scyka as default character (not Live2D)")
			# Continue to default video/image loading below
	# Check if this is another Live2D character (characters 5, 6, etc.)
	elif character_id >= 0 and Live2DDebugger.is_live2d_character(actual_character_id):
		print("Detected Live2D character (ID: %d)" % actual_character_id)
		if load_live2d_character(display_node, character_id):
			print("✓ Live2D character loaded successfully")
			return
		else:
			print("⚠ Live2D character load failed, falling back to video/image")

	# Try to load idle animation (default animation)
	# Supports both video (.ogv, .webm, .mp4) and GIF formats
	var supported_video_extensions = [".ogv", ".webm", ".mp4"]
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
				# Fixed height with unlimited width
				video_player.custom_minimum_size = Vector2(0, 200)
				video_player.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				video_player.name = "IdleAnimation"
				display_node.add_child(video_player)
				print("Loaded character animation: ", video_path)
				video_loaded = true
				break
			else:
				# File exists but failed to load
				AnimationErrorDetector.log_load_failed(
					video_path,
					"Character idle video animation"
				)

	# Try to load GIF animation
	if not video_loaded:
		var gif_path = animations_dir + "character_idle.gif"
		if FileAccess.file_exists(gif_path):
			var texture = load(gif_path)
			if texture:
				var texture_rect = TextureRect.new()
				texture_rect.texture = texture
				texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				texture_rect.anchor_right = 1.0
				texture_rect.anchor_bottom = 1.0
				# Fixed height with unlimited width
				texture_rect.custom_minimum_size = Vector2(0, 200)
				texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				texture_rect.name = "IdleAnimation"
				display_node.add_child(texture_rect)
				print("Loaded character animation GIF: ", gif_path)
				video_loaded = true
			else:
				# File exists but failed to load
				AnimationErrorDetector.log_load_failed(
					gif_path,
					"Character idle GIF animation"
				)

	if not video_loaded:
		print("No supported idle animation found (checked .webm, .ogv, .mp4, .gif)")
		AnimationErrorDetector.log_file_not_found(
			animations_dir + "character_idle.[ogv|webm|mp4|gif]",
			animations_dir
		)

	# Pre-load victory, defeat, and capture effect animations for later use
	# These will be stored as metadata on the display node for quick access
	preload_special_animations(display_node, animations_dir)

func preload_special_animations(display_node: Control, animations_dir: String):
	"""
	Pre-loads victory, defeat, and capture effect animations for quick playback.
	Stores them as metadata on the display node.

	Args:
		display_node: The Control node to store animation references
		animations_dir: Path to the character's animations directory
	"""
	var special_animations = ["character_victory", "character_defeat", "piece_capture_effect"]
	var supported_extensions = [".ogv", ".webm", ".mp4", ".gif"]

	for anim_name in special_animations:
		for ext in supported_extensions:
			var anim_path = animations_dir + anim_name + ext
			if FileAccess.file_exists(anim_path):
				# Store the path for later use
				display_node.set_meta(anim_name, anim_path)
				print("Pre-loaded special animation: ", anim_path)
				break

func play_special_animation(display_node: Control, animation_type: String, duration: float = 3.0):
	"""
	Plays a special animation on the character display.
	Temporarily replaces the idle animation with the special animation, then restores it.
	For Live2D characters, uses JSON-based animation configuration.

	Args:
		display_node: The Control node containing the character animations
		animation_type: The type of animation to play:
			- "character_victory": Win animation (maps to win_enter → win_idle)
			- "character_defeat": Lose animation (maps to lose_enter)
			- "piece_capture_effect": Piece captured animation (maps to piece_captured)
			- "hover_piece": Hovering over/picking a piece (maps to hover_piece)
			- "check": King in check animation (maps to check)
		duration: How long to play the animation before returning to idle (in seconds)
	"""
	# Check if this is a Live2D character
	var is_live2d = false
	var live2d_model = null
	var character_id = -1

	# Use helper function to get Live2D model from display node
	live2d_model = get_live2d_model_from_display(display_node)
	if live2d_model != null and live2d_model.has_method("start_motion") and live2d_model.has_meta("character_id"):
		is_live2d = true
		character_id = live2d_model.get_meta("character_id")

	# Handle Live2D animations using JSON configuration
	if is_live2d and live2d_model != null:
		# Map animation_type to action name
		var action = ""
		match animation_type:
			"character_victory":
				action = "win_enter"
			"character_defeat":
				action = "lose_enter"
			"piece_capture_effect":
				action = "piece_captured"
			"hover_piece":
				action = "hover_piece"
			"check":
				action = "check"
			_:
				print("Unknown animation type for Live2D: ", animation_type)
				return

		# Play the animation using the config
		var success = Live2DAnimationConfig.play_animation(live2d_model, character_id, action)
		if success:
			print("Playing Live2D animation: ", action)
			# Update current animation metadata
			live2d_model.set_meta("current_animation", action)
			# Note: Transition handling is now done automatically by motion_finished signal
		else:
			print("Failed to play Live2D animation: ", action)
		return

	# Check if the animation is available (for non-Live2D characters)
	if not display_node.has_meta(animation_type):
		print("Special animation not available: ", animation_type)
		AnimationErrorDetector.log_error(
			AnimationErrorDetector.ErrorType.PLAYBACK_FAILED,
			"Special animation not pre-loaded: %s" % animation_type,
			{"animation_type": animation_type}
		)
		return

	var anim_path = display_node.get_meta(animation_type)
	var is_gif = anim_path.ends_with(".gif")

	# Hide the current idle animation
	if display_node.get_child_count() > 0:
		display_node.get_child(0).visible = false

	# Create and play the special animation
	var anim_node = null
	if is_gif:
		var texture = load(anim_path)
		if texture:
			anim_node = TextureRect.new()
			anim_node.texture = texture
			anim_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			anim_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			anim_node.anchor_right = 1.0
			anim_node.anchor_bottom = 1.0
			anim_node.custom_minimum_size = Vector2(400, 400)
		else:
			# GIF file exists but failed to load
			AnimationErrorDetector.log_load_failed(
				anim_path,
				"Special animation GIF: %s" % animation_type
			)
	else:
		var video_stream = load(anim_path)
		if video_stream:
			anim_node = VideoStreamPlayer.new()
			anim_node.stream = video_stream
			anim_node.autoplay = true
			anim_node.loop = false  # Play once
			anim_node.expand = true
			anim_node.anchor_right = 1.0
			anim_node.anchor_bottom = 1.0
			anim_node.custom_minimum_size = Vector2(400, 400)
		else:
			# Video file exists but failed to load
			AnimationErrorDetector.log_load_failed(
				anim_path,
				"Special animation video: %s" % animation_type
			)

	if anim_node:
		anim_node.name = "SpecialAnimation"
		display_node.add_child(anim_node)
		print("Playing special animation: ", animation_type)

		# Create a timer to restore the idle animation
		await get_tree().create_timer(duration).timeout
		anim_node.queue_free()
		if display_node.get_child_count() > 0:
			display_node.get_child(0).visible = true

func _on_live2d_motion_finished(live2d_model: Node, character_id: int):
	"""
	Motion finished callback - handles animation transitions for Live2D characters.
	This is called when a Live2D animation completes.

	Args:
		live2d_model: The Live2D model that finished playing
		character_id: The character ID
	"""
	if not is_instance_valid(live2d_model):
		return

	var current_animation = live2d_model.get_meta("current_animation", "idle")

	print("\n" + "=".repeat(60))
	print("🔔 Live2D Motion Finished Callback")
	print("=".repeat(60))
	print("   Current animation: %s" % current_animation)
	print("   Character ID: %d" % character_id)

	# Check if there's a transition defined for the current animation
	var transition = Live2DAnimationConfig.get_animation_transition(character_id, current_animation)
	print("   Transition config: %s" % transition)

	if not transition.is_empty() and transition.has("next_animation"):
		var next_anim = transition["next_animation"]
		var delay = transition.get("delay", 0.5)

		print("\n▶️ Animation Transition:")
		print("   From: %s" % current_animation)
		print("   To: %s" % next_anim)
		print("   Delay: %.2fs" % delay)

		if delay > 0.0:
			print("   ⏳ Waiting %.2fs before transition..." % delay)
			await get_tree().create_timer(delay).timeout
			print("   ✓ Delay complete")

		# Play the next animation
		if live2d_model and is_instance_valid(live2d_model) and live2d_model.has_method("start_motion"):
			print("   🎬 Starting next animation: %s" % next_anim)
			var success = Live2DAnimationConfig.play_animation(live2d_model, character_id, next_anim)
			if success:
				print("   ✓ Transition successful")
				# Update current animation metadata
				live2d_model.set_meta("current_animation", next_anim)
			else:
				print("   ❌ Transition failed")
		else:
			print("   ❌ ERROR: Model not available or missing start_motion method")
	else:
		print("   ℹ️ No transition defined for '%s'" % current_animation)

	print("=".repeat(60) + "\n")

	# ============================================================================
	# CHARACTER BACKGROUND REMOVED IN MAIN GAME
	# ============================================================================
	# The character background is no longer displayed in the Main Game to allow
	# the character animation to be more prominent. To re-enable backgrounds,
	# uncomment the code below:
	#
	# if bg_path != "" and FileAccess.file_exists(bg_path):
	#     var texture = load(bg_path)
	#     if texture:
	#         var texture_rect = TextureRect.new()
	#         texture_rect.texture = texture
	#         texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	#         texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	#         texture_rect.anchor_right = 1.0
	#         texture_rect.anchor_bottom = 1.0
	#         texture_rect.z_index = -1
	#         area_node.add_child(texture_rect)
	#         area_node.move_child(texture_rect, 0)
	#         print("Loaded background image: ", bg_path)
	# elif bg_path != "":
	#     print("Warning: Character background not found: ", bg_path)
	# ============================================================================

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
	var character_names = ["Character 1", "Character 2", "Character 3", "Character 4 (Scyka)"]

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
	Uses the ChessPieceSprite system with Sprite2D nodes.
	IF-ELSE LOGIC: Automatically checks if piece is PNG or scene folder.

	Args:
		piece: The ChessPiece object containing piece data
		pos: Board position (row, col) where the piece should be displayed
	"""
	# Determine which character's assets to use based on piece color
	var character_id = GameState.player1_character if piece.piece_color == ChessPiece.PieceColor.WHITE else GameState.player2_character

	# Get piece type name
	var piece_type_name = ChessPiece.PieceType.keys()[piece.piece_type].to_lower()

	# Use ChessPieceSprite system to create the piece
	# This handles the IF-ELSE logic:
	# - IF scene folder exists: Load the scene
	# - ELSE: Load the PNG and put it in a Sprite2D node
	var piece_sprite = ChessPieceSprite.create_piece_sprite(piece_type_name, character_id + 1, false)

	if piece_sprite:
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
				piece_sprite.modulate = tint_colors[piece_style]
			else:
				piece_sprite.modulate = Color(0.3, 0.3, 0.3)  # Default dark gray

		# Store piece metadata for effects system
		piece_sprite.set_meta("piece_type", piece_type_name)
		piece_sprite.set_meta("piece_color", "white" if piece.piece_color == ChessPiece.PieceColor.WHITE else "black")
		piece_sprite.set_meta("character_id", character_id + 1)
		piece_sprite.set_meta("board_position", pos)

		# Position the piece at the center of the board square
		var square = board_squares[pos.x][pos.y]
		# Convert square's global position to pieces_layer's local coordinate space
		var square_global_center = square.global_position + square.size / 2.0
		var piece_local_position = pieces_layer.to_local(square_global_center)
		piece_sprite.position = piece_local_position

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

		# Add piece to the pieces layer and track it
		pieces_layer.add_child(piece_sprite)
		visual_pieces.append(piece_sprite)
		return

	# Fallback to Unicode symbols if sprite creation failed
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
		tween.set_loops(0)  # 0 = infinite loops
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
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
			visual_piece.custom_minimum_size = Vector2(60, 60)  # Captured pieces size
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

func create_drag_shadow(piece_node: CanvasItem):
	"""
	Creates a shadow/glow effect behind the dragged piece for visual feedback.
	The shadow follows the piece during dragging.
	Works with both Node2D (Sprite2D) and Control (Label) pieces.

	Args:
		piece_node: The piece node being dragged (Node2D or Control)
	"""
	# Remove any existing shadow
	if drag_shadow:
		drag_shadow.queue_free()
		drag_shadow = null

	# Calculate the size of the piece node
	var piece_size = Vector2(100, 100)  # Default size

	if piece_node is Control:
		# For Control nodes (Label fallback), use the size property
		piece_size = piece_node.size
	else:
		# For Node2D nodes (Sprite2D), estimate size from children
		# Look for a Sprite2D child with a texture
		for child in piece_node.get_children():
			if child is Sprite2D and child.texture:
				var texture_size = child.texture.get_size()
				piece_size = texture_size * child.scale
				break
			elif child is Control:
				# Scene-based piece might have Control nodes
				piece_size = child.size
				break

	# Create a ColorRect as shadow
	drag_shadow = ColorRect.new()
	drag_shadow.color = Color(0, 0, 0, 0.3)  # Semi-transparent black shadow
	drag_shadow.z_index = 99  # Just behind the dragged piece

	# Match the piece's size and position
	drag_shadow.custom_minimum_size = piece_size
	drag_shadow.size = piece_size
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

	# Find the piece at this board position in the pieces_layer
	var piece_node = null
	for child in pieces_layer.get_children():
		if child.has_meta("board_position"):
			var board_pos = child.get_meta("board_position")
			if board_pos == pos:
				piece_node = child
				break

	if piece_node:
		# Store reference to the piece and its original position
		dragging_piece = piece_node
		original_parent = pieces_layer
		original_scale = piece_node.scale

		# Get current mouse/touch position
		var mouse_pos = get_viewport().get_mouse_position()

		# Convert global mouse position to pieces_layer local coordinates
		var local_mouse = pieces_layer.get_global_transform().affine_inverse() * mouse_pos

		# Calculate offset from mouse to piece position to prevent shifting
		# This ensures the piece stays in the exact same position relative to the cursor
		drag_offset = local_mouse - piece_node.position

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

		# 4. Apply piece effects system (image swap, glow, particles, etc.)
		if piece_effects:
			var piece_data = {
				"type": piece_node.get_meta("piece_type", ""),
				"color": piece_node.get_meta("piece_color", ""),
				"character_id": piece_node.get_meta("character_id", 1),
				"position": pos
			}
			# Get square size for proper scaling of held piece
			var square = board_squares[pos.x][pos.y]
			var square_size = square.size.x
			piece_effects.apply_drag_effects(piece_node, piece_data, square_size, held_piece_scale_multiplier)

		# Update drag state
		is_dragging = true

		# Play hover_piece animation for the player who is dragging
		var piece = chess_board.get_piece_at(pos)
		if piece:
			var display_node = player1_character_display if piece.piece_color == ChessPiece.PieceColor.WHITE else player2_character_display
			play_special_animation(display_node, "hover_piece", 1.0)

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

	# Remove piece effects (image swap, glow, particles, etc.)
	if piece_effects and dragging_piece:
		piece_effects.remove_drag_effects(dragging_piece)

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

	# Remove piece effects (image swap, glow, particles, etc.)
	if piece_effects and dragging_piece:
		piece_effects.remove_drag_effects(dragging_piece)

	if dragging_piece:
		# Get the original board position from metadata
		var board_pos = dragging_piece.get_meta("board_position", Vector2i(-1, -1))
		if board_pos != Vector2i(-1, -1):
			# Calculate the target position (center of original square)
			var square = board_squares[board_pos.x][board_pos.y]
			var target_position = square.position + square.size / 2.0

			# Create animation tween for smooth return
			var tween = create_tween()
			tween.set_parallel(true)  # Run all animations simultaneously
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_BACK)  # "Bounce back" effect

			# Animate position back to original square
			tween.tween_property(dragging_piece, "position", target_position, 0.3)

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
			# No valid board position, just reset immediately
			dragging_piece.modulate = Color(1, 1, 1, 1)
			dragging_piece.z_index = 0
			dragging_piece = null
			is_dragging = false
			original_parent = null
			clear_highlights()
			selected_square = Vector2i(-1, -1)
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
	Updates the captured pieces display and plays capture effect animation.
	Connected to the chess_board.piece_captured signal.

	Args:
		piece: The piece that was captured
		captured_by: The piece that captured it
	"""
	print(captured_by.get_piece_name(), " captured ", piece.get_piece_name())
	update_captured_display()

	# Play piece_captured animation for the player whose piece was captured (victim)
	var display_node = player1_character_display if piece.piece_color == ChessPiece.PieceColor.WHITE else player2_character_display
	play_special_animation(display_node, "piece_capture_effect", 2.0)

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

func _on_check_detected(color: ChessPiece.PieceColor):
	"""
	Called when a king is in check.
	Plays the shock animation for the player whose king is in check.
	Connected to the chess_board.check_detected signal.

	Args:
		color: The color of the king that is in check
	"""
	print("Check detected! ", "White" if color == ChessPiece.PieceColor.WHITE else "Black", "'s king is in check")

	# Play check animation for the player whose king is in check
	var display_node = player1_character_display if color == ChessPiece.PieceColor.WHITE else player2_character_display
	play_special_animation(display_node, "check", 2.0)

func _on_game_over(result: String):
	"""
	Called when the game ends (checkmate, stalemate, etc.).
	Shows the game summary dialog and plays victory/defeat animations.
	Connected to the chess_board.game_over signal.

	Args:
		result: The game result string (e.g., "checkmate_white", "stalemate")
	"""
	print("Game Over! Result: ", result)
	game_ended = true

	# Play victory/defeat animations based on the result
	if result == "checkmate_white":
		# White (Player 1) wins
		play_special_animation(player1_character_display, "character_victory", 4.0)
		play_special_animation(player2_character_display, "character_defeat", 4.0)
	elif result == "checkmate_black":
		# Black (Player 2) wins
		play_special_animation(player2_character_display, "character_victory", 4.0)
		play_special_animation(player1_character_display, "character_defeat", 4.0)
	# For stalemate/draw, no special animations

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

	# Initialize chessboard scale to full size
	chessboard_container.scale = Vector2(1.0, 1.0)

	print("Score panel initialized as hidden")

func setup_responsive_layout():
	"""
	Sets up responsive layout for GameArea and PlayerAreas.
	GameArea size is based on the chessboard size (not flex).
	TopPlayerArea and BottomPlayerArea expand to fill remaining space.
	"""
	# Connect to resize signals for responsive behavior
	chessboard_container.resized.connect(_update_responsive_layout)
	main_container.resized.connect(_update_responsive_layout)

	# Set initial layout
	_update_responsive_layout()

	print("Responsive layout initialized ✓")

func _update_responsive_layout():
	"""
	Updates the layout responsively based on chessboard and available space.
	Called when the chessboard or container resizes.
	"""
	# Wait for next frame to ensure all sizes are updated
	await get_tree().process_frame

	# Get the chessboard's actual size
	var chessboard_size = chessboard_container.size

	# Set GameArea's custom minimum size based on chessboard
	# This makes GameArea responsive to chessboard size instead of using flex
	game_area.custom_minimum_size = Vector2(0, chessboard_size.y)

	# The TopPlayerArea and BottomPlayerArea will automatically expand
	# to fill the remaining vertical space due to size_flags_vertical = 3

func _on_score_toggle_pressed():
	"""
	Handles clicks on the score panel toggle button.
	Toggles the score panel visibility state.
	"""
	score_panel_visible = !score_panel_visible
	toggle_score_panel()

func toggle_score_panel():
	"""
	Animates the score panel sliding in/out with smooth chessboard zoom effect.
	When the score panel opens, the chessboard zooms out to accommodate it.
	When the score panel closes, the chessboard zooms back to full size.
	"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(true)  # Run animations in parallel

	if score_panel_visible:
		# Show panel - fade in and zoom out chessboard
		score_panel.visible = true
		score_panel.modulate.a = 0.0
		tween.tween_property(score_panel, "modulate:a", 1.0, 0.4)
		# Zoom out chessboard by scaling down
		tween.tween_property(chessboard_container, "scale", Vector2(0.85, 0.85), 0.4)
	else:
		# Hide panel - fade out and zoom in chessboard
		tween.tween_property(score_panel, "modulate:a", 0.0, 0.4)
		# Zoom in chessboard back to full size
		tween.tween_property(chessboard_container, "scale", Vector2(1.0, 1.0), 0.4)
		tween.chain().tween_callback(func(): score_panel.visible = false)

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
		var move_num = int(i / 2.0) + 1  # Calculate move number (integer division)
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
