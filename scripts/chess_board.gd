extends Node
class_name ChessBoard

signal piece_moved(from_pos: Vector2i, to_pos: Vector2i, piece: ChessPiece)
signal piece_captured(piece: ChessPiece, captured_by: ChessPiece)
signal turn_changed(is_white_turn: bool)
signal game_over(result: String)  # "checkmate_white", "checkmate_black", "stalemate", "draw"
signal check_detected(color: ChessPiece.PieceColor)

var board_state: Array = []
var is_white_turn: bool = true
var selected_piece: ChessPiece = null
var valid_moves: Array = []
var captured_pieces_white: Array = []  # Pieces captured by white
var captured_pieces_black: Array = []  # Pieces captured by black

func _init():
	initialize_board()

func initialize_board():
	# Create 8x8 board
	board_state = []
	for i in range(8):
		var row = []
		for j in range(8):
			row.append(null)
		board_state.append(row)

	# Set up pieces
	setup_pieces()

func setup_pieces():
	var white_style = GameState.get_character_piece_style(GameState.player1_character)
	var black_style = GameState.get_character_piece_style(GameState.player2_character)

	# White pieces (bottom, rows 6-7)
	# Pawns
	for i in range(8):
		var pawn = ChessPieces.Pawn.new(ChessPiece.PieceColor.WHITE, Vector2i(6, i), white_style)
		board_state[6][i] = pawn

	# Back row
	board_state[7][0] = ChessPieces.Rook.new(ChessPiece.PieceColor.WHITE, Vector2i(7, 0), white_style)
	board_state[7][1] = ChessPieces.Knight.new(ChessPiece.PieceColor.WHITE, Vector2i(7, 1), white_style)
	board_state[7][2] = ChessPieces.Bishop.new(ChessPiece.PieceColor.WHITE, Vector2i(7, 2), white_style)
	board_state[7][3] = ChessPieces.Queen.new(ChessPiece.PieceColor.WHITE, Vector2i(7, 3), white_style)
	board_state[7][4] = ChessPieces.King.new(ChessPiece.PieceColor.WHITE, Vector2i(7, 4), white_style)
	board_state[7][5] = ChessPieces.Bishop.new(ChessPiece.PieceColor.WHITE, Vector2i(7, 5), white_style)
	board_state[7][6] = ChessPieces.Knight.new(ChessPiece.PieceColor.WHITE, Vector2i(7, 6), white_style)
	board_state[7][7] = ChessPieces.Rook.new(ChessPiece.PieceColor.WHITE, Vector2i(7, 7), white_style)

	# Black pieces (top, rows 0-1)
	# Pawns
	for i in range(8):
		var pawn = ChessPieces.Pawn.new(ChessPiece.PieceColor.BLACK, Vector2i(1, i), black_style)
		board_state[1][i] = pawn

	# Back row
	board_state[0][0] = ChessPieces.Rook.new(ChessPiece.PieceColor.BLACK, Vector2i(0, 0), black_style)
	board_state[0][1] = ChessPieces.Knight.new(ChessPiece.PieceColor.BLACK, Vector2i(0, 1), black_style)
	board_state[0][2] = ChessPieces.Bishop.new(ChessPiece.PieceColor.BLACK, Vector2i(0, 2), black_style)
	board_state[0][3] = ChessPieces.Queen.new(ChessPiece.PieceColor.BLACK, Vector2i(0, 3), black_style)
	board_state[0][4] = ChessPieces.King.new(ChessPiece.PieceColor.BLACK, Vector2i(0, 4), black_style)
	board_state[0][5] = ChessPieces.Bishop.new(ChessPiece.PieceColor.BLACK, Vector2i(0, 5), black_style)
	board_state[0][6] = ChessPieces.Knight.new(ChessPiece.PieceColor.BLACK, Vector2i(0, 6), black_style)
	board_state[0][7] = ChessPieces.Rook.new(ChessPiece.PieceColor.BLACK, Vector2i(0, 7), black_style)

func get_piece_at(pos: Vector2i) -> ChessPiece:
	if ChessPiece.is_valid_position(pos):
		return board_state[pos.x][pos.y]
	return null

func select_piece(pos: Vector2i) -> bool:
	var piece = get_piece_at(pos)

	if piece == null:
		return false

	# Check if it's the correct player's turn
	var is_white_piece = piece.piece_color == ChessPiece.PieceColor.WHITE
	if is_white_piece != is_white_turn:
		return false

	selected_piece = piece
	valid_moves = piece.get_valid_moves(board_state)
	return true

func try_move_piece(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	var piece = get_piece_at(from_pos)

	if piece == null:
		return false

	# Check if it's a valid move
	var moves = piece.get_valid_moves(board_state)
	if not to_pos in moves:
		return false

	# Check for capture
	var captured_piece = get_piece_at(to_pos)
	if captured_piece != null:
		handle_capture(captured_piece, piece)

	# Move the piece
	board_state[to_pos.x][to_pos.y] = piece
	board_state[from_pos.x][from_pos.y] = null
	piece.position = to_pos
	piece.has_moved = true

	# Update game state
	GameState.move_count += 1

	# Record move in history
	var move_notation = get_move_notation(piece, from_pos, to_pos, captured_piece)
	GameState.move_history.append(move_notation)

	# Emit signals
	piece_moved.emit(from_pos, to_pos, piece)

	# Switch turns
	is_white_turn = !is_white_turn
	turn_changed.emit(is_white_turn)

	selected_piece = null
	valid_moves = []

	# Check for game over (if king was captured)
	if captured_piece != null and captured_piece.piece_type == ChessPiece.PieceType.KING:
		var result = "checkmate_white" if piece.piece_color == ChessPiece.PieceColor.WHITE else "checkmate_black"
		GameState.game_result = result
		game_over.emit(result)
		return true

	# Check for checkmate or stalemate
	check_game_state()

	return true

func handle_capture(captured: ChessPiece, captor: ChessPiece):
	# Add to captured pieces list
	if captor.piece_color == ChessPiece.PieceColor.WHITE:
		captured_pieces_white.append(captured)
		GameState.player1_score += captured.get_value()
	else:
		captured_pieces_black.append(captured)
		GameState.player2_score += captured.get_value()

	GameState.captured_pieces += 1
	piece_captured.emit(captured, captor)

func get_captured_by_white() -> Array:
	return captured_pieces_white

func get_captured_by_black() -> Array:
	return captured_pieces_black

func reset():
	board_state = []
	captured_pieces_white = []
	captured_pieces_black = []
	is_white_turn = true
	selected_piece = null
	valid_moves = []
	initialize_board()

func get_move_notation(piece: ChessPiece, from_pos: Vector2i, to_pos: Vector2i, captured: ChessPiece) -> String:
	var piece_symbol = ""
	match piece.piece_type:
		ChessPiece.PieceType.KING: piece_symbol = "K"
		ChessPiece.PieceType.QUEEN: piece_symbol = "Q"
		ChessPiece.PieceType.ROOK: piece_symbol = "R"
		ChessPiece.PieceType.BISHOP: piece_symbol = "B"
		ChessPiece.PieceType.KNIGHT: piece_symbol = "N"
		ChessPiece.PieceType.PAWN: piece_symbol = ""

	var from_notation = get_square_notation(from_pos)
	var to_notation = get_square_notation(to_pos)
	var capture_symbol = "x" if captured != null else "-"

	return piece_symbol + from_notation + capture_symbol + to_notation

func get_square_notation(pos: Vector2i) -> String:
	var files = ["a", "b", "c", "d", "e", "f", "g", "h"]
	var rank = str(8 - pos.x)
	var file = files[pos.y]
	return file + rank

func check_game_state():
	# Check if the current player has any valid moves
	var current_color = ChessPiece.PieceColor.WHITE if is_white_turn else ChessPiece.PieceColor.BLACK
	var has_valid_moves = false

	for row in range(8):
		for col in range(8):
			var piece = board_state[row][col]
			if piece != null and piece.piece_color == current_color:
				var moves = piece.get_valid_moves(board_state)
				if moves.size() > 0:
					has_valid_moves = true
					break
		if has_valid_moves:
			break

	# If no valid moves, it's either checkmate or stalemate
	if not has_valid_moves:
		# Check if the king is in check
		var in_check = is_king_in_check(current_color)
		if in_check:
			# Checkmate
			var result = "checkmate_black" if current_color == ChessPiece.PieceColor.WHITE else "checkmate_white"
			GameState.game_result = result
			game_over.emit(result)
		else:
			# Stalemate
			GameState.game_result = "stalemate"
			game_over.emit("stalemate")

func is_king_in_check(color: ChessPiece.PieceColor) -> bool:
	# Find the king
	var king_pos = Vector2i(-1, -1)
	for row in range(8):
		for col in range(8):
			var piece = board_state[row][col]
			if piece != null and piece.piece_type == ChessPiece.PieceType.KING and piece.piece_color == color:
				king_pos = Vector2i(row, col)
				break
		if king_pos != Vector2i(-1, -1):
			break

	if king_pos == Vector2i(-1, -1):
		return false

	# Check if any enemy piece can attack the king
	var enemy_color = ChessPiece.PieceColor.BLACK if color == ChessPiece.PieceColor.WHITE else ChessPiece.PieceColor.WHITE
	for row in range(8):
		for col in range(8):
			var piece = board_state[row][col]
			if piece != null and piece.piece_color == enemy_color:
				var moves = piece.get_valid_moves(board_state)
				if king_pos in moves:
					return true

	return false
