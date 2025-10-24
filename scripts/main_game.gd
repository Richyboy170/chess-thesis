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

var chess_board: ChessBoard
var visual_pieces: Array = []
var board_squares: Array = []
var selected_square: Vector2i = Vector2i(-1, -1)

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

func setup_chessboard():
	# Create 8x8 grid of chess squares
	board_squares = []
	for row in range(8):
		var row_array = []
		for col in range(8):
			var square = Button.new()
			square.custom_minimum_size = Vector2(50, 50)
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
	visual_piece.add_theme_font_size_override("font_size", 36)

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
		# Try to select a piece
		attempt_select_piece(pos)

func attempt_select_piece(pos: Vector2i):
	clear_highlights()
	if chess_board.select_piece(pos):
		selected_square = pos
		highlight_valid_moves()

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

func _on_piece_moved(from_pos: Vector2i, to_pos: Vector2i):
	print("Piece moved from ", from_pos, " to ", to_pos)

func _on_piece_captured(piece: ChessPiece, captured_by: ChessPiece):
	print(captured_by.get_piece_name(), " captured ", piece.get_piece_name())
	update_captured_display()

func _on_turn_changed(is_white_turn: bool):
	var turn_text = "White's Turn" if is_white_turn else "Black's Turn"
	turn_indicator.text = turn_text
	print(turn_text)

func _on_game_over(winner: ChessPiece.PieceColor):
	var winner_text = "White" if winner == ChessPiece.PieceColor.WHITE else "Black"
	print("Game Over! ", winner_text, " wins!")
	# Show game over dialog or return to menu

func _on_menu_button_pressed():
	# Return to character selection or main menu
	get_tree().change_scene_to_file("res://scenes/ui/login_page.tscn")
