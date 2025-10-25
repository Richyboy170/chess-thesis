extends Node
class_name ChessboardFactory

## ChessboardFactory
## Responsible for creating and validating chess board instances
## Uses factory pattern with validation to ensure board integrity

# Result class to encapsulate creation result
class CreationResult:
	var success: bool = false
	var chessboard: ChessBoard = null
	var error_message: String = ""
	var validation_details: Array = []

	func _init(p_success: bool, p_chessboard: ChessBoard = null, p_error: String = "", p_details: Array = []):
		success = p_success
		chessboard = p_chessboard
		error_message = p_error
		validation_details = p_details

	func is_valid() -> bool:
		return success and chessboard != null

	func get_error_report() -> String:
		if success:
			return "Chessboard created successfully"

		var report = "CHESSBOARD CREATION FAILED\n"
		report += "Error: " + error_message + "\n"
		if validation_details.size() > 0:
			report += "Validation Details:\n"
			for detail in validation_details:
				report += "  - " + detail + "\n"
		return report

## Create a new chessboard instance with full validation
static func create_chessboard() -> CreationResult:
	print("ChessboardFactory: Starting chessboard creation...")

	# Step 1: Create the chessboard instance
	var board = ChessBoard.new()
	if board == null:
		return CreationResult.new(false, null, "Failed to instantiate ChessBoard class")

	print("ChessboardFactory: ChessBoard instance created")

	# Step 2: Validate the created board
	var validation_result = ChessboardValidator.validate_board(board)

	if not validation_result.is_valid:
		var error_msg = "Board validation failed: " + validation_result.error_summary
		print("ChessboardFactory: " + error_msg)
		board.queue_free()  # Clean up invalid board
		return CreationResult.new(false, null, error_msg, validation_result.errors)

	# Step 3: Return successful result
	print("ChessboardFactory: Chessboard created and validated successfully")
	print("ChessboardFactory: Board has %d pieces in correct positions" % validation_result.piece_count)

	return CreationResult.new(
		true,
		board,
		"Chessboard created successfully",
		validation_result.validation_details
	)

## Create chessboard with custom validation rules
static func create_chessboard_with_options(strict_validation: bool = true) -> CreationResult:
	print("ChessboardFactory: Creating chessboard with custom options (strict=%s)" % strict_validation)

	var board = ChessBoard.new()
	if board == null:
		return CreationResult.new(false, null, "Failed to instantiate ChessBoard class")

	# Apply validation based on strictness
	var validation_result = ChessboardValidator.validate_board(board, strict_validation)

	if not validation_result.is_valid:
		var error_msg = "Board validation failed: " + validation_result.error_summary
		print("ChessboardFactory: " + error_msg)
		board.queue_free()
		return CreationResult.new(false, null, error_msg, validation_result.errors)

	return CreationResult.new(
		true,
		board,
		"Chessboard created successfully",
		validation_result.validation_details
	)

## Verify an existing chessboard is still valid
static func verify_existing_board(board: ChessBoard) -> CreationResult:
	if board == null:
		return CreationResult.new(false, null, "Provided chessboard is null")

	var validation_result = ChessboardValidator.validate_board(board)

	if not validation_result.is_valid:
		return CreationResult.new(
			false,
			board,
			"Existing board is invalid: " + validation_result.error_summary,
			validation_result.errors
		)

	return CreationResult.new(
		true,
		board,
		"Existing board is valid",
		validation_result.validation_details
	)
