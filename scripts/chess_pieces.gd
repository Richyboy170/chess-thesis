extends Node

# This file contains all the specific chess piece implementations

class Pawn extends ChessPiece:
	func _init(p_color: PieceColor, p_position: Vector2i, style: String = "classic"):
		super(PieceType.PAWN, p_color, p_position, style)

	func get_valid_moves(board_state: Array) -> Array:
		var moves = []
		var direction = -1 if piece_color == PieceColor.WHITE else 1

		# Forward move
		var forward = Vector2i(position.x + direction, position.y)
		if is_valid_position(forward) and is_empty(board_state, forward):
			moves.append(forward)

			# Double move from starting position
			if not has_moved:
				var double_forward = Vector2i(position.x + direction * 2, position.y)
				if is_empty(board_state, double_forward):
					moves.append(double_forward)

		# Capture diagonally
		for dy in [-1, 1]:
			var capture_pos = Vector2i(position.x + direction, position.y + dy)
			if is_enemy(board_state, capture_pos):
				moves.append(capture_pos)

		return moves

class Rook extends ChessPiece:
	func _init(p_color: PieceColor, p_position: Vector2i, style: String = "classic"):
		super(PieceType.ROOK, p_color, p_position, style)

	func get_valid_moves(board_state: Array) -> Array:
		var moves = []
		var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

		for dir in directions:
			var current = position + dir
			while is_valid_position(current):
				if is_empty(board_state, current):
					moves.append(current)
					current += dir
				elif is_enemy(board_state, current):
					moves.append(current)
					break
				else:
					break

		return moves

class Knight extends ChessPiece:
	func _init(p_color: PieceColor, p_position: Vector2i, style: String = "classic"):
		super(PieceType.KNIGHT, p_color, p_position, style)

	func get_valid_moves(board_state: Array) -> Array:
		var moves = []
		var knight_moves = [
			Vector2i(2, 1), Vector2i(2, -1), Vector2i(-2, 1), Vector2i(-2, -1),
			Vector2i(1, 2), Vector2i(1, -2), Vector2i(-1, 2), Vector2i(-1, -2)
		]

		for move in knight_moves:
			var target = position + move
			if is_valid_position(target) and (is_empty(board_state, target) or is_enemy(board_state, target)):
				moves.append(target)

		return moves

class Bishop extends ChessPiece:
	func _init(p_color: PieceColor, p_position: Vector2i, style: String = "classic"):
		super(PieceType.BISHOP, p_color, p_position, style)

	func get_valid_moves(board_state: Array) -> Array:
		var moves = []
		var directions = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]

		for dir in directions:
			var current = position + dir
			while is_valid_position(current):
				if is_empty(board_state, current):
					moves.append(current)
					current += dir
				elif is_enemy(board_state, current):
					moves.append(current)
					break
				else:
					break

		return moves

class Queen extends ChessPiece:
	func _init(p_color: PieceColor, p_position: Vector2i, style: String = "classic"):
		super(PieceType.QUEEN, p_color, p_position, style)

	func get_valid_moves(board_state: Array) -> Array:
		var moves = []
		var directions = [
			Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
			Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
		]

		for dir in directions:
			var current = position + dir
			while is_valid_position(current):
				if is_empty(board_state, current):
					moves.append(current)
					current += dir
				elif is_enemy(board_state, current):
					moves.append(current)
					break
				else:
					break

		return moves

class King extends ChessPiece:
	func _init(p_color: PieceColor, p_position: Vector2i, style: String = "classic"):
		super(PieceType.KING, p_color, p_position, style)

	func get_valid_moves(board_state: Array) -> Array:
		var moves = []
		var directions = [
			Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
			Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
		]

		for dir in directions:
			var target = position + dir
			if is_valid_position(target) and (is_empty(board_state, target) or is_enemy(board_state, target)):
				moves.append(target)

		return moves
