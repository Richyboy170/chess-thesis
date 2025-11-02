extends Node
## Live2D Character Debugger
##
## This script provides comprehensive debugging for Live2D characters in the Main Game.
## It checks plugin availability, model files, and provides detailed error reporting.

class_name Live2DDebugger

## Error types for Live2D debugging
enum ErrorType {
	PLUGIN_NOT_LOADED,      ## GDCubism plugin is not enabled
	MODEL_FILE_MISSING,     ## .model3.json file not found
	MODEL_LOAD_FAILED,      ## Model file exists but failed to load
	TEXTURE_MISSING,        ## Required texture files missing
	INVALID_CHARACTER_ID,   ## Character ID out of range
	INSTANTIATION_FAILED    ## Failed to create GDCubismUserModel instance
}

## Dynamically detected character information
static var _live2d_characters: Dictionary = {}
static var _characters_initialized: bool = false

## Auto-detect available Live2D characters by scanning assets/characters/ folder
static func _initialize_characters():
	if _characters_initialized:
		return

	_characters_initialized = true
	_live2d_characters.clear()

	var characters_dir = "res://assets/characters/"
	var dir = DirAccess.open(characters_dir)

	if not dir:
		push_error("Live2DDebugger: Failed to open characters directory: " + characters_dir)
		return

	dir.list_dir_begin()
	var folder_name = dir.get_next()

	while folder_name != "":
		if dir.current_is_dir() and folder_name.begins_with("character_"):
			# Extract character ID from folder name (e.g., "character_4" -> 4)
			var id_str = folder_name.trim_prefix("character_")
			if id_str.is_valid_int():
				var char_id = id_str.to_int()
				var char_path = characters_dir + folder_name + "/"

				# Look for .model3.json file to identify Live2D character
				var char_dir = DirAccess.open(char_path)
				if char_dir:
					char_dir.list_dir_begin()
					var file = char_dir.get_next()
					var model_file = ""
					var texture_dir = ""

					while file != "":
						if file.ends_with(".model3.json"):
							model_file = file.trim_suffix(".model3.json")
						elif char_dir.current_is_dir() and (file.contains(".") or file.contains("texture") or file.contains(id_str)):
							# Look for texture directory (usually has resolution in name like "Scyka.4096")
							if file.begins_with(model_file) or file.contains("texture") or file.contains("."):
								texture_dir = file
						file = char_dir.get_next()

					char_dir.list_dir_end()

					# If we found a model file, this is a Live2D character
					if model_file != "":
						_live2d_characters[char_id] = {
							"name": model_file,
							"texture_dir": texture_dir if texture_dir != "" else model_file
						}
						print("Live2DDebugger: Found Live2D character %d (%s) with texture dir: %s" % [char_id, model_file, texture_dir])

		folder_name = dir.get_next()

	dir.list_dir_end()

	print("Live2DDebugger: Detected %d Live2D characters" % _live2d_characters.size())

## Debug report structure
class DebugReport:
	var character_id: int
	var character_name: String
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var info: Array[String] = []
	var success: bool = true

	func add_error(message: String):
		errors.append(message)
		success = false

	func add_warning(message: String):
		warnings.append(message)

	func add_info(message: String):
		info.append(message)

	func _to_string() -> String:
		var output = "\n"
		output += "═".repeat(80) + "\n"
		output += "  LIVE2D CHARACTER DEBUG REPORT\n"
		output += "═".repeat(80) + "\n\n"
		output += "Character: %s (ID: %d)\n" % [character_name, character_id]
		output += "Status: %s\n" % ("✓ SUCCESS" if success else "✗ FAILED")
		output += "─".repeat(80) + "\n\n"

		if info.size() > 0:
			output += "ℹ INFO:\n"
			for msg in info:
				output += "  • %s\n" % msg
			output += "\n"

		if warnings.size() > 0:
			output += "⚠ WARNINGS:\n"
			for msg in warnings:
				output += "  • %s\n" % msg
			output += "\n"

		if errors.size() > 0:
			output += "✗ ERRORS:\n"
			for msg in errors:
				output += "  • %s\n" % msg
			output += "\n"

		output += "═".repeat(80) + "\n"
		return output

## Check if a character ID is a Live2D character
static func is_live2d_character(character_id: int) -> bool:
	_initialize_characters()
	return character_id in _live2d_characters

## Get character information
static func get_character_info(character_id: int) -> Dictionary:
	_initialize_characters()
	if character_id in _live2d_characters:
		return _live2d_characters[character_id]
	return {}

## Get all available Live2D character IDs
static func get_available_characters() -> Array:
	_initialize_characters()
	var ids = _live2d_characters.keys()
	ids.sort()
	return ids

## Check if GDCubism plugin is available
static func check_plugin_available() -> bool:
	return ClassDB.class_exists("GDCubismUserModel")

## Get the path to a character's model file
static func get_model_path(character_id: int) -> String:
	var char_info = get_character_info(character_id)
	if char_info.is_empty():
		return ""

	var char_path = "res://assets/characters/character_%d/" % character_id
	return char_path + char_info["name"] + ".model3.json"

## Get the path to a character's texture directory
static func get_texture_dir(character_id: int) -> String:
	var char_info = get_character_info(character_id)
	if char_info.is_empty():
		return ""

	var char_path = "res://assets/characters/character_%d/" % character_id
	return char_path + char_info["texture_dir"] + "/"

## Comprehensive debug check for a Live2D character
static func debug_character(character_id: int) -> DebugReport:
	var report = DebugReport.new()
	report.character_id = character_id

	# Check if character ID is valid
	if not is_live2d_character(character_id):
		report.character_name = "Unknown"
		report.add_error("Invalid character ID: %d (not a Live2D character)" % character_id)
		return report

	var char_info = get_character_info(character_id)
	report.character_name = char_info["name"]
	report.add_info("Character folder: res://assets/characters/character_%d/" % character_id)

	# Step 1: Check if GDCubism plugin is loaded
	report.add_info("Checking GDCubism plugin availability...")
	if not check_plugin_available():
		report.add_error("GDCubism plugin is NOT loaded!")
		report.add_error("The GDCubismUserModel class is not available")
		report.add_info("Solution: Enable the GDCubism plugin in Project Settings > Plugins")
		report.add_info("See LIVE2D_SETUP.md for installation instructions")
		return report
	else:
		report.add_info("✓ GDCubism plugin is loaded (GDCubismUserModel class available)")

	# Step 2: Check if model file exists
	var model_path = get_model_path(character_id)
	report.add_info("Checking model file: %s" % model_path)

	if not FileAccess.file_exists(model_path):
		report.add_error("Model file NOT FOUND: %s" % model_path)
		report.add_info("Expected file: %s.model3.json" % char_info["name"])
		return report
	else:
		report.add_info("✓ Model file exists")

	# Step 3: Try to load the model file
	report.add_info("Attempting to load model file...")
	var model_resource = load(model_path)
	if model_resource == null:
		report.add_error("Failed to load model file as resource")
		report.add_warning("The file exists but Godot cannot load it")
		return report
	else:
		report.add_info("✓ Model file can be loaded as resource")

	# Step 4: Check texture files
	var texture_dir = get_texture_dir(character_id)
	report.add_info("Checking texture directory: %s" % texture_dir)

	if DirAccess.dir_exists_absolute(texture_dir):
		report.add_info("✓ Texture directory exists")

		# Check for texture_00.png (primary texture)
		var texture_00_path = texture_dir + "texture_00.png"
		if FileAccess.file_exists(texture_00_path):
			report.add_info("✓ Primary texture found: texture_00.png")
		else:
			report.add_warning("Primary texture not found: texture_00.png")

		# List all textures
		var dir = DirAccess.open(texture_dir)
		if dir:
			var texture_count = 0
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".png"):
					texture_count += 1
				file_name = dir.get_next()
			dir.list_dir_end()
			report.add_info("Found %d texture file(s) in directory" % texture_count)
	else:
		report.add_error("Texture directory NOT FOUND: %s" % texture_dir)
		return report

	# Step 5: Try to instantiate the model
	report.add_info("Attempting to instantiate GDCubismUserModel...")
	var live2d_model = ClassDB.instantiate("GDCubismUserModel")

	if live2d_model == null:
		report.add_error("Failed to instantiate GDCubismUserModel")
		return report
	else:
		report.add_info("✓ Successfully instantiated GDCubismUserModel")

	# Step 6: Try to set the assets property
	report.add_info("Attempting to assign model assets...")
	live2d_model.assets = model_path
	report.add_info("✓ Model assets assigned")

	# Clean up the test instance
	live2d_model.queue_free()

	report.add_info("\n✓✓✓ All checks passed! Character should load correctly. ✓✓✓")

	return report

## Quick check for all Live2D characters
static func debug_all_characters() -> String:
	_initialize_characters()

	var output = "\n"
	output += "╔" + "═".repeat(78) + "╗\n"
	output += "║" + " ".repeat(20) + "LIVE2D CHARACTERS DEBUG SUMMARY" + " ".repeat(26) + "║\n"
	output += "╚" + "═".repeat(78) + "╝\n\n"

	# Check plugin first
	if not check_plugin_available():
		output += "✗ CRITICAL: GDCubism plugin is NOT loaded!\n"
		output += "  The GDCubismUserModel class is not available.\n"
		output += "  Enable the plugin in: Project Settings > Plugins\n"
		output += "  See LIVE2D_SETUP.md for setup instructions.\n\n"
		return output
	else:
		output += "✓ GDCubism plugin is loaded\n\n"

	if _live2d_characters.is_empty():
		output += "⚠ No Live2D characters detected in assets/characters/\n"
		output += "  Expected: character_N folders with .model3.json files\n\n"
		return output

	# Check each character
	var char_ids = _live2d_characters.keys()
	char_ids.sort()

	for char_id in char_ids:
		var char_info = _live2d_characters[char_id]
		var model_path = get_model_path(char_id)
		var status = "✓" if FileAccess.file_exists(model_path) else "✗"

		output += "%s Character %d (%s):\n" % [status, char_id, char_info["name"]]
		output += "    Model: %s\n" % model_path

		if FileAccess.file_exists(model_path):
			output += "    Status: Ready\n"
		else:
			output += "    Status: MODEL FILE MISSING!\n"
		output += "\n"

	return output

## Create a debug UI panel for the main game
static func create_debug_panel(parent_node: Control) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.name = "Live2DDebugPanel"
	panel.position = Vector2(10, 10)
	panel.custom_minimum_size = Vector2(600, 400)
	panel.visible = false
	panel.z_index = 2000

	# Style the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 0.95)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.0, 0.8, 1.0, 1.0)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	panel.add_theme_stylebox_override("panel", style)

	# Create content
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "LIVE2D CHARACTER DEBUGGER"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.0, 0.8, 1.0, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Instructions
	var instructions = Label.new()
	instructions.text = "Press 'L' to toggle this panel\nPress buttons below to debug specific characters"
	instructions.add_theme_font_size_override("font_size", 12)
	instructions.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	vbox.add_child(instructions)

	# Button container
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 10)
	vbox.add_child(button_container)

	# Create debug buttons for each character
	_initialize_characters()
	var char_ids = _live2d_characters.keys()
	char_ids.sort()

	for char_id in char_ids:
		var char_info = _live2d_characters[char_id]
		var btn = Button.new()
		btn.text = "Debug %s" % char_info["name"]
		btn.custom_minimum_size = Vector2(120, 40)
		btn.pressed.connect(func(): print_debug_report(char_id))
		button_container.add_child(btn)

	# Add "Debug All" button
	var debug_all_btn = Button.new()
	debug_all_btn.text = "Debug All"
	debug_all_btn.custom_minimum_size = Vector2(120, 40)
	debug_all_btn.pressed.connect(func(): print(debug_all_characters()))
	button_container.add_child(debug_all_btn)

	# Output area
	var output_label = Label.new()
	output_label.name = "OutputLabel"
	output_label.text = "Click a button above to see debug information in the console."
	output_label.add_theme_font_size_override("font_size", 11)
	output_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	output_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(output_label)

	# Add scroll container for detailed info
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 200)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var info_label = RichTextLabel.new()
	info_label.name = "InfoLabel"
	info_label.bbcode_enabled = true
	info_label.fit_content = true
	info_label.add_theme_font_size_override("normal_font_size", 11)
	info_label.add_theme_color_override("default_color", Color(0.9, 0.9, 0.9, 1.0))
	scroll.add_child(info_label)

	parent_node.add_child(panel)
	return panel

## Print debug report to console
static func print_debug_report(character_id: int):
	var report = debug_character(character_id)
	print(report._to_string())

## Get a detailed status message for in-game display
static func get_status_message(character_id: int) -> String:
	if not is_live2d_character(character_id):
		return "Not a Live2D character"

	if not check_plugin_available():
		return "ERROR: GDCubism plugin not loaded"

	var model_path = get_model_path(character_id)
	if not FileAccess.file_exists(model_path):
		return "ERROR: Model file missing"

	return "Ready (All checks passed)"
