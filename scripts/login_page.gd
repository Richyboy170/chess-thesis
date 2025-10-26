extends Control

@onready var no_timer_button = $VBoxContainer/TimerSettings/TimerOptions/NoTimerButton
@onready var timer_5_button = $VBoxContainer/TimerSettings/TimerOptions/Timer5Button
@onready var timer_10_button = $VBoxContainer/TimerSettings/TimerOptions/Timer10Button
@onready var timer_15_button = $VBoxContainer/TimerSettings/TimerOptions/Timer15Button
@onready var timer_30_button = $VBoxContainer/TimerSettings/TimerOptions/Timer30Button

var timer_buttons: Array = []

func _ready():
	# Load random background
	load_random_background()

	# Setup button group for timer selection
	timer_buttons = [no_timer_button, timer_5_button, timer_10_button, timer_15_button, timer_30_button]

	# Connect all timer buttons
	no_timer_button.pressed.connect(_on_timer_button_pressed.bind(0))
	timer_5_button.pressed.connect(_on_timer_button_pressed.bind(5))
	timer_10_button.pressed.connect(_on_timer_button_pressed.bind(10))
	timer_15_button.pressed.connect(_on_timer_button_pressed.bind(15))
	timer_30_button.pressed.connect(_on_timer_button_pressed.bind(30))

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

func _on_timer_button_pressed(minutes: int):
	# Unpress all other buttons
	for button in timer_buttons:
		button.button_pressed = false

	# Press the selected button
	match minutes:
		0:
			no_timer_button.button_pressed = true
		5:
			timer_5_button.button_pressed = true
		10:
			timer_10_button.button_pressed = true
		15:
			timer_15_button.button_pressed = true
		30:
			timer_30_button.button_pressed = true

	# Set timer in GameState (convert minutes to seconds)
	GameState.player_time_limit = minutes * 60

func _on_play_button_pressed():
	# Navigate to character selection
	get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")
