extends Control

var player1_character = -1
var player2_character = -1

func _ready():
	# Load random background
	load_random_background()

	# Apply anime font theme to all UI elements
	ThemeManager.apply_theme_to_container(self, true)

	# Load character previews on buttons
	load_character_previews()

	update_start_button()

func load_random_background():
	"""
	Loads a random background image from the backgrounds folder and applies it
	to cover the entire screen. The background is placed behind all other elements.
	"""
	var backgrounds_path = "res://assets/backgrounds/"
	var background_files = []

	# Get all files in the backgrounds directory
	var dir = DirAccess.open(backgrounds_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Check if it's a valid image file (not a directory or hidden file)
			if not dir.current_is_dir() and not file_name.begins_with(".") and not file_name.ends_with(".md"):
				# Check for valid image extensions
				if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
					background_files.append(backgrounds_path + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

	# If no backgrounds found, print warning and return
	if background_files.size() == 0:
		print("Warning: No background images found in ", backgrounds_path)
		return

	# Select a random background
	var random_index = randi() % background_files.size()
	var selected_background = background_files[random_index]
	print("Selected random background: ", selected_background)

	# Load and display the background
	if FileAccess.file_exists(selected_background):
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

			# Add to the root control node (self)
			add_child(background_rect)
			move_child(background_rect, 0)  # Move to the very back
			print("Random background loaded successfully")
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

	# Player 2 character buttons
	load_character_preview_on_button($VBoxContainer/Player2Section/Player2CharacterPanel/MarginContainer/HBoxContainer/Character1Button, 0)
	load_character_preview_on_button($VBoxContainer/Player2Section/Player2CharacterPanel/MarginContainer/HBoxContainer/Character2Button, 1)
	load_character_preview_on_button($VBoxContainer/Player2Section/Player2CharacterPanel/MarginContainer/HBoxContainer/Character3Button, 2)

func load_character_preview_on_button(button: Button, character_id: int):
	"""
	Loads and displays a character preview (video or image) on a button.

	Args:
		button: The button to add the preview to
		character_id: The character ID (0-2)
	"""
	var char_path = "res://assets/characters/character_" + str(character_id + 1) + "/"
	var bg_path = char_path + "backgrounds/character_background.png"

	# Create a container for the preview that doesn't interfere with button functionality
	var preview_container = Control.new()
	preview_container.name = "PreviewContainer"
	preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let clicks pass through to button
	preview_container.anchor_right = 1.0
	preview_container.anchor_bottom = 1.0
	preview_container.z_index = -1  # Place behind button text

	# Try to load video animation first (only supported formats: .webm, .ogv)
	# Godot does NOT support .mp4 natively
	var supported_video_extensions = [".webm", ".ogv"]
	var video_loaded = false

	for ext in supported_video_extensions:
		var video_path = char_path + "animations/character_idle" + ext
		if FileAccess.file_exists(video_path):
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
				print("Loaded character preview video for character ", character_id + 1, " (", ext, ")")
				video_loaded = true
				break

	# Fallback to background image if no video was loaded
	if not video_loaded:
		if FileAccess.file_exists(bg_path):
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
				print("Loaded character preview image for character ", character_id + 1)
		else:
			print("Warning: No preview found for character ", character_id + 1)

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
