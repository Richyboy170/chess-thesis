extends Control

# Simple sandbox for testing Live2D models with GDCubism

@onready var model_container = $ModelContainer
@onready var status_label = $VBoxContainer/StatusLabel
@onready var character_label = $VBoxContainer/CharacterLabel

var current_model = null
var current_character_id = 3  # Start with character 3 (Scyka)

# Zoom settings
var zoom_level: float = 1.0
const ZOOM_MIN: float = 0.5
const ZOOM_MAX: float = 3.0
const ZOOM_STEP: float = 0.1

func _ready():
	print("=== Live2D Model Test Sandbox ===")
	load_character(current_character_id)

func _input(event):
	# Handle mouse wheel for zooming
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_out()

func zoom_in():
	zoom_level = clamp(zoom_level + ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
	update_zoom()
	print("Zoom in: %.1fx" % zoom_level)

func zoom_out():
	zoom_level = clamp(zoom_level - ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
	update_zoom()
	print("Zoom out: %.1fx" % zoom_level)

func update_zoom():
	if model_container:
		model_container.scale = Vector2(zoom_level, zoom_level)

func load_character(character_id: int):
	print("\n--- Loading Character %d ---" % character_id)
	current_character_id = character_id

	# Reset zoom level
	zoom_level = 1.0
	update_zoom()

	# Clear existing model
	if current_model:
		current_model.queue_free()
		current_model = null

	# Check if GDCubism is available
	if not ClassDB.class_exists("GDCubismUserModel"):
		status_label.text = "ERROR: GDCubism plugin not loaded!"
		status_label.add_theme_color_override("font_color", Color.RED)
		print("ERROR: GDCubism plugin not available")
		return

	# Get model path
	var model_path = Live2DDebugger.get_model_path(character_id)
	if model_path.is_empty():
		status_label.text = "ERROR: Invalid character ID"
		status_label.add_theme_color_override("font_color", Color.RED)
		print("ERROR: Could not find model path for character %d" % character_id)
		return

	print("Model path: %s" % model_path)

	# Check if model file exists
	if not FileAccess.file_exists(model_path):
		status_label.text = "ERROR: Model file not found!"
		status_label.add_theme_color_override("font_color", Color.RED)
		print("ERROR: Model file does not exist: %s" % model_path)
		return

	# Create Live2D model
	var live2d_model = ClassDB.instantiate("GDCubismUserModel")
	if not live2d_model:
		status_label.text = "ERROR: Failed to instantiate model"
		status_label.add_theme_color_override("font_color", Color.RED)
		print("ERROR: Failed to instantiate GDCubismUserModel")
		return

	# Configure the model
	live2d_model.assets = model_path
	live2d_model.anchor_right = 1.0
	live2d_model.anchor_bottom = 1.0

	# Set auto_scale if available
	if "auto_scale" in live2d_model:
		live2d_model.auto_scale = 2  # AUTO_SCALE_FORCE_INSIDE
		print("Auto-scale enabled")

	# Add to scene
	model_container.add_child(live2d_model)
	current_model = live2d_model

	# Start default animation
	if live2d_model.has_method("start_motion"):
		var default_action = Live2DAnimationConfig.get_default_animation(character_id)
		print("Starting default animation: %s" % default_action)
		var success = Live2DAnimationConfig.play_animation(live2d_model, character_id, default_action)
		if not success:
			print("Warning: Failed to start default animation")

	# Update UI
	var character_info = Live2DDebugger.LIVE2D_CHARACTERS.get(character_id, {})
	var character_name = character_info.get("name", "Unknown")
	character_label.text = "Character: %s (ID: %d)" % [character_name, character_id]
	status_label.text = "Model loaded successfully!"
	status_label.add_theme_color_override("font_color", Color.GREEN)
	print("SUCCESS: Model loaded and displayed")

# Button callbacks
func _on_character_3_pressed():
	load_character(3)

func _on_character_4_pressed():
	load_character(4)

func _on_character_5_pressed():
	load_character(5)

func _on_idle_animation_pressed():
	if current_model and current_model.has_method("start_motion"):
		print("Playing idle animation")
		Live2DAnimationConfig.play_animation(current_model, current_character_id, "idle")

func _on_piece_captured_pressed():
	if current_model and current_model.has_method("start_motion"):
		print("Playing piece_captured animation")
		Live2DAnimationConfig.play_animation(current_model, current_character_id, "piece_captured")

func _on_check_pressed():
	if current_model and current_model.has_method("start_motion"):
		print("Playing check animation")
		Live2DAnimationConfig.play_animation(current_model, current_character_id, "check")
