extends Control

var player1_character = -1
var player2_character = -1

# Background debugger variables
var background_debug_panel: PanelContainer = null
var background_debug_visible: bool = false
var current_background_node: Control = null

func _ready():
	# Load random background
	load_random_background()

	# Apply anime font theme to all UI elements
	ThemeManager.apply_theme_to_container(self, true)

	# Load character previews on buttons
	load_character_previews()

	update_start_button()

	# Create background debugger
	create_background_debugger()

func load_random_background():
	"""
	Loads a random background (image or video) from the character selection backgrounds folder
	and applies it to cover the entire screen. The background is placed behind all other elements.
	Supports static images (PNG, JPG) and dynamic videos (WebM, OGV).
	"""
	var backgrounds_path = "res://assets/backgrounds_character_selection/"
	var background_files = []

	# Get all files in the backgrounds directory
	var dir = DirAccess.open(backgrounds_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Check if it's a valid file (not a directory or hidden file)
			if not dir.current_is_dir() and not file_name.begins_with(".") and not file_name.ends_with(".md"):
				# Check for valid image and video extensions
				# Note: Only .ogv (Ogg Theora) is supported natively by Godot for videos
				# .webm and .mp4 require additional codec support not available by default
				if (file_name.ends_with(".png") or file_name.ends_with(".jpg") or
					file_name.ends_with(".jpeg") or file_name.ends_with(".ogv")):
					background_files.append(backgrounds_path + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

	# If no backgrounds found, print warning and return
	if background_files.size() == 0:
		print("Warning: No background files found in ", backgrounds_path)
		return

	# Select a random background
	var random_index = randi() % background_files.size()
	var selected_background = background_files[random_index]
	print("Selected random background: ", selected_background)

	# Determine if it's a video or image
	# Godot natively supports .ogv (Ogg Theora) format for videos
	# .webm and .mp4 are not supported without additional codec support
	var is_video = selected_background.ends_with(".ogv")

	# Load and display the background
	if FileAccess.file_exists(selected_background):
		if is_video:
			# Load video background
			var video_stream = load(selected_background)
			if video_stream:
				var video_player = VideoStreamPlayer.new()
				video_player.stream = video_stream
				video_player.autoplay = true
				video_player.loop = true
				video_player.expand = true
				video_player.anchor_right = 1.0
				video_player.anchor_bottom = 1.0
				video_player.z_index = -100  # Place far behind everything
				video_player.mouse_filter = Control.MOUSE_FILTER_IGNORE

				# Store reference for debugger
				current_background_node = video_player

				# Add to the root control node (self)
				add_child(video_player)
				move_child(video_player, 0)  # Move to the very back
				print("Random video background loaded successfully")
			else:
				print("Error: Could not load video stream: ", selected_background)
		else:
			# Load image background
			var texture = load(selected_background)
			if texture:
				# Create TextureRect to cover the entire screen
				var background_rect = TextureRect.new()
				background_rect.texture = texture
				background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				background_rect.anchor_right = 1.0
				background_rect.anchor_bottom = 1.0
				background_rect.z_index = -100  # Place far behind everything
				background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

				# Store reference for debugger
				current_background_node = background_rect

				# Add to the root control node (self)
				add_child(background_rect)
				move_child(background_rect, 0)  # Move to the very back
				print("Random image background loaded successfully")
			else:
				print("Error: Could not load background texture: ", selected_background)
	else:
		print("Error: Background file does not exist: ", selected_background)

func load_character_previews():
	"""
	Loads character preview images/animations onto the character selection buttons.
	"""
	# Player 1 character buttons
	load_character_preview_on_button($VBoxContainer/Player1Section/Player1CharacterPanel/MarginContainer/HBoxContainer/Character1Button, 0)
	load_character_preview_on_button($VBoxContainer/Player1Section/Player1CharacterPanel/MarginContainer/HBoxContainer/Character2Button, 1)
	load_character_preview_on_button($VBoxContainer/Player1Section/Player1CharacterPanel/MarginContainer/HBoxContainer/Character3Button, 2)
	load_character_preview_on_button($VBoxContainer/Player1Section/Player1CharacterPanel/MarginContainer/HBoxContainer/Character4Button, 3)

	# Player 2 character buttons
	load_character_preview_on_button($VBoxContainer/Player2Section/Player2CharacterPanel/MarginContainer/HBoxContainer/Character1Button, 0)
	load_character_preview_on_button($VBoxContainer/Player2Section/Player2CharacterPanel/MarginContainer/HBoxContainer/Character2Button, 1)
	load_character_preview_on_button($VBoxContainer/Player2Section/Player2CharacterPanel/MarginContainer/HBoxContainer/Character3Button, 2)
	load_character_preview_on_button($VBoxContainer/Player2Section/Player2CharacterPanel/MarginContainer/HBoxContainer/Character4Button, 3)

func load_character_preview_on_button(button: Button, character_id: int):
	"""
	Loads and displays a character preview (video, image, or Live2D) on a button.

	Args:
		button: The button to add the preview to
		character_id: The character ID (0-3)
	"""
	var char_path = "res://assets/characters/character_" + str(character_id + 1) + "/"
	print("\n===== LOADING CHARACTER ", character_id + 1, " PREVIEW =====")
	print("Character path: ", char_path)

	# Special handling for Character 4 (Live2D)
	if character_id == 3:
		load_live2d_preview_on_button(button, char_path)
		return

	# Find character background image (support multiple formats)
	var bg_path = ""
	var supported_bg_extensions = [".png", ".jpg", ".jpeg", ".webp"]
	print("Searching for background image...")
	for ext in supported_bg_extensions:
		var test_path = char_path + "backgrounds/character_background" + ext
		print("  Checking: ", test_path)
		if FileAccess.file_exists(test_path):
			bg_path = test_path
			print("  ✓ FOUND: ", test_path)
			break

	if bg_path == "":
		print("  ✗ No background image found")

	# Create a container for the preview that doesn't interfere with button functionality
	var preview_container = Control.new()
	preview_container.name = "PreviewContainer"
	preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let clicks pass through to button
	preview_container.anchor_right = 1.0
	preview_container.anchor_bottom = 1.0
	preview_container.z_index = -1  # Place behind button text

	# Try to load video animation first
	# Godot natively supports .ogv (Ogg Theora) format
	# .webm and .mp4 are not supported without additional codec support
	var supported_video_extensions = [".ogv"]
	var video_loaded = false

	print("\nSearching for video animation...")
	for ext in supported_video_extensions:
		var video_path = char_path + "animations/character_idle" + ext
		print("  Checking: ", video_path)
		if FileAccess.file_exists(video_path):
			print("  ✓ FOUND: ", video_path)
			var video_stream = load(video_path)
			if video_stream:
				var video_player = VideoStreamPlayer.new()
				video_player.stream = video_stream
				video_player.autoplay = true
				video_player.loop = true
				video_player.expand = true
				video_player.anchor_right = 1.0
				video_player.anchor_bottom = 1.0
				video_player.mouse_filter = Control.MOUSE_FILTER_IGNORE
				preview_container.add_child(video_player)
				button.add_child(preview_container)
				button.move_child(preview_container, 0)  # Move to back
				print("  ✓ LOADED: Video preview (", ext, ")")
				video_loaded = true
				break
			else:
				print("  ✗ ERROR: Could not load video stream")

	# Note: GIF animations are not supported by Godot natively
	# Skipping GIF loading - use .ogv video format instead for animations

	# Fallback to background image if no video/animation was loaded
	if not video_loaded:
		print("\nFalling back to background image...")
		if bg_path != "" and FileAccess.file_exists(bg_path):
			print("  Using background: ", bg_path)
			var texture = load(bg_path)
			if texture:
				var texture_rect = TextureRect.new()
				texture_rect.texture = texture
				texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				texture_rect.anchor_right = 1.0
				texture_rect.anchor_bottom = 1.0
				texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
				preview_container.add_child(texture_rect)
				button.add_child(preview_container)
				button.move_child(preview_container, 0)  # Move to back
				print("  ✓ LOADED: Background image preview")
			else:
				print("  ✗ ERROR: Could not load background texture")
		else:
			print("  ✗ ERROR: No background image available")
			print("\n⚠ WARNING: No preview found for character ", character_id + 1)
			print("  Searched for:")
			print("    - animations/character_idle.ogv")
			print("    - backgrounds/character_background.[png|jpg|jpeg|webp]")

	print("===== END CHARACTER ", character_id + 1, " PREVIEW =====\n")

func _on_player1_character_selected(character_id: int):
	player1_character = character_id
	# Store in game state
	GameState.player1_character = character_id
	print("Player 1 selected character: ", character_id)
	update_start_button()
	# Visual feedback could be added here (highlight selected character)

func _on_player2_character_selected(character_id: int):
	player2_character = character_id
	# Store in game state
	GameState.player2_character = character_id
	print("Player 2 selected character: ", character_id)
	update_start_button()
	# Visual feedback could be added here (highlight selected character)

func update_start_button():
	var start_button = $VBoxContainer/ButtonContainer/StartButton
	start_button.disabled = (player1_character == -1 or player2_character == -1)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/login_page.tscn")

func _on_start_button_pressed():
	if player1_character != -1 and player2_character != -1:
		get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")

# ============================================================================
# CHARACTER BACKGROUND DEBUGGER FUNCTIONS
# ============================================================================

func create_background_debugger():
	"""
	Creates a floating debug panel for character selection page background.
	This panel allows you to:
	- Adjust background scale
	- Adjust background opacity
	- Adjust background position
	- Toggle visibility

	Press 'B' key to toggle the debug panel visibility.
	"""
	# Create main panel container
	background_debug_panel = PanelContainer.new()
	background_debug_panel.name = "BackgroundDebugPanel"
	background_debug_panel.position = Vector2(10, 100)
	background_debug_panel.custom_minimum_size = Vector2(350, 350)
	background_debug_panel.visible = false  # Hidden by default
	background_debug_panel.z_index = 1000  # Always on top

	# Create a stylebox for the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1.0, 0.6, 0.3, 1.0)
	background_debug_panel.add_theme_stylebox_override("panel", panel_style)

	# Create main VBoxContainer for content
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	background_debug_panel.add_child(vbox)

	# Add margin container for padding
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	vbox.add_child(margin)

	# Create content container
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 15)
	margin.add_child(content)

	# Title
	var title = Label.new()
	title.text = "CHARACTER BACKGROUND DEBUGGER"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)

	# Separator
	var sep1 = HSeparator.new()
	content.add_child(sep1)

	# Instructions
	var instructions = Label.new()
	instructions.text = "Press 'B' to toggle this panel\nAdjust page background below:"
	instructions.add_theme_font_size_override("font_size", 12)
	instructions.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	content.add_child(instructions)

	# Background Scale
	var scale_label = Label.new()
	scale_label.text = "Scale: 1.0x"
	scale_label.add_theme_font_size_override("font_size", 11)
	content.add_child(scale_label)

	var scale_slider = HSlider.new()
	scale_slider.min_value = 0.5
	scale_slider.max_value = 2.0
	scale_slider.step = 0.1
	scale_slider.value = 1.0
	scale_slider.custom_minimum_size = Vector2(300, 20)
	content.add_child(scale_slider)

	# Background Opacity
	var opacity_label = Label.new()
	opacity_label.text = "Opacity: 100%"
	opacity_label.add_theme_font_size_override("font_size", 11)
	content.add_child(opacity_label)

	var opacity_slider = HSlider.new()
	opacity_slider.min_value = 0.0
	opacity_slider.max_value = 1.0
	opacity_slider.step = 0.05
	opacity_slider.value = 1.0
	opacity_slider.custom_minimum_size = Vector2(300, 20)
	content.add_child(opacity_slider)

	# Background Position X
	var pos_x_label = Label.new()
	pos_x_label.text = "Position X: 0"
	pos_x_label.add_theme_font_size_override("font_size", 11)
	content.add_child(pos_x_label)

	var pos_x_slider = HSlider.new()
	pos_x_slider.min_value = -500
	pos_x_slider.max_value = 500
	pos_x_slider.step = 10
	pos_x_slider.value = 0
	pos_x_slider.custom_minimum_size = Vector2(300, 20)
	content.add_child(pos_x_slider)

	# Background Position Y
	var pos_y_label = Label.new()
	pos_y_label.text = "Position Y: 0"
	pos_y_label.add_theme_font_size_override("font_size", 11)
	content.add_child(pos_y_label)

	var pos_y_slider = HSlider.new()
	pos_y_slider.min_value = -500
	pos_y_slider.max_value = 500
	pos_y_slider.step = 10
	pos_y_slider.value = 0
	pos_y_slider.custom_minimum_size = Vector2(300, 20)
	content.add_child(pos_y_slider)

	# Visibility Toggle
	var visibility = CheckButton.new()
	visibility.text = "Visible"
	visibility.button_pressed = true
	content.add_child(visibility)

	# Connect signals
	scale_slider.value_changed.connect(func(value):
		scale_label.text = "Scale: %.1fx" % value
		if current_background_node:
			current_background_node.scale = Vector2(value, value)
	)

	opacity_slider.value_changed.connect(func(value):
		opacity_label.text = "Opacity: %d%%" % int(value * 100)
		if current_background_node:
			current_background_node.modulate.a = value
	)

	pos_x_slider.value_changed.connect(func(value):
		pos_x_label.text = "Position X: %d" % int(value)
		if current_background_node:
			current_background_node.position.x = value
	)

	pos_y_slider.value_changed.connect(func(value):
		pos_y_label.text = "Position Y: %d" % int(value)
		if current_background_node:
			current_background_node.position.y = value
	)

	visibility.toggled.connect(func(pressed):
		if current_background_node:
			current_background_node.visible = pressed
	)

	# Add panel to scene
	add_child(background_debug_panel)

	print("Character Background Debugger created. Press 'B' to toggle.")

func _unhandled_key_input(event):
	"""
	Handles keyboard shortcuts for the debug panel.
	Press 'B' to toggle the character background debugger.
	"""
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			toggle_background_debugger()

func toggle_background_debugger():
	"""
	Toggles the visibility of the character background debug panel.
	"""
	if background_debug_panel:
		background_debug_visible = !background_debug_visible
		background_debug_panel.visible = background_debug_visible
		if background_debug_visible:
			print("Character Background Debugger: VISIBLE")
		else:
			print("Character Background Debugger: HIDDEN")

func load_live2d_preview_on_button(button: Button, char_path: String):
	"""
	Loads and displays a Live2D character preview on a button.
	Falls back to texture preview if GDCubism is not available.

	Args:
		button: The button to add the preview to
		char_path: Path to the character folder
	"""
	print("Loading Live2D preview for Character 4...")

	# Create a container for the preview
	var preview_container = Control.new()
	preview_container.name = "PreviewContainer"
	preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_container.anchor_right = 1.0
	preview_container.anchor_bottom = 1.0
	preview_container.z_index = -1

	# Check if GDCubism is available
	var model_path = char_path + "Scyka.model3.json"

	if ClassDB.class_exists("GDCubismUserModel") and FileAccess.file_exists(model_path):
		print("  GDCubism is available, loading Live2D model...")
		# Create Live2D model instance
		var live2d_model = ClassDB.instantiate("GDCubismUserModel")

		if live2d_model:
			# Configure the Live2D model
			live2d_model.assets = model_path
			# Try to set auto_scale if available
			if "auto_scale" in live2d_model:
				live2d_model.auto_scale = 2  # AUTO_SCALE_FORCE_INSIDE
			live2d_model.mouse_filter = Control.MOUSE_FILTER_IGNORE
			live2d_model.anchor_right = 1.0
			live2d_model.anchor_bottom = 1.0

			# Start with idle animation if method is available
			if live2d_model.has_method("start_motion"):
				live2d_model.start_motion("Idle", 0, 2, true)  # PRIORITY_IDLE = 2

			preview_container.add_child(live2d_model)
			button.add_child(preview_container)
			button.move_child(preview_container, 0)
			print("  ✓ LOADED: Live2D model preview")
			return
		else:
			print("  ✗ ERROR: Could not instantiate GDCubismUserModel")
	else:
		if not ClassDB.class_exists("GDCubismUserModel"):
			print("  ⚠ WARNING: GDCubism plugin not loaded")
			print("    See LIVE2D_SETUP.md for installation instructions")
		else:
			print("  ✗ ERROR: Model file not found: ", model_path)

	# Fallback to texture preview
	print("  Falling back to texture preview...")
	var texture_path = char_path + "Scyka.4096/texture_00.png"

	if FileAccess.file_exists(texture_path):
		var texture = load(texture_path)
		if texture:
			var texture_rect = TextureRect.new()
			texture_rect.texture = texture
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			texture_rect.anchor_right = 1.0
			texture_rect.anchor_bottom = 1.0
			texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			preview_container.add_child(texture_rect)
			button.add_child(preview_container)
			button.move_child(preview_container, 0)
			print("  ✓ LOADED: Texture preview")
		else:
			print("  ✗ ERROR: Could not load texture")
	else:
		print("  ✗ ERROR: Texture not found: ", texture_path)

	print("===== END CHARACTER 4 PREVIEW =====\n")
