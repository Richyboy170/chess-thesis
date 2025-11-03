extends Control

# Simple sandbox for testing Live2D models with GDCubism

@onready var model_container = $ModelContainer
@onready var status_label = $VBoxContainer/StatusLabel
@onready var character_label = $VBoxContainer/CharacterLabel

var current_model = null
var current_character_id = 4  # Start with character 4 (Scyka)

# Zoom settings - start at 0.5 to prevent cropping
var zoom_level: float = 0.5
const ZOOM_MIN: float = 0.3
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

	# Reset zoom level to 0.5 to prevent cropping
	zoom_level = 0.3
	update_zoom()

	# Clear existing model
	if current_model:
		# Disconnect signals if connected
		if current_model.motion_finished.is_connected(_on_motion_finished):
			current_model.motion_finished.disconnect(_on_motion_finished)
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
	#live2d_model.anchor_right = 1.0
	#live2d_model.anchor_bottom = 1.0

	# Set auto_scale if available
	if "auto_scale" in live2d_model:
		live2d_model.auto_scale = 2  # AUTO_SCALE_FORCE_INSIDE
		print("Auto-scale enabled")

	# Add to scene
	model_container.add_child(live2d_model)
	current_model = live2d_model

	# Center the model in the container
	# Wait one frame for the model to initialize and get its size
	await get_tree().process_frame

	# Position the model at the center of the container
	var container_size = model_container.size
	var center_position = Vector2(container_size.x / 2.0, container_size.y / 2.0)
	live2d_model.position = center_position
	print("Model centered at position: %s" % center_position)

	# Connect motion_finished signal for animation transitions
	if live2d_model.has_signal("motion_finished"):
		live2d_model.motion_finished.connect(_on_motion_finished)
		print("Connected to motion_finished signal")

	# Start default animation
	if live2d_model.has_method("start_motion"):
		var default_action = Live2DAnimationConfig.get_default_animation(character_id)
		print("Starting default animation: %s" % default_action)
		current_animation = default_action
		var success = Live2DAnimationConfig.play_animation(live2d_model, character_id, default_action)
		if not success:
			print("Warning: Failed to start default animation")

	# Update UI
	var character_info = Live2DDebugger.get_character_info(character_id)
	var character_name = character_info.get("name", "Unknown")
	character_label.text = "Character: %s (ID: %d)" % [character_name, character_id]
	status_label.text = "Model loaded successfully!"
	status_label.add_theme_color_override("font_color", Color.GREEN)
	print("SUCCESS: Model loaded and displayed")

# Motion finished callback - handles animation transitions
var current_animation: String = "idle"

func _on_motion_finished():
	print("Motion finished for animation: %s" % current_animation)

	# Check if there's a transition defined for the current animation
	var transition = Live2DAnimationConfig.get_animation_transition(current_character_id, current_animation)

	if not transition.is_empty() and transition.has("next_animation"):
		var next_anim = transition["next_animation"]
		var delay = transition.get("delay", 0.0)

		print("Transitioning to: %s (delay: %.2fs)" % [next_anim, delay])

		if delay > 0.0:
			# Wait for the delay before transitioning
			await get_tree().create_timer(delay).timeout

		# Play the next animation
		if current_model and current_model.has_method("start_motion"):
			current_animation = next_anim
			Live2DAnimationConfig.play_animation(current_model, current_character_id, next_anim)

# Button callbacks
func _on_character_3_pressed():
	load_character(4)

func _on_character_4_pressed():
	load_character(5)

func _on_character_5_pressed():
	load_character(6)

func _on_idle_animation_pressed():
	if current_model and current_model.has_method("start_motion"):
		print("Playing idle animation")
		current_animation = "idle"
		Live2DAnimationConfig.play_animation(current_model, current_character_id, "idle")

func _on_piece_captured_pressed():
	print("\n" + "=".repeat(60))
	print("DEBUG: piece_captured button pressed")
	print("=".repeat(60))

	# Check if model exists
	if not current_model:
		print("ERROR: current_model is null!")
		return
	print("✓ current_model exists: %s" % current_model)

	# Check if model has start_motion method
	if not current_model.has_method("start_motion"):
		print("ERROR: current_model doesn't have start_motion method!")
		print("Available methods: %s" % current_model.get_method_list())
		return
	print("✓ current_model has start_motion method")

	# Check if model has start_motion_loop method
	if not current_model.has_method("start_motion_loop"):
		print("ERROR: current_model doesn't have start_motion_loop method!")
		return
	print("✓ current_model has start_motion_loop method")

	# Get animation config
	var anim_data = Live2DAnimationConfig.get_animation(current_character_id, "piece_captured")
	print("Animation data: %s" % anim_data)

	# Get motion file name
	var motion_file = Live2DAnimationConfig.get_motion_file(current_character_id, "piece_captured")
	print("Motion file name: '%s'" % motion_file)

	# Check if motion file exists
	var char_path = "res://assets/characters/character_%d/" % current_character_id
	var motion_path = char_path + motion_file + ".motion3.json"
	print("Looking for motion file at: %s" % motion_path)
	print("Motion file exists: %s" % FileAccess.file_exists(motion_path))

	# Get animation params
	var params = Live2DAnimationConfig.get_animation_params(current_character_id, "piece_captured")
	print("Animation params: %s" % params)

	# Try to play the animation
	print("Calling Live2DAnimationConfig.play_animation...")
	current_animation = "piece_captured"
	var success = Live2DAnimationConfig.play_animation(current_model, current_character_id, "piece_captured")
	print("Animation play result: %s" % ("SUCCESS" if success else "FAILED"))

	# Check if motion is actually playing
	if current_model.has_method("get_motions"):
		print("Current motions: %s" % current_model.get_motions())

	print("=".repeat(60) + "\n")

func _on_check_pressed():
	print("\n" + "=".repeat(60))
	print("DEBUG: check button pressed")
	print("=".repeat(60))

	# Check if model exists
	if not current_model:
		print("ERROR: current_model is null!")
		return
	print("✓ current_model exists: %s" % current_model)

	# Check if model has start_motion method
	if not current_model.has_method("start_motion"):
		print("ERROR: current_model doesn't have start_motion method!")
		print("Available methods: %s" % current_model.get_method_list())
		return
	print("✓ current_model has start_motion method")

	# Check if model has start_motion_loop method
	if not current_model.has_method("start_motion_loop"):
		print("ERROR: current_model doesn't have start_motion_loop method!")
		return
	print("✓ current_model has start_motion_loop method")

	# Get animation config
	var anim_data = Live2DAnimationConfig.get_animation(current_character_id, "check")
	print("Animation data: %s" % anim_data)

	# Get motion file name
	var motion_file = Live2DAnimationConfig.get_motion_file(current_character_id, "check")
	print("Motion file name: '%s'" % motion_file)

	# Check if motion file exists
	var char_path = "res://assets/characters/character_%d/" % current_character_id
	var motion_path = char_path + motion_file + ".motion3.json"
	print("Looking for motion file at: %s" % motion_path)
	print("Motion file exists: %s" % FileAccess.file_exists(motion_path))

	# Get animation params
	var params = Live2DAnimationConfig.get_animation_params(current_character_id, "check")
	print("Animation params: %s" % params)

	# Try to play the animation
	print("Calling Live2DAnimationConfig.play_animation...")
	current_animation = "check"
	var success = Live2DAnimationConfig.play_animation(current_model, current_character_id, "check")
	print("Animation play result: %s" % ("SUCCESS" if success else "FAILED"))

	# Check if motion is actually playing
	if current_model.has_method("get_motions"):
		print("Current motions: %s" % current_model.get_motions())

	print("=".repeat(60) + "\n")
