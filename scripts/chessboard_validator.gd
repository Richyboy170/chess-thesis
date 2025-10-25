extends Node
class_name ChessboardValidator

## ChessboardValidator
## Validates chess board integrity and correct setup
## Provides detailed error reporting for debugging

# Validation result class
class ValidationResult:
	var is_valid: bool = true
	var errors: Array = []
	var validation_details: Array = []
	var piece_count: int = 0
	var error_summary: String = ""

	func add_error(error: String):
		is_valid = false
		errors.append(error)
		print("ValidationResult: ERROR - " + error)

	func add_detail(detail: String):
		validation_details.append(detail)

	func finalize():
		if not is_valid:
			error_summary = "Found %d error(s)" % errors.size()
		else:
			error_summary = "All validations passed"

## Main validation function
static func validate_board(board: ChessBoard, strict: bool = true) -> ValidationResult:
	var result = ValidationResult.new()

	print("ChessboardValidator: Starting board validation (strict=%s)" % strict)

	# Validation 1: Check board is not null
	if board == null:
		result.add_error("Board is null")
		result.finalize()
		return result

	result.add_detail("Board instance exists")

	# Validation 2: Check board_state exists and is correct size
	if not _validate_board_state_structure(board, result):
		result.finalize()
		return result

	# Validation 3: Validate piece positions
	if not _validate_piece_positions(board, result, strict):
		result.finalize()
		return result

	# Validation 4: Count pieces
	result.piece_count = _count_pieces(board)
	result.add_detail("Found %d pieces on the board" % result.piece_count)

	# Validation 5: Check starting position (strict mode)
	if strict:
		if not _validate_starting_position(board, result):
			result.finalize()
			return result

	# Validation 6: Check turn state
	if board.current_turn == null:
		result.add_error("Current turn is null")
	else:
		result.add_detail("Current turn: " + str(board.current_turn))

	# Validation 7: Verify arrays are initialized
	if board.white_captured == null or board.black_captured == null:
		result.add_error("Captured piece arrays are null")
	else:
		result.add_detail("Captured piece tracking initialized")

	result.finalize()

	if result.is_valid:
		print("ChessboardValidator: Validation PASSED ✓")
	else:
		print("ChessboardValidator: Validation FAILED ✗")

	return result

## Validate board_state structure
static func _validate_board_state_structure(board: ChessBoard, result: ValidationResult) -> bool:
	if board.board_state == null:
		result.add_error("board_state is null")
		return false

	if board.board_state.size() != 8:
		result.add_error("board_state has %d rows (expected 8)" % board.board_state.size())
		return false

	# Check each row
	for row in range(8):
		if board.board_state[row] == null:
			result.add_error("Row %d is null" % row)
			return false

		if board.board_state[row].size() != 8:
			result.add_error("Row %d has %d columns (expected 8)" % [row, board.board_state[row].size()])
			return false

	result.add_detail("Board state structure valid (8x8 grid)")
	return true

## Validate piece positions are within bounds
static func _validate_piece_positions(board: ChessBoard, result: ValidationResult, strict: bool) -> bool:
	var valid = true

	for row in range(8):
		for col in range(8):
			var piece = board.board_state[row][col]
			if piece != null:
				# Check piece has correct position stored
				if piece.row != row or piece.col != col:
					var error = "Piece at [%d,%d] thinks it's at [%d,%d]" % [row, col, piece.row, piece.col]
					if strict:
						result.add_error(error)
						valid = false
					else:
						result.add_detail("WARNING: " + error)

				# Check piece has valid type
				if piece.piece_type == null:
					result.add_error("Piece at [%d,%d] has null piece_type" % [row, col])
					valid = false

				# Check piece has valid color
				if piece.color != "white" and piece.color != "black":
					result.add_error("Piece at [%d,%d] has invalid color: %s" % [row, col, piece.color])
					valid = false

	if valid:
		result.add_detail("All pieces have valid positions and properties")

	return valid

## Count total pieces on board
static func _count_pieces(board: ChessBoard) -> int:
	var count = 0
	for row in range(8):
		for col in range(8):
			if board.board_state[row][col] != null:
				count += 1
	return count

## Validate starting position (strict mode)
static func _validate_starting_position(board: ChessBoard, result: ValidationResult) -> bool:
	var piece_count = _count_pieces(board)

	# Standard chess starting position has 32 pieces
	if piece_count != 32:
		result.add_error("Expected 32 pieces in starting position, found %d" % piece_count)
		return false

	# Validate specific starting pieces
	var validations = []

	# Check white pieces (rows 6-7)
	validations.append(_validate_row_pieces(board, 7, "white", ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]))
	validations.append(_validate_row_pieces(board, 6, "white", ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"]))

	# Check black pieces (rows 0-1)
	validations.append(_validate_row_pieces(board, 0, "black", ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]))
	validations.append(_validate_row_pieces(board, 1, "black", ["pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn", "pawn"]))

	# Check empty squares (rows 2-5)
	for row in range(2, 6):
		for col in range(8):
			if board.board_state[row][col] != null:
				result.add_error("Expected empty square at [%d,%d] but found piece" % [row, col])
				return false

	# Check if any validation failed
	for validation_result in validations:
		if not validation_result.success:
			result.add_error(validation_result.error)
			return false

	result.add_detail("Starting position is correct (32 pieces in standard setup)")
	return true

## Validate pieces in a specific row
static func _validate_row_pieces(board: ChessBoard, row: int, expected_color: String, expected_types: Array) -> Dictionary:
	for col in range(8):
		var piece = board.board_state[row][col]
		if piece == null:
			return {"success": false, "error": "Expected %s %s at [%d,%d] but found empty square" % [expected_color, expected_types[col], row, col]}

		if piece.color != expected_color:
			return {"success": false, "error": "Expected %s piece at [%d,%d] but found %s" % [expected_color, row, col, piece.color]}

		if piece.piece_type != expected_types[col]:
			return {"success": false, "error": "Expected %s at [%d,%d] but found %s" % [expected_types[col], row, col, piece.piece_type]}

	return {"success": true, "error": ""}

## Quick validation check (for runtime checks)
static func quick_validate(board: ChessBoard) -> bool:
	if board == null or board.board_state == null:
		return false

	if board.board_state.size() != 8:
		return false

	for row in board.board_state:
		if row == null or row.size() != 8:
			return false

	return true
