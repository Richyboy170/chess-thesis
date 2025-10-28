extends PanelContainer

## AnimationErrorViewer - Debug UI for viewing animation errors
##
## This is a floating debug panel that displays all animation errors
## captured by the AnimationErrorDetector. Can be toggled with hotkeys.
##
## Usage:
##   1. Add this scene to your game scenes (or add via code)
##   2. Press F9 to toggle visibility
##   3. Press F10 to export errors to file
##   4. Press F11 to clear all errors

@onready var error_list: RichTextLabel = $MarginContainer/VBoxContainer/ScrollContainer/ErrorList
@onready var summary_label: Label = $MarginContainer/VBoxContainer/Header/SummaryLabel
@onready var close_button: Button = $MarginContainer/VBoxContainer/Header/CloseButton
@onready var export_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/ExportButton
@onready var clear_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/ClearButton
@onready var refresh_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/RefreshButton

var is_visible_panel: bool = false

## Helper function to repeat strings
static func repeat_string(s: String, count: int) -> String:
	var result = ""
	for i in count:
		result += s
	return result

func _ready():
	# Connect to error detector signals
	if AnimationErrorDetector:
		AnimationErrorDetector.error_logged.connect(_on_error_logged)
		AnimationErrorDetector.critical_error_count_reached.connect(_on_critical_errors)

	# Connect button signals
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if export_button:
		export_button.pressed.connect(_on_export_pressed)
	if clear_button:
		clear_button.pressed.connect(_on_clear_pressed)
	if refresh_button:
		refresh_button.pressed.connect(_on_refresh_pressed)

	# Initial setup
	hide()
	refresh_display()

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F9:
				toggle_visibility()
			KEY_F10:
				_on_export_pressed()
			KEY_F11:
				_on_clear_pressed()

func toggle_visibility():
	is_visible_panel = not is_visible_panel
	visible = is_visible_panel
	if is_visible_panel:
		refresh_display()

func refresh_display():
	update_summary()
	update_error_list()

func update_summary():
	if not AnimationErrorDetector:
		return

	var error_count = AnimationErrorDetector.get_error_count()
	var has_critical = AnimationErrorDetector.has_critical_errors()

	if error_count == 0:
		summary_label.text = "No animation errors"
		summary_label.add_theme_color_override("font_color", Color.GREEN)
	elif has_critical:
		summary_label.text = "%d errors (CRITICAL)" % error_count
		summary_label.add_theme_color_override("font_color", Color.RED)
	else:
		summary_label.text = "%d errors" % error_count
		summary_label.add_theme_color_override("font_color", Color.YELLOW)

func update_error_list():
	if not AnimationErrorDetector or not error_list:
		return

	error_list.clear()

	if AnimationErrorDetector.get_error_count() == 0:
		error_list.append_text("[color=green]✓ No animation errors detected[/color]\n\n")
		error_list.append_text("All character animations loaded successfully!")
		return

	# Display error summary by type
	error_list.append_text("[b][color=white]Error Summary[/color][/b]\n")
	error_list.append_text(repeat_string("=", 50) + "\n\n")

	# Count by type
	for type in AnimationErrorDetector.ErrorType.values():
		var count = AnimationErrorDetector.get_error_count_by_type(type)
		if count > 0:
			var type_name = AnimationErrorDetector.ErrorType.keys()[type]
			var icon = AnimationErrorDetector.get_error_icon(type)
			error_list.append_text("%s [color=yellow]%s[/color]: %d\n" % [icon, type_name, count])

	error_list.append_text("\n" + repeat_string("=", 50) + "\n\n")

	# Display recent errors (last 10)
	error_list.append_text("[b][color=white]Recent Errors[/color][/b]\n\n")

	var recent_errors = AnimationErrorDetector.get_recent_errors(10)
	for i in recent_errors.size():
		var error = recent_errors[i]
		var type_name = AnimationErrorDetector.ErrorType.keys()[error.error_type]
		var icon = AnimationErrorDetector.get_error_icon(error.error_type)

		error_list.append_text("[b]%s Error #%d[/b]\n" % [icon, i + 1])
		error_list.append_text("[color=gray]%s[/color]\n" % error.timestamp)
		error_list.append_text("[color=yellow]Type:[/color] %s\n" % type_name)
		error_list.append_text("[color=cyan]Message:[/color] %s\n" % error.message)

		if not error.context.is_empty():
			error_list.append_text("[color=cyan]Context:[/color]\n")
			for key in error.context:
				error_list.append_text("  • %s: %s\n" % [key, error.context[key]])

		error_list.append_text("\n" + repeat_string("-", 50) + "\n\n")

	# Show total count
	var total = AnimationErrorDetector.get_error_count()
	if total > 10:
		error_list.append_text("[color=gray][i]Showing 10 of %d total errors[/i][/color]\n" % total)

func _on_error_logged(_error):
	# Automatically refresh when new error is logged
	if is_visible_panel:
		refresh_display()

func _on_critical_errors(count: int):
	# Show panel automatically when critical errors occur
	push_warning("Critical animation error count reached: %d" % count)
	if not is_visible_panel:
		toggle_visibility()

func _on_close_pressed():
	toggle_visibility()

func _on_export_pressed():
	if not AnimationErrorDetector:
		return

	# Export to both text and JSON formats
	var text_success = AnimationErrorDetector.export_errors_to_file()
	var json_success = AnimationErrorDetector.export_errors_as_json()

	if text_success and json_success:
		print("Errors exported successfully:")
		print("  - Text: ", AnimationErrorDetector.error_log_path)
		print("  - JSON: user://animation_errors.json")
		show_notification("Errors exported to:\n%s\nanimation_errors.json" % AnimationErrorDetector.error_log_path)
	else:
		push_error("Failed to export errors")

func _on_clear_pressed():
	if not AnimationErrorDetector:
		return

	AnimationErrorDetector.clear_errors()
	refresh_display()
	show_notification("All errors cleared")

func _on_refresh_pressed():
	refresh_display()
	show_notification("Display refreshed")

func show_notification(message: String):
	# Simple notification - just print for now
	# Could be enhanced with a toast notification system
	print("✓ ", message)

# Helper function to create the viewer programmatically
static func create_viewer():
	var script = load("res://scripts/animation_error_viewer.gd")
	var viewer = script.new()
	viewer.name = "AnimationErrorViewer"

	# Create UI structure
	var margin = MarginContainer.new()
	margin.name = "MarginContainer"
	viewer.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	margin.add_child(vbox)

	# Header
	var header = HBoxContainer.new()
	header.name = "Header"
	vbox.add_child(header)

	var title = Label.new()
	title.text = "Animation Errors"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var summary = Label.new()
	summary.name = "SummaryLabel"
	header.add_child(summary)

	var close = Button.new()
	close.name = "CloseButton"
	close.text = "X"
	header.add_child(close)

	# Error list
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.custom_minimum_size = Vector2(600, 400)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var error_list_label = RichTextLabel.new()
	error_list_label.name = "ErrorList"
	error_list_label.bbcode_enabled = true
	error_list_label.fit_content = true
	scroll.add_child(error_list_label)

	# Buttons
	var button_container = HBoxContainer.new()
	button_container.name = "ButtonContainer"
	vbox.add_child(button_container)

	var refresh = Button.new()
	refresh.name = "RefreshButton"
	refresh.text = "Refresh"
	button_container.add_child(refresh)

	var export = Button.new()
	export.name = "ExportButton"
	export.text = "Export"
	button_container.add_child(export)

	var clear = Button.new()
	clear.name = "ClearButton"
	clear.text = "Clear"
	button_container.add_child(clear)

	# Set position (top-right corner)
	viewer.position = Vector2(100, 100)
	viewer.size = Vector2(650, 500)

	return viewer
