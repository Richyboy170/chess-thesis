extends Control

@onready var chessboard = $MainContainer/GameArea/ChessboardContainer/MarginContainer/VBoxContainer/AspectRatioContainer/Chessboard
@onready var player1_character_label = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/CharacterName
@onready var player2_character_label = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/CharacterName
@onready var player1_score_label = $MainContainer/GameArea/ScorePanel/MarginContainer/VBoxContainer/Player1Score/ScoreValue
@onready var player2_score_label = $MainContainer/GameArea/ScorePanel/MarginContainer/VBoxContainer/Player2Score/ScoreValue
@onready var moves_label = $MainContainer/GameArea/ScorePanel/MarginContainer/VBoxContainer/GameStats/MovesLabel
@onready var captured_label = $MainContainer/GameArea/ScorePanel/MarginContainer/VBoxContainer/GameStats/CapturedLabel
@onready var turn_indicator = $MainContainer/GameArea/ScorePanel/MarginContainer/VBoxContainer/TurnIndicator
@onready var player1_captured_container = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/CapturedPieces
@onready var player2_captured_container = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/CapturedPieces
@onready var score_panel = $MainContainer/GameArea/ScorePanel
@onready var score_toggle_button = $MainContainer/GameArea/ScoreToggleButton
@onready var player1_timer_label = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/TimerLabel
@onready var player2_timer_label = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/TimerLabel

var chess_board: ChessBoard
var visual_pieces: Array = []
var board_squares: Array = []
var selected_square: Vector2i = Vector2i(-1, -1)
var score_panel_visible: bool = true
var game_ended: bool = false

# Drag and drop variables
var dragging_piece: Label = null
var drag_offset: Vector2 = Vector2.ZERO
var original_parent: Control = null
var is_dragging: bool = false

func _ready():
	chess_board = ChessBoard.new()
	add_child(chess_board)

	# Connect signals
	chess_board.piece_moved.connect(_on_piece_moved)
	chess_board.piece_captured.connect(_on_piece_captured)
	chess_board.turn_changed.connect(_on_turn_changed)
	chess_board.game_over.connect(_on_game_over)

	setup_chessboard()
	update_character_displays()
	update_board_display()
	update_score_display()
	setup_score_toggle()
	initialize_timers()
	update_timer_display()

func _process(delta):
	# Update timers if game is active
	if not game_ended and GameState.player_time_limit > 0:
		# Decrement current player's time
		if chess_board.is_white_turn:
			GameState.player1_time_remaining -= delta
			if GameState.player1_time_remaining <= 0:
				GameState.player1_time_remaining = 0
				handle_time_expired(true)  # Player 1 (White) ran out of time
		else:
			GameState.player2_time_remaining -= delta
			if GameState.player2_time_remaining <= 0:
				GameState.player2_time_remaining = 0
				handle_time_expired(false)  # Player 2 (Black) ran out of time

		update_timer_display()

func _input(event):
	if is_dragging and dragging_piece:
		if event is InputEventMouseMotion or event is InputEventScreenDrag:
			# Update dragging piece position to follow cursor/finger
			var mouse_pos = get_viewport().get_mouse_position()
			dragging_piece.global_position = mouse_pos - drag_offset
		elif event is InputEventMouseButton:
			if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				# Mouse released - try to drop piece
				end_drag(event.position)
		elif event is InputEventScreenTouch:
			if not event.pressed:
				# Touch released - try to drop piece
				end_drag(event.position)

func setup_chessboard():
	# Create 8x8 grid of chess squares
	board_squares = []
	for row in range(8):
		var row_array = []
		for col in range(8):
			var square = Button.new()
			square.custom_minimum_size = Vector2(80, 80)  # Increased from 50 to 80
			square.flat = true

			# Create background style
			var style_box = StyleBoxFlat.new()
			# Alternate colors for chessboard pattern
			if (row + col) % 2 == 0:
				style_box.bg_color = Color(0.9, 0.9, 0.8, 1)  # Light square
			else:
				style_box.bg_color = Color(0.5, 0.4, 0.3, 1)  # Dark square

			square.add_theme_stylebox_override("normal", style_box)
			square.add_theme_stylebox_override("hover", style_box)
			square.add_theme_stylebox_override("pressed", style_box)

			# Store position in metadata
			square.set_meta("board_pos", Vector2i(row, col))
			square.pressed.connect(_on_square_clicked.bind(Vector2i(row, col)))

			chessboard.add_child(square)
			row_array.append(square)
		board_squares.append(row_array)

func update_character_displays():
	# Update character names based on selection
	var character_names = ["Character 1", "Character 2", "Character 3"]

	if GameState.player1_character >= 0 and GameState.player1_character < character_names.size():
		player1_character_label.text = "Character: " + character_names[GameState.player1_character]

	if GameState.player2_character >= 0 and GameState.player2_character < character_names.size():
		player2_character_label.text = "Character: " + character_names[GameState.player2_character]

func update_board_display():
	# Clear existing visual pieces
	for piece in visual_pieces:
		piece.queue_free()
	visual_pieces.clear()

	# Clear all squares
	for row in range(8):
		for col in range(8):
			var square = board_squares[row][col]
			# Remove any existing children (pieces)
			for child in square.get_children():
				child.queue_free()

	# Create visual pieces for current board state
	for row in range(8):
		for col in range(8):
			var piece = chess_board.get_piece_at(Vector2i(row, col))
			if piece != null:
				create_visual_piece(piece, Vector2i(row, col))

func create_visual_piece(piece: ChessPiece, pos: Vector2i):
	var visual_piece = Label.new()
	visual_piece.text = piece.get_piece_symbol()
	visual_piece.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	visual_piece.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	visual_piece.add_theme_font_size_override("font_size", 56)  # Increased from 36 to 56
	visual_piece.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow mouse events

	# Center the piece in its square using anchors
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

	# Style based on character theme
	var style_colors = {
		"classic": {"white": Color(1, 1, 1), "black": Color(0.2, 0.2, 0.2)},
		"modern": {"white": Color(0.8, 0.9, 1), "black": Color(0.1, 0.2, 0.4)},
		"fantasy": {"white": Color(1, 0.9, 0.7), "black": Color(0.4, 0.1, 0.3)}
	}

	var style = piece.character_style
	if not style in style_colors:
		style = "classic"

	var color_key = "white" if piece.piece_color == ChessPiece.PieceColor.WHITE else "black"
	visual_piece.add_theme_color_override("font_color", style_colors[style][color_key])

	board_squares[pos.x][pos.y].add_child(visual_piece)
	visual_pieces.append(visual_piece)

func _on_square_clicked(pos: Vector2i):
	if is_dragging:
		return  # Don't process clicks while dragging

	# If a piece is selected, try to move it
	if selected_square != Vector2i(-1, -1):
		if chess_board.try_move_piece(selected_square, pos):
			clear_highlights()
			selected_square = Vector2i(-1, -1)
			update_board_display()
			update_score_display()
		else:
			# Try selecting a new piece
			attempt_select_piece(pos)
	else:
		# Try to select a piece and start dragging
		attempt_select_piece(pos)

func attempt_select_piece(pos: Vector2i):
	clear_highlights()
	if chess_board.select_piece(pos):
		selected_square = pos
		highlight_valid_moves()
		start_drag(pos)

func highlight_valid_moves():
	# Highlight selected square
	var selected = board_squares[selected_square.x][selected_square.y]
	var highlight_style = StyleBoxFlat.new()
	highlight_style.bg_color = Color(1, 1, 0, 0.5)
	selected.add_theme_stylebox_override("normal", highlight_style)

	# Highlight valid moves
	for move in chess_board.valid_moves:
		var square = board_squares[move.x][move.y]
		var move_style = StyleBoxFlat.new()

		# Different color for captures
		if chess_board.get_piece_at(move) != null:
			move_style.bg_color = Color(1, 0.3, 0.3, 0.5)  # Red for capture
		else:
			move_style.bg_color = Color(0.3, 1, 0.3, 0.5)  # Green for move

		square.add_theme_stylebox_override("normal", move_style)

func clear_highlights():
	for row in range(8):
		for col in range(8):
			var square = board_squares[row][col]
			var style_box = StyleBoxFlat.new()

			if (row + col) % 2 == 0:
				style_box.bg_color = Color(0.9, 0.9, 0.8, 1)
			else:
				style_box.bg_color = Color(0.5, 0.4, 0.3, 1)

			square.add_theme_stylebox_override("normal", style_box)

func update_score_display():
	player1_score_label.text = str(GameState.player1_score)
	player2_score_label.text = str(GameState.player2_score)
	moves_label.text = "Moves: " + str(GameState.move_count)
	captured_label.text = "Captured Pieces: " + str(GameState.captured_pieces)

func update_captured_display():
	# Clear existing captured pieces display
	for child in player1_captured_container.get_children():
		child.queue_free()
	for child in player2_captured_container.get_children():
		child.queue_free()

	# Display pieces captured by Player 1 (White)
	for piece in chess_board.get_captured_by_white():
		var label = Label.new()
		label.text = piece.get_piece_symbol()
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		player1_captured_container.add_child(label)

	# Display pieces captured by Player 2 (Black)
	for piece in chess_board.get_captured_by_black():
		var label = Label.new()
		label.text = piece.get_piece_symbol()
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		player2_captured_container.add_child(label)

func start_drag(pos: Vector2i):
	# Get the piece label from the square
	var square = board_squares[pos.x][pos.y]
	if square.get_child_count() > 0:
		var piece_label = square.get_child(0)
		if piece_label is Label:
			# Store original parent
			original_parent = square

			# Get mouse position
			var mouse_pos = get_viewport().get_mouse_position()

			# Calculate offset to center piece on cursor
			# Use the square size since the label fills the square
			drag_offset = square.size / 2

			# Reparent to root to move freely
			piece_label.reparent(self)
			piece_label.z_index = 100  # Draw on top

			# Reset anchors and set size to match square
			piece_label.anchor_left = 0
			piece_label.anchor_top = 0
			piece_label.anchor_right = 0
			piece_label.anchor_bottom = 0
			piece_label.size = square.size

			# Set position to follow cursor with piece centered
			piece_label.global_position = mouse_pos - drag_offset

			dragging_piece = piece_label
			is_dragging = true

func end_drag(drop_position: Vector2):
	if not is_dragging or dragging_piece == null:
		return

	# Find which square we dropped on
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

	# Try to move the piece
	if dropped_on_square != Vector2i(-1, -1) and selected_square != Vector2i(-1, -1):
		if chess_board.try_move_piece(selected_square, dropped_on_square):
			# Move successful
			clear_highlights()
			selected_square = Vector2i(-1, -1)
			# Clean up drag state
			if dragging_piece:
				dragging_piece.queue_free()
			dragging_piece = null
			is_dragging = false
			original_parent = null
			update_board_display()
			update_score_display()
		else:
			# Move failed - show red flash on target square and return piece
			if dropped_on_square != Vector2i(-1, -1):
				flash_square_red(dropped_on_square)
			return_piece_to_original_position()
	else:
		# Dropped outside board or invalid
		return_piece_to_original_position()

func return_piece_to_original_position():
	if dragging_piece and original_parent:
		dragging_piece.reparent(original_parent)
		dragging_piece.z_index = 0

	# Clean up drag state
	dragging_piece = null
	is_dragging = false
	original_parent = null
	clear_highlights()
	selected_square = Vector2i(-1, -1)
	update_board_display()

func flash_square_red(pos: Vector2i):
	if pos.x < 0 or pos.x >= 8 or pos.y < 0 or pos.y >= 8:
		return

	var square = board_squares[pos.x][pos.y]
	var original_color: Color

	# Get original square color
	if (pos.x + pos.y) % 2 == 0:
		original_color = Color(0.9, 0.9, 0.8, 1)  # Light square
	else:
		original_color = Color(0.5, 0.4, 0.3, 1)  # Dark square

	# Create red flash style
	var red_style = StyleBoxFlat.new()
	red_style.bg_color = Color(1, 0, 0, 0.7)  # Bright red
	square.add_theme_stylebox_override("normal", red_style)

	# Create tween for smooth color transition back
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Animate back to original color over 1 second
	tween.tween_method(func(value: float):
		var current_style = StyleBoxFlat.new()
		current_style.bg_color = Color(1, 0, 0, 0.7).lerp(original_color, value)
		square.add_theme_stylebox_override("normal", current_style)
	, 0.0, 1.0, 1.0)

	# Restore original color at the end
	tween.tween_callback(func():
		var final_style = StyleBoxFlat.new()
		final_style.bg_color = original_color
		square.add_theme_stylebox_override("normal", final_style)
	)

func _on_piece_moved(from_pos: Vector2i, to_pos: Vector2i, piece: ChessPiece):
	print("Piece moved from ", from_pos, " to ", to_pos)

func _on_piece_captured(piece: ChessPiece, captured_by: ChessPiece):
	print(captured_by.get_piece_name(), " captured ", piece.get_piece_name())
	update_captured_display()

func _on_turn_changed(is_white_turn: bool):
	var turn_text = "White's Turn" if is_white_turn else "Black's Turn"
	turn_indicator.text = turn_text
	print(turn_text)

func _on_game_over(result: String):
	print("Game Over! Result: ", result)
	game_ended = true
	# Show game summary dialog
	show_game_summary(result)

func initialize_timers():
	# Initialize timer values from GameState
	if GameState.player_time_limit > 0:
		GameState.player1_time_remaining = float(GameState.player_time_limit)
		GameState.player2_time_remaining = float(GameState.player_time_limit)
	else:
		GameState.player1_time_remaining = 0.0
		GameState.player2_time_remaining = 0.0
		# Hide timer labels if no timer is set
		player1_timer_label.visible = false
		player2_timer_label.visible = false

func update_timer_display():
	if GameState.player_time_limit == 0:
		return

	# Format and display Player 1 time
	var p1_minutes = int(GameState.player1_time_remaining) / 60
	var p1_seconds = int(GameState.player1_time_remaining) % 60
	player1_timer_label.text = "Time: %02d:%02d" % [p1_minutes, p1_seconds]

	# Format and display Player 2 time
	var p2_minutes = int(GameState.player2_time_remaining) / 60
	var p2_seconds = int(GameState.player2_time_remaining) % 60
	player2_timer_label.text = "Time: %02d:%02d" % [p2_minutes, p2_seconds]

	# Color coding: red if less than 30 seconds, yellow if less than 60 seconds
	if GameState.player1_time_remaining <= 30:
		player1_timer_label.add_theme_color_override("font_color", Color(1, 0, 0, 1))  # Red
	elif GameState.player1_time_remaining <= 60:
		player1_timer_label.add_theme_color_override("font_color", Color(1, 1, 0, 1))  # Yellow
	else:
		player1_timer_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))  # Green

	if GameState.player2_time_remaining <= 30:
		player2_timer_label.add_theme_color_override("font_color", Color(1, 0, 0, 1))  # Red
	elif GameState.player2_time_remaining <= 60:
		player2_timer_label.add_theme_color_override("font_color", Color(1, 1, 0, 1))  # Yellow
	else:
		player2_timer_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))  # Green

func handle_time_expired(is_white: bool):
	if game_ended:
		return

	game_ended = true
	var result = "timeout_black_wins" if is_white else "timeout_white_wins"
	GameState.game_result = result

	# Show game over
	var result_text = "Time's Up! Black Wins!" if is_white else "Time's Up! White Wins!"
	show_game_summary(result)

func setup_score_toggle():
	# Connect the toggle button signal
	score_toggle_button.pressed.connect(_on_score_toggle_pressed)
	# Set initial text - panel is visible by default, so show collapse arrow
	score_toggle_button.text = "<"

func _on_score_toggle_pressed():
	score_panel_visible = !score_panel_visible
	toggle_score_panel()

func toggle_score_panel():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	if score_panel_visible:
		# Show panel - slide in from right
		score_panel.visible = true
		score_panel.modulate.a = 0.0
		score_panel.position.x = score_panel.size.x
		tween.tween_property(score_panel, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(score_panel, "position:x", 0, 0.3)
	else:
		# Hide panel - slide out to right
		tween.tween_property(score_panel, "modulate:a", 0.0, 0.3)
		tween.parallel().tween_property(score_panel, "position:x", score_panel.size.x, 0.3)
		tween.tween_callback(func(): score_panel.visible = false)

	update_score_toggle_text()

func update_score_toggle_text():
	if score_panel_visible:
		score_toggle_button.text = "<"
	else:
		score_toggle_button.text = ">"

func _on_menu_button_pressed():
	# Return to character selection or main menu
	get_tree().change_scene_to_file("res://scenes/ui/login_page.tscn")

func show_game_summary(result: String):
	# Create a popup dialog for game summary
	var dialog = AcceptDialog.new()
	dialog.title = "Game Over!"
	dialog.dialog_autowrap = true
	dialog.size = Vector2(600, 800)

	# Determine winner text
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
		_:
			result_text = "Game Over!"

	# Create content
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 15)

	# Result label
	var result_label = Label.new()
	result_label.text = result_text
	result_label.add_theme_font_size_override("font_size", 28)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(result_label)

	# Separator
	var sep1 = HSeparator.new()
	content.add_child(sep1)

	# Stats section
	var stats_label = Label.new()
	stats_label.text = "Game Statistics"
	stats_label.add_theme_font_size_override("font_size", 22)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(stats_label)

	var stats_text = Label.new()
	stats_text.text = "Total Moves: " + str(GameState.move_count) + "\n"
	stats_text.text += "Player 1 Score: " + str(GameState.player1_score) + "\n"
	stats_text.text += "Player 2 Score: " + str(GameState.player2_score) + "\n"
	stats_text.text += "Total Captures: " + str(GameState.captured_pieces)
	stats_text.add_theme_font_size_override("font_size", 18)
	stats_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(stats_text)

	# Separator
	var sep2 = HSeparator.new()
	content.add_child(sep2)

	# Move history section
	var history_label = Label.new()
	history_label.text = "Move History"
	history_label.add_theme_font_size_override("font_size", 22)
	history_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(history_label)

	# Create scrollable container for moves
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(550, 300)

	var moves_label = Label.new()
	var moves_text = ""
	for i in range(GameState.move_history.size()):
		var move_num = (i / 2) + 1
		if i % 2 == 0:
			moves_text += str(move_num) + ". " + GameState.move_history[i]
			if i + 1 < GameState.move_history.size():
				moves_text += "  " + GameState.move_history[i + 1] + "\n"
			else:
				moves_text += "\n"

	moves_label.text = moves_text
	moves_label.add_theme_font_size_override("font_size", 16)
	moves_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	scroll.add_child(moves_label)
	content.add_child(scroll)

	dialog.add_child(content)
	add_child(dialog)
	dialog.popup_centered()

	# When dialog is closed, return to menu
	dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/login_page.tscn"))
