extends Node

## AnimationErrorDetector - Singleton for tracking animation errors
##
## This system captures, logs, and reports all animation-related errors
## so they can be easily reviewed and debugged later.
##
## Usage:
##   AnimationErrorDetector.log_error(type, message, context)
##   AnimationErrorDetector.export_errors_to_file()
##   AnimationErrorDetector.get_error_summary()

## Error types
enum ErrorType {
	FILE_NOT_FOUND,
	LOAD_FAILED,
	PLUGIN_MISSING,
	INVALID_RESOURCE,
	PLAYBACK_FAILED,
	CONFIGURATION_ERROR,
	LIVE2D_ERROR,
	UNKNOWN
}

## Error data structure
class AnimationError:
	var timestamp: String
	var error_type: ErrorType
	var message: String
	var context: Dictionary
	var stack_trace: Array

	func _init(p_type: ErrorType, p_message: String, p_context: Dictionary):
		timestamp = Time.get_datetime_string_from_system()
		error_type = p_type
		message = p_message
		context = p_context
		stack_trace = get_stack()

	func to_dict() -> Dictionary:
		return {
			"timestamp": timestamp,
			"error_type": ErrorType.keys()[error_type],
			"message": message,
			"context": context,
			"stack_trace": stack_trace
		}

	func _to_string() -> String:
		var error_type_name = ErrorType.keys()[error_type]
		var context_str = JSON.stringify(context, "\t")
		return "[%s] %s: %s\nContext: %s" % [timestamp, error_type_name, message, context_str]

	# Compatibility method that calls _to_string()
	func to_string() -> String:
		return _to_string()

## Storage
var errors: Array[AnimationError] = []
var error_count_by_type: Dictionary = {}
var max_errors: int = 1000  # Prevent memory issues
var auto_save_enabled: bool = true
var error_log_path: String = "user://animation_errors.log"

## Helper function to repeat strings
static func repeat_string(s: String, count: int) -> String:
	var result = ""
	for i in count:
		result += s
	return result

## Signals
signal error_logged(error: AnimationError)
signal critical_error_count_reached(count: int)

func _ready():
	print("🔍 AnimationErrorDetector initialized")
	# Initialize error counts
	for type in ErrorType.values():
		error_count_by_type[type] = 0

## Main logging function
func log_error(type: ErrorType, message: String, context: Dictionary = {}) -> void:
	# Create error object
	var error = AnimationError.new(type, message, context)

	# Store error
	errors.append(error)
	error_count_by_type[type] += 1

	# Limit storage to prevent memory issues
	if errors.size() > max_errors:
		errors.pop_front()

	# Print to console with visual indicator
	print_error_to_console(error)

	# Emit signal
	error_logged.emit(error)

	# Auto-save if enabled
	if auto_save_enabled:
		save_latest_error_to_file(error)

	# Check for critical error count
	if errors.size() > 50:
		critical_error_count_reached.emit(errors.size())

## Specialized logging functions for common cases
func log_file_not_found(file_path: String, expected_location: String = "") -> void:
	log_error(ErrorType.FILE_NOT_FOUND,
		"Animation file not found: %s" % file_path,
		{"file_path": file_path, "expected_location": expected_location})

func log_load_failed(file_path: String, resource_type: String = "") -> void:
	log_error(ErrorType.LOAD_FAILED,
		"Failed to load animation resource: %s" % file_path,
		{"file_path": file_path, "resource_type": resource_type})

func log_plugin_missing(plugin_name: String, feature: String = "") -> void:
	log_error(ErrorType.PLUGIN_MISSING,
		"Plugin not available: %s" % plugin_name,
		{"plugin_name": plugin_name, "feature": feature})

func log_playback_failed(animation_name: String, node_path: String = "") -> void:
	log_error(ErrorType.PLAYBACK_FAILED,
		"Animation playback failed: %s" % animation_name,
		{"animation_name": animation_name, "node_path": node_path})

func log_live2d_error(model_path: String, error_detail: String = "") -> void:
	log_error(ErrorType.LIVE2D_ERROR,
		"Live2D error for model: %s - %s" % [model_path, error_detail],
		{"model_path": model_path, "error_detail": error_detail})

func log_config_error(character_id: int, config_issue: String) -> void:
	log_error(ErrorType.CONFIGURATION_ERROR,
		"Configuration error for character %d: %s" % [character_id, config_issue],
		{"character_id": character_id, "config_issue": config_issue})

## Query functions
func get_errors_by_type(type: ErrorType) -> Array[AnimationError]:
	var filtered: Array[AnimationError] = []
	for error in errors:
		if error.error_type == type:
			filtered.append(error)
	return filtered

func get_recent_errors(count: int = 10) -> Array[AnimationError]:
	var start_idx = max(0, errors.size() - count)
	return errors.slice(start_idx)

func get_error_count() -> int:
	return errors.size()

func get_error_count_by_type(type: ErrorType) -> int:
	return error_count_by_type.get(type, 0)

func has_errors() -> bool:
	return errors.size() > 0

func has_critical_errors() -> bool:
	return (get_error_count_by_type(ErrorType.LOAD_FAILED) > 0 or
			get_error_count_by_type(ErrorType.PLAYBACK_FAILED) > 0)

## Summary and reporting
func get_error_summary() -> String:
	if errors.is_empty():
		return "✓ No animation errors detected"

	var summary = "📊 Animation Error Summary\n"
	summary += repeat_string("=", 50) + "\n"
	summary += "Total Errors: %d\n\n" % errors.size()

	summary += "Errors by Type:\n"
	for type in ErrorType.values():
		var count = error_count_by_type[type]
		if count > 0:
			summary += "  • %s: %d\n" % [ErrorType.keys()[type], count]

	summary += "\nRecent Errors (last 5):\n"
	var recent = get_recent_errors(5)
	for error in recent:
		summary += "\n" + error.to_string() + "\n"

	return summary

func get_detailed_report() -> String:
	var report = "📋 Detailed Animation Error Report\n"
	report += repeat_string("=", 70) + "\n"
	report += "Generated: %s\n" % Time.get_datetime_string_from_system()
	report += "Total Errors: %d\n" % errors.size()
	report += repeat_string("=", 70) + "\n\n"

	for i in errors.size():
		report += "Error #%d:\n" % (i + 1)
		report += errors[i].to_string() + "\n"
		report += repeat_string("-", 70) + "\n\n"

	return report

## File operations
func save_latest_error_to_file(error: AnimationError) -> void:
	var file = FileAccess.open(error_log_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		file.store_line(error.to_string())
		file.store_line(repeat_string("-", 70))
		file.close()

func export_errors_to_file(custom_path: String = "") -> bool:
	var path = custom_path if custom_path != "" else error_log_path
	var file = FileAccess.open(path, FileAccess.WRITE)

	if file:
		file.store_string(get_detailed_report())
		file.close()
		print("✓ Errors exported to: %s" % path)
		return true
	else:
		push_error("Failed to export errors to file: %s" % path)
		return false

func export_errors_as_json(file_path: String = "user://animation_errors.json") -> bool:
	var error_data = []
	for error in errors:
		error_data.append(error.to_dict())

	var json_string = JSON.stringify(error_data, "\t")
	var file = FileAccess.open(file_path, FileAccess.WRITE)

	if file:
		file.store_string(json_string)
		file.close()
		print("✓ Errors exported as JSON to: %s" % file_path)
		return true
	else:
		push_error("Failed to export errors as JSON: %s" % file_path)
		return false

func load_errors_from_json(file_path: String = "user://animation_errors.json") -> bool:
	if not FileAccess.file_exists(file_path):
		return false

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			print("✓ Loaded %d errors from JSON" % json.data.size())
			return true

	return false

func clear_errors() -> void:
	errors.clear()
	for type in ErrorType.values():
		error_count_by_type[type] = 0
	print("✓ All animation errors cleared")

func clear_log_file() -> void:
	if FileAccess.file_exists(error_log_path):
		DirAccess.remove_absolute(error_log_path)
		print("✓ Error log file cleared")

## Console output
func print_error_to_console(error: AnimationError) -> void:
	var error_type_name = ErrorType.keys()[error.error_type]
	var icon = get_error_icon(error.error_type)

	print_rich("[color=red]%s ANIMATION ERROR [%s][/color]" % [icon, error_type_name])
	print_rich("[color=yellow]Message:[/color] %s" % error.message)
	if not error.context.is_empty():
		print_rich("[color=cyan]Context:[/color] %s" % JSON.stringify(error.context))

func get_error_icon(type: ErrorType) -> String:
	match type:
		ErrorType.FILE_NOT_FOUND: return "📁❌"
		ErrorType.LOAD_FAILED: return "⚠️"
		ErrorType.PLUGIN_MISSING: return "🔌❌"
		ErrorType.INVALID_RESOURCE: return "🚫"
		ErrorType.PLAYBACK_FAILED: return "▶️❌"
		ErrorType.CONFIGURATION_ERROR: return "⚙️❌"
		ErrorType.LIVE2D_ERROR: return "🎭❌"
		_: return "❓"

## Debug functions
func print_summary() -> void:
	print(get_error_summary())

func print_all_errors() -> void:
	print(get_detailed_report())

## Hotkey handler (call from game scenes)
func handle_debug_input(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F9:  # Print summary
				print_summary()
				return true
			KEY_F10:  # Export to file
				export_errors_to_file()
				return true
			KEY_F11:  # Clear errors
				clear_errors()
				return true
	return false
