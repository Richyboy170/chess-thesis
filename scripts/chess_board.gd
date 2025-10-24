extends Node
class_name ChessBoard

signal piece_moved(from_pos: Vector2i, to_pos: Vector2i)
signal piece_captured(piece: ChessPiece, captured_by: ChessPiece)
signal turn_changed(is_white_turn: bool)
signal game_over(winner: ChessPiece.PieceColor)

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

	# Emit signals
	piece_moved.emit(from_pos, to_pos)

	# Switch turns
	is_white_turn = !is_white_turn
	turn_changed.emit(is_white_turn)

	selected_piece = null
	valid_moves = []

	# Check for game over (if king was captured)
	if captured_piece != null and captured_piece.piece_type == ChessPiece.PieceType.KING:
		game_over.emit(piece.piece_color)

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
