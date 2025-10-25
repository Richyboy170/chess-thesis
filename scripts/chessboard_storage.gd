extends Node

## ChessboardStorage
## Global singleton for storing and managing the chess board instance
## Provides centralized access to the validated chessboard
## To enable: Add to Project Settings -> AutoLoad

# Signals
signal chessboard_created(chessboard: ChessBoard)
signal chessboard_cleared()
signal chessboard_validation_failed(error_message: String)

# Storage
var _chessboard: ChessBoard = null
var _is_validated: bool = false
var _creation_result: ChessboardFactory.CreationResult = null

## Check if a chessboard is currently stored
func has_chessboard() -> bool:
	return _chessboard != null

## Check if the stored chessboard is validated
func is_validated() -> bool:
	return _is_validated and _chessboard != null

## Get the stored chessboard (returns null if not created or invalid)
func get_chessboard() -> ChessBoard:
	if not is_validated():
		push_warning("ChessboardStorage: Attempting to get chessboard but it's not validated")
		return null
	return _chessboard

## Get chessboard without validation check (use with caution)
func get_chessboard_unsafe() -> ChessBoard:
	return _chessboard

## Create and store a new chessboard with full validation
func create_and_store_chessboard() -> bool:
	print("\n=== ChessboardStorage: Creating and storing chessboard ===")

	# Clear any existing board
	if _chessboard != null:
		print("ChessboardStorage: Clearing existing chessboard")
		clear_chessboard()

	# Use factory to create and validate
	_creation_result = ChessboardFactory.create_chessboard()

	# Check result
	if _creation_result.is_valid():
		_chessboard = _creation_result.chessboard
		_is_validated = true
		print("ChessboardStorage: ✓ Chessboard created and stored successfully")
		print(_creation_result.get_error_report())
		emit_signal("chessboard_created", _chessboard)
		return true
	else:
		_chessboard = null
		_is_validated = false
		var error_report = _creation_result.get_error_report()
		print("ChessboardStorage: ✗ FAILED to create chessboard")
		print(error_report)
		emit_signal("chessboard_validation_failed", error_report)
		return false

## Store an existing chessboard with validation
func store_chessboard(board: ChessBoard) -> bool:
	print("\n=== ChessboardStorage: Storing existing chessboard ===")

	if board == null:
		push_error("ChessboardStorage: Cannot store null chessboard")
		return false

	# Validate the provided board
	_creation_result = ChessboardFactory.verify_existing_board(board)

	if _creation_result.is_valid():
		# Clear old board if exists
		if _chessboard != null and _chessboard != board:
			clear_chessboard()

		_chessboard = board
		_is_validated = true
		print("ChessboardStorage: ✓ Chessboard stored successfully")
		emit_signal("chessboard_created", _chessboard)
		return true
	else:
		var error_report = _creation_result.get_error_report()
		push_error("ChessboardStorage: Board validation failed - " + error_report)
		emit_signal("chessboard_validation_failed", error_report)
		return false

## Clear the stored chessboard
func clear_chessboard():
	if _chessboard != null:
		print("ChessboardStorage: Clearing chessboard")
		# Don't free the board here - let the owner handle it
		_chessboard = null
		_is_validated = false
		_creation_result = null
		emit_signal("chessboard_cleared")

## Re-validate the stored chessboard
func revalidate() -> bool:
	if _chessboard == null:
		push_warning("ChessboardStorage: Cannot revalidate - no chessboard stored")
		return false

	print("ChessboardStorage: Re-validating stored chessboard")
	_creation_result = ChessboardFactory.verify_existing_board(_chessboard)

	if _creation_result.is_valid():
		_is_validated = true
		print("ChessboardStorage: ✓ Revalidation passed")
		return true
	else:
		_is_validated = false
		var error_report = _creation_result.get_error_report()
		push_error("ChessboardStorage: ✗ Revalidation failed - " + error_report)
		emit_signal("chessboard_validation_failed", error_report)
		return false

## Get the last creation/validation result
func get_last_result() -> ChessboardFactory.CreationResult:
	return _creation_result

## Get detailed status report
func get_status_report() -> String:
	var report = "\n=== ChessboardStorage Status Report ===\n"

	if _chessboard == null:
		report += "Status: NO CHESSBOARD STORED\n"
	else:
		report += "Status: Chessboard stored\n"
		report += "Validated: %s\n" % ("YES" if _is_validated else "NO")

		if _creation_result != null:
			report += "\nLast Operation Result:\n"
			report += _creation_result.get_error_report()

	report += "\n========================================"
	return report

## Print status to console
func print_status():
	print(get_status_report())

## Quick health check
func health_check() -> bool:
	if not has_chessboard():
		push_warning("ChessboardStorage: Health check failed - no chessboard")
		return false

	if not is_validated():
		push_warning("ChessboardStorage: Health check failed - not validated")
		return false

	# Quick validation
	if not ChessboardValidator.quick_validate(_chessboard):
		push_error("ChessboardStorage: Health check failed - quick validation failed")
		_is_validated = false
		return false

	print("ChessboardStorage: Health check passed ✓")
	return true
