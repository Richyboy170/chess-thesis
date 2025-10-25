extends Node
class_name ChessPiece

enum PieceType { PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING }
enum PieceColor { WHITE, BLACK }

var piece_type: PieceType
var piece_color: PieceColor
var position: Vector2i  # Board position (row, col)
var has_moved: bool = false
var character_style: String = "classic"

# Piece values for scoring
const PIECE_VALUES = {
	PieceType.PAWN: 1,
	PieceType.KNIGHT: 3,
	PieceType.BISHOP: 3,
	PieceType.ROOK: 5,
	PieceType.QUEEN: 9,
	PieceType.KING: 0
}

func _init(p_type: PieceType, p_color: PieceColor, p_position: Vector2i, style: String = "classic"):
	piece_type = p_type
	piece_color = p_color
	position = p_position
	character_style = style

func get_value() -> int:
	return PIECE_VALUES[piece_type]

func get_piece_name() -> String:
	var color_str = "White" if piece_color == PieceColor.WHITE else "Black"
	var type_str = PieceType.keys()[piece_type].capitalize()
	return color_str + " " + type_str

func get_piece_symbol() -> String:
	var symbols = {
		PieceType.KING: ["♔", "♚"],
		PieceType.QUEEN: ["♕", "♛"],
		PieceType.ROOK: ["♖", "♜"],
		PieceType.BISHOP: ["♗", "♝"],
		PieceType.KNIGHT: ["♘", "♞"],
		PieceType.PAWN: ["♙", "♟"]
	}
	var color_idx = 0 if piece_color == PieceColor.WHITE else 1
	return symbols[piece_type][color_idx]

# Virtual method - override in specific piece types
func get_valid_moves(_board_state: Array) -> Array:
	return []

# Helper function to check if a position is on the board
static func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < 8 and pos.y >= 0 and pos.y < 8

# Helper function to check if a square is empty
static func is_empty(board_state: Array, pos: Vector2i) -> bool:
	if not is_valid_position(pos):
		return false
	return board_state[pos.x][pos.y] == null

# Helper function to check if a square has an enemy piece
func is_enemy(board_state: Array, pos: Vector2i) -> bool:
	if not is_valid_position(pos):
		return false
	var piece = board_state[pos.x][pos.y]
	return piece != null and piece.piece_color != piece_color

# Helper function to check if a square has a friendly piece
func is_friendly(board_state: Array, pos: Vector2i) -> bool:
	if not is_valid_position(pos):
		return false
	var piece = board_state[pos.x][pos.y]
	return piece != null and piece.piece_color == piece_color
