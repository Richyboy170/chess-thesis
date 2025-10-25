extends Control

var player1_character = -1
var player2_character = -1

func _ready():
	# Apply anime font theme to all UI elements
	ThemeManager.apply_theme_to_container(self, true)

	# Load character previews on buttons
	load_character_previews()

	update_start_button()

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
	var video_path = char_path + "animations/character_idle.mp4"
	var bg_path = char_path + "backgrounds/character_background.png"

	# Create a container for the preview that doesn't interfere with button functionality
	var preview_container = Control.new()
	preview_container.name = "PreviewContainer"
	preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let clicks pass through to button
	preview_container.anchor_right = 1.0
	preview_container.anchor_bottom = 1.0
	preview_container.z_index = -1  # Place behind button text

	# Try to load video animation first
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
			print("Loaded character preview video for character ", character_id + 1)
			return

	# Fallback to background image
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
