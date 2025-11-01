extends Node

## GDExtensionErrorDetector - Singleton for tracking GDExtension-related errors
##
## This system detects, captures, and reports errors related to GDExtension loading,
## missing libraries, configuration issues, and plugin problems.
##
## Usage:
##   GDExtensionErrorDetector.scan_for_issues()
##   GDExtensionErrorDetector.log_error(type, message, context)
##   GDExtensionErrorDetector.export_errors_to_file()
##   GDExtensionErrorDetector.get_error_summary()

## Error types specific to GDExtension
enum ErrorType {
	LIBRARY_NOT_FOUND,          # Dynamic library file missing
	GDEXTENSION_NOT_FOUND,      # .gdextension file not found
	CONFIGURATION_ERROR,        # Invalid configuration in .gdextension
	SYMBOL_NOT_FOUND,          # Entry symbol missing in library
	WRONG_GODOT_VERSION,       # Incompatible Godot version
	PLATFORM_MISMATCH,         # Library not available for current platform
	NESTED_PROJECT_WARNING,    # Nested project.godot detected
	PLUGIN_LOAD_FAILED,        # Plugin failed to load
	MISSING_DEPENDENCIES,      # Missing required dependencies
	PERMISSION_ERROR,          # File permission issues
	UNKNOWN
}

## Error data structure
class GDExtensionError:
	var timestamp: String
	var error_type: ErrorType
	var message: String
	var context: Dictionary
	var severity: String  # "critical", "warning", "info"
	var suggested_fix: String

	func _init(p_type: ErrorType, p_message: String, p_context: Dictionary, p_severity: String = "critical", p_fix: String = ""):
		timestamp = Time.get_datetime_string_from_system()
		error_type = p_type
		message = p_message
		context = p_context
		severity = p_severity
		suggested_fix = p_fix

	func to_dict() -> Dictionary:
		return {
			"timestamp": timestamp,
			"error_type": ErrorType.keys()[error_type],
			"message": message,
			"context": context,
			"severity": severity,
			"suggested_fix": suggested_fix
		}

	func _to_string() -> String:
		var error_type_name = ErrorType.keys()[error_type]
		var context_str = JSON.stringify(context, "\t")
		var output = "[%s] [%s] %s: %s\nContext: %s" % [timestamp, severity.to_upper(), error_type_name, message, context_str]
		if suggested_fix != "":
			output += "\n💡 Suggested Fix: %s" % suggested_fix
		return output

## Storage
var errors: Array[GDExtensionError] = []
var error_count_by_type: Dictionary = {}
var max_errors: int = 500
var auto_scan_on_ready: bool = true
var error_log_path: String = "user://gdextension_errors.log"

## Known extensions to monitor
var monitored_extensions: Array[String] = [
	"res://gd_cubism/gd_cubism.gdextension"
]

## Helper function to repeat strings
static func repeat_string(s: String, count: int) -> String:
	var result = ""
	for i in count:
		result += s
	return result

## Signals
signal error_logged(error: GDExtensionError)
signal critical_error_detected(error: GDExtensionError)
signal scan_completed(error_count: int)

func _ready():
	print("🔍 GDExtensionErrorDetector initialized")

	# Initialize error counts
	for type in ErrorType.values():
		error_count_by_type[type] = 0

	# Auto-scan for issues
	if auto_scan_on_ready:
		call_deferred("scan_for_issues")

## Main scanning function - proactively detect issues
func scan_for_issues() -> void:
	print("🔎 Scanning for GDExtension issues...")

	var issues_found = 0

	# Check each monitored extension
	for ext_path in monitored_extensions:
		issues_found += scan_extension(ext_path)

	# Check for nested projects
	issues_found += scan_for_nested_projects()

	# Check for common permission issues
	issues_found += scan_for_permission_issues()

	scan_completed.emit(issues_found)

	if issues_found > 0:
		print("⚠️ Found %d GDExtension issues" % issues_found)
		print_summary()
	else:
		print("✓ No GDExtension issues detected")

## Scan a specific GDExtension
func scan_extension(extension_path: String) -> int:
	var issues = 0

	# Check if .gdextension file exists
	if not FileAccess.file_exists(extension_path):
		log_error(ErrorType.GDEXTENSION_NOT_FOUND,
			"GDExtension file not found: %s" % extension_path,
			{"extension_path": extension_path},
			"critical",
			"Ensure the extension is properly installed and the path is correct")
		return issues + 1

	# Parse the .gdextension file
	var config = ConfigFile.new()
	var err = config.load(extension_path)

	if err != OK:
		log_error(ErrorType.CONFIGURATION_ERROR,
			"Failed to parse GDExtension configuration: %s" % extension_path,
			{"extension_path": extension_path, "error_code": err},
			"critical",
			"Check the .gdextension file for syntax errors")
		return issues + 1

	# Get the base directory
	var base_dir = extension_path.get_base_dir()

	# Check entry symbol
	if not config.has_section_key("configuration", "entry_symbol"):
		log_error(ErrorType.CONFIGURATION_ERROR,
			"Missing entry_symbol in configuration",
			{"extension_path": extension_path},
			"critical",
			"Add 'entry_symbol' to the [configuration] section")
		issues += 1

	# Check compatibility version
	if config.has_section_key("configuration", "compatibility_minimum"):
		var min_version = config.get_value("configuration", "compatibility_minimum")
		var current_version = Engine.get_version_info()
		# Basic version check (could be more sophisticated)
		if str(current_version.major) + "." + str(current_version.minor) < str(min_version):
			log_error(ErrorType.WRONG_GODOT_VERSION,
				"GDExtension requires Godot %s, but running %s.%s" % [min_version, current_version.major, current_version.minor],
				{"extension_path": extension_path, "required": min_version, "current": "%s.%s" % [current_version.major, current_version.minor]},
				"warning",
				"Upgrade Godot to version %s or higher" % min_version)
			issues += 1

	# Check if libraries exist for current platform
	if config.has_section("libraries"):
		var platform_key = get_platform_key()
		var found_library = false
		var library_path = ""

		# Try to find a matching library for current platform
		for key in config.get_section_keys("libraries"):
			if platform_key in key:
				found_library = true
				library_path = config.get_value("libraries", key)
				break

		if not found_library:
			log_error(ErrorType.PLATFORM_MISMATCH,
				"No library defined for platform: %s" % platform_key,
				{"extension_path": extension_path, "platform": platform_key},
				"critical",
				"Build or obtain the library for your platform (%s)" % platform_key)
			issues += 1
		elif library_path != "":
			# Check if the library file actually exists
			var full_library_path = base_dir + "/" + library_path
			if not FileAccess.file_exists(full_library_path):
				log_error(ErrorType.LIBRARY_NOT_FOUND,
					"Dynamic library file not found: %s" % library_path,
					{"extension_path": extension_path, "library_path": full_library_path, "platform": platform_key},
					"critical",
					"Build the GDExtension library or check if it's excluded by .gitignore. Run the build process for the extension.")
				issues += 1

	return issues

## Get current platform key
func get_platform_key() -> String:
	var os_name = OS.get_name().to_lower()

	if "windows" in os_name:
		return "windows"
	elif "linux" in os_name or "bsd" in os_name:
		return "linux"
	elif "macos" in os_name or "osx" in os_name:
		return "macos"
	elif "android" in os_name:
		return "android"
	elif "ios" in os_name:
		return "ios"
	else:
		return "unknown"

## Scan for nested project.godot files
func scan_for_nested_projects() -> int:
	var issues = 0
	var addons_dir = "res://addons"

	if DirAccess.dir_exists_absolute(addons_dir):
		var nested_projects = find_nested_projects(addons_dir)

		for project_path in nested_projects:
			log_error(ErrorType.NESTED_PROJECT_WARNING,
				"Detected nested project.godot at: %s" % project_path,
				{"project_path": project_path},
				"warning",
				"Rename the file to project.godot.disabled to prevent conflicts")
			issues += 1

	return issues

## Find nested project.godot files
func find_nested_projects(dir_path: String) -> Array[String]:
	var nested: Array[String] = []
	var dir = DirAccess.open(dir_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			var full_path = dir_path + "/" + file_name

			if dir.current_is_dir():
				if file_name != "." and file_name != "..":
					# Check for project.godot in subdirectory
					if FileAccess.file_exists(full_path + "/project.godot"):
						# Don't report the root project
						if full_path != "res://":
							nested.append(full_path + "/project.godot")
					# Recurse into subdirectories
					nested.append_array(find_nested_projects(full_path))

			file_name = dir.get_next()

		dir.list_dir_end()

	return nested

## Check for permission issues
func scan_for_permission_issues() -> int:
	var issues = 0

	# Check if we can write to user directory
	var test_file = "user://permission_test.tmp"
	var file = FileAccess.open(test_file, FileAccess.WRITE)

	if not file:
		log_error(ErrorType.PERMISSION_ERROR,
			"Cannot write to user:// directory",
			{"path": test_file},
			"critical",
			"Check file system permissions for the user data directory")
		issues += 1
	else:
		file.close()
		DirAccess.remove_absolute(test_file)

	return issues

## Main logging function
func log_error(type: ErrorType, message: String, context: Dictionary = {}, severity: String = "critical", suggested_fix: String = "") -> void:
	# Create error object
	var error = GDExtensionError.new(type, message, context, severity, suggested_fix)

	# Store error
	errors.append(error)
	error_count_by_type[type] += 1

	# Limit storage
	if errors.size() > max_errors:
		errors.pop_front()

	# Print to console
	print_error_to_console(error)

	# Emit signals
	error_logged.emit(error)
	if severity == "critical":
		critical_error_detected.emit(error)

	# Save to file
	save_latest_error_to_file(error)

## Specialized logging functions
func log_library_not_found(library_path: String, extension_path: String) -> void:
	log_error(ErrorType.LIBRARY_NOT_FOUND,
		"Dynamic library not found: %s" % library_path,
		{"library_path": library_path, "extension_path": extension_path},
		"critical",
		"Build the extension or download precompiled binaries")

func log_plugin_load_failed(plugin_name: String, reason: String = "") -> void:
	log_error(ErrorType.PLUGIN_LOAD_FAILED,
		"Plugin failed to load: %s" % plugin_name,
		{"plugin_name": plugin_name, "reason": reason},
		"critical",
		"Check plugin dependencies and configuration")

func log_missing_dependency(dependency_name: String, required_by: String) -> void:
	log_error(ErrorType.MISSING_DEPENDENCIES,
		"Missing dependency: %s (required by %s)" % [dependency_name, required_by],
		{"dependency": dependency_name, "required_by": required_by},
		"critical",
		"Install the missing dependency")

## Query functions
func get_errors_by_type(type: ErrorType) -> Array[GDExtensionError]:
	var filtered: Array[GDExtensionError] = []
	for error in errors:
		if error.error_type == type:
			filtered.append(error)
	return filtered

func get_errors_by_severity(severity: String) -> Array[GDExtensionError]:
	var filtered: Array[GDExtensionError] = []
	for error in errors:
		if error.severity == severity:
			filtered.append(error)
	return filtered

func get_recent_errors(count: int = 10) -> Array[GDExtensionError]:
	var start_idx = max(0, errors.size() - count)
	return errors.slice(start_idx)

func get_error_count() -> int:
	return errors.size()

func get_critical_error_count() -> int:
	return get_errors_by_severity("critical").size()

func has_errors() -> bool:
	return errors.size() > 0

func has_critical_errors() -> bool:
	return get_critical_error_count() > 0

## Summary and reporting
func get_error_summary() -> String:
	if errors.is_empty():
		return "✓ No GDExtension errors detected"

	var summary = "📊 GDExtension Error Summary\n"
	summary += repeat_string("=", 50) + "\n"
	summary += "Total Errors: %d (%d critical, %d warnings)\n\n" % [
		errors.size(),
		get_critical_error_count(),
		get_errors_by_severity("warning").size()
	]

	summary += "Errors by Type:\n"
	for type in ErrorType.values():
		var count = error_count_by_type[type]
		if count > 0:
			summary += "  • %s: %d\n" % [ErrorType.keys()[type], count]

	summary += "\nRecent Errors (last 5):\n"
	var recent = get_recent_errors(5)
	for error in recent:
		summary += "\n" + str(error) + "\n"

	return summary

func get_detailed_report() -> String:
	var report = "📋 Detailed GDExtension Error Report\n"
	report += repeat_string("=", 70) + "\n"
	report += "Generated: %s\n" % Time.get_datetime_string_from_system()
	report += "Platform: %s\n" % get_platform_key()
	report += "Godot Version: %s\n" % Engine.get_version_info().string
	report += "Total Errors: %d\n" % errors.size()
	report += repeat_string("=", 70) + "\n\n"

	for i in errors.size():
		report += "Error #%d:\n" % (i + 1)
		report += str(errors[i]) + "\n"
		report += repeat_string("-", 70) + "\n\n"

	return report

## File operations
func save_latest_error_to_file(error: GDExtensionError) -> void:
	var file = FileAccess.open(error_log_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		file.store_line(str(error))
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

func export_errors_as_json(file_path: String = "user://gdextension_errors.json") -> bool:
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

func clear_errors() -> void:
	errors.clear()
	for type in ErrorType.values():
		error_count_by_type[type] = 0
	print("✓ All GDExtension errors cleared")

func clear_log_file() -> void:
	if FileAccess.file_exists(error_log_path):
		DirAccess.remove_absolute(error_log_path)
		print("✓ Error log file cleared")

## Console output
func print_error_to_console(error: GDExtensionError) -> void:
	var error_type_name = ErrorType.keys()[error.error_type]
	var icon = get_error_icon(error.error_type)

	var color = "red" if error.severity == "critical" else "yellow"

	print_rich("[color=%s]%s GDEXTENSION ERROR [%s][/color]" % [color, icon, error_type_name])
	print_rich("[color=yellow]Message:[/color] %s" % error.message)
	if not error.context.is_empty():
		print_rich("[color=cyan]Context:[/color] %s" % JSON.stringify(error.context))
	if error.suggested_fix != "":
		print_rich("[color=green]💡 Suggested Fix:[/color] %s" % error.suggested_fix)

func get_error_icon(type: ErrorType) -> String:
	match type:
		ErrorType.LIBRARY_NOT_FOUND: return "📚❌"
		ErrorType.GDEXTENSION_NOT_FOUND: return "📄❌"
		ErrorType.CONFIGURATION_ERROR: return "⚙️❌"
		ErrorType.SYMBOL_NOT_FOUND: return "🔣❌"
		ErrorType.WRONG_GODOT_VERSION: return "🔢❌"
		ErrorType.PLATFORM_MISMATCH: return "💻❌"
		ErrorType.NESTED_PROJECT_WARNING: return "⚠️"
		ErrorType.PLUGIN_LOAD_FAILED: return "🔌❌"
		ErrorType.MISSING_DEPENDENCIES: return "📦❌"
		ErrorType.PERMISSION_ERROR: return "🔒❌"
		_: return "❓"

## Debug functions
func print_summary() -> void:
	print(get_error_summary())

func print_all_errors() -> void:
	print(get_detailed_report())

## Add extension to monitoring
func add_monitored_extension(extension_path: String) -> void:
	if not extension_path in monitored_extensions:
		monitored_extensions.append(extension_path)
		print("✓ Added %s to monitoring" % extension_path)

## Remove extension from monitoring
func remove_monitored_extension(extension_path: String) -> void:
	monitored_extensions.erase(extension_path)
	print("✓ Removed %s from monitoring" % extension_path)

## Hotkey handler
func handle_debug_input(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F8:  # Rescan for issues
				scan_for_issues()
				return true
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
