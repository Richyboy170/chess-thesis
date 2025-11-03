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
	print("Press F1 to inspect current model state")
	print("Press F2 to list available animations")
	print("Press F3 to show current motion status")
	load_character(current_character_id)

func _input(event):
	# Handle debug keys
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				debug_inspect_model_state()
				get_viewport().set_input_as_handled()
			KEY_F2:
				debug_list_animations()
				get_viewport().set_input_as_handled()
			KEY_F3:
				debug_show_motion_status()
				get_viewport().set_input_as_handled()

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
	print("\n" + "=".repeat(70))
	print("--- Loading Character %d ---" % character_id)
	print("=".repeat(70))

	current_character_id = character_id

	# Reset zoom level to 0.5 to prevent cropping
	zoom_level = 0.3
	update_zoom()

	# Clear existing model
	if current_model:
		print("🧹 Cleaning up previous model...")
		# Disconnect signals if connected
		if current_model.motion_finished.is_connected(_on_motion_finished):
			current_model.motion_finished.disconnect(_on_motion_finished)
		current_model.queue_free()
		current_model = null
		print("   ✓ Previous model cleaned up")

	# Detailed GDExtension diagnostics
	print("\n🔍 GDExtension Diagnostics:")
	print("   Checking for GDCubism availability...")

	if not ClassDB.class_exists("GDCubismUserModel"):
		print("   ❌ CRITICAL: GDCubismUserModel class not found!")
		print("\n📋 Troubleshooting steps:")
		print("   1. Verify gd_cubism.gdextension exists at: res://gd_cubism/gd_cubism.gdextension")
		print("   2. Check if the GDCubism library is built for your platform")
		print("   3. Ensure the plugin is enabled in Project Settings")
		print("   4. Try reimporting the project")

		# Check if GDExtensionErrorDetector found issues
		if has_node("/root/GDExtensionErrorDetector"):
			print("\n⚠️ GDExtension Error Detector Report:")
			var detector = get_node("/root/GDExtensionErrorDetector")
			if detector.has_method("get_error_summary"):
				print(detector.get_error_summary())

		status_label.text = "ERROR: GDCubism plugin not loaded!"
		status_label.add_theme_color_override("font_color", Color.RED)
		print("=".repeat(70))
		return

	print("   ✓ GDCubismUserModel class found")

	# Additional class checks
	var available_classes = []
	for cubism_class in ["GDCubismUserModel", "GDCubismEffect", "GDCubismEffectBreath"]:
		if ClassDB.class_exists(cubism_class):
			available_classes.append(cubism_class)
	print("   ✓ Available GDCubism classes: %s" % ", ".join(available_classes))

	# Get model path
	print("\n📂 Model Path Resolution:")
	var model_path = Live2DDebugger.get_model_path(character_id)
	if model_path.is_empty():
		print("   ❌ ERROR: Could not find model path for character %d" % character_id)
		status_label.text = "ERROR: Invalid character ID"
		status_label.add_theme_color_override("font_color", Color.RED)
		print("=".repeat(70))
		return

	print("   Model path: %s" % model_path)
	print("   Character ID: %d" % character_id)

	# Check if model file exists
	print("\n📄 Model File Validation:")
	if not FileAccess.file_exists(model_path):
		print("   ❌ ERROR: Model file does not exist!")
		print("   Expected location: %s" % model_path)

		# List what files DO exist in the character directory
		var char_dir = model_path.get_base_dir()
		print("\n   Files in character directory (%s):" % char_dir)
		var dir = DirAccess.open(char_dir)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					print("     - %s" % file_name)
				file_name = dir.get_next()
			dir.list_dir_end()

		status_label.text = "ERROR: Model file not found!"
		status_label.add_theme_color_override("font_color", Color.RED)
		print("=".repeat(70))
		return

	print("   ✓ Model file exists")

	# Read and display model.json info for character 4
	if character_id == 4:
		print("\n📊 Character 4 (Scyka) Model Details:")
		var file = FileAccess.open(model_path, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(json_text) == OK:
				var model_data = json.get_data()
				print("   Model Version: %s" % model_data.get("Version", "Unknown"))
				if model_data.has("FileReferences"):
					var refs = model_data["FileReferences"]
					print("   Moc file: %s" % refs.get("Moc", "N/A"))
					print("   Textures: %d" % refs.get("Textures", []).size())
					print("   Physics: %s" % refs.get("Physics", "N/A"))

	# Create Live2D model
	print("\n🎭 Model Instantiation:")
	print("   Creating GDCubismUserModel instance...")
	var live2d_model = ClassDB.instantiate("GDCubismUserModel")
	if not live2d_model:
		print("   ❌ ERROR: Failed to instantiate GDCubismUserModel")
		status_label.text = "ERROR: Failed to instantiate model"
		status_label.add_theme_color_override("font_color", Color.RED)
		print("=".repeat(70))
		return

	print("   ✓ Model instance created successfully")
	print("   Instance type: %s" % live2d_model.get_class())

	# Configure the model
	print("\n⚙️ Model Configuration:")
	print("   Setting assets path: %s" % model_path)
	live2d_model.assets = model_path

	# Set auto_scale if available
	if "auto_scale" in live2d_model:
		live2d_model.auto_scale = 2  # AUTO_SCALE_FORCE_INSIDE
		print("   ✓ Auto-scale enabled (FORCE_INSIDE)")
	else:
		print("   ⚠️ auto_scale property not available")

	# Set playback_process_mode to ensure animations update
	if "playback_process_mode" in live2d_model:
		# IDLE = 1 (uses _process callback for animation updates)
		live2d_model.playback_process_mode = 1  # GDCubismUserModel.IDLE
		print("   ✓ Playback process mode set to IDLE (auto-update enabled)")
	else:
		print("   ⚠️ playback_process_mode property not available")

	# Introspect model capabilities
	print("\n🔬 Model Capabilities Inspection:")
	var important_methods = ["start_motion", "start_motion_loop", "stop_motion", "get_motions", "get_canvas_info"]
	print("   Available animation methods:")
	for method in important_methods:
		var has_it = live2d_model.has_method(method)
		var icon = "✓" if has_it else "❌"
		print("     %s %s" % [icon, method])

	# Add to scene
	print("\n🏗️ Adding Model to Scene:")
	print("   Adding to model_container...")
	model_container.add_child(live2d_model)
	current_model = live2d_model
	print("   ✓ Model added to scene tree")

	# Center the model in the container
	print("\n📐 Model Positioning:")
	print("   Waiting for model initialization...")
	await get_tree().process_frame

	# Position the model at the center of the container
	var container_size = model_container.size
	var center_position = Vector2(container_size.x / 2.0, container_size.y / 2.0)
	live2d_model.position = center_position
	print("   Container size: %s" % container_size)
	print("   Model centered at: %s" % center_position)

	# Get model canvas info if available
	if live2d_model.has_method("get_canvas_info"):
		var canvas_info = live2d_model.get_canvas_info()
		print("   Canvas info: %s" % canvas_info)

	# Connect motion_finished signal for animation transitions
	print("\n🔔 Signal Connection:")
	if live2d_model.has_signal("motion_finished"):
		live2d_model.motion_finished.connect(_on_motion_finished)
		print("   ✓ Connected to motion_finished signal")
	else:
		print("   ⚠️ motion_finished signal not available")

	# Load animation configuration for character 4
	if character_id == 4:
		print("\n🎬 Character 4 Animation Configuration:")
		var anim_config = Live2DAnimationConfig.load_animation_config(character_id)
		if not anim_config.is_empty():
			print("   Character name: %s" % anim_config.get("character_name", "Unknown"))
			print("   Available animations:")
			if anim_config.has("animations"):
				for anim_name in anim_config["animations"].keys():
					var anim = anim_config["animations"][anim_name]
					var motion_file = anim.get("motion_file", "N/A")
					var loop = anim.get("loop", false)
					var priority = anim.get("priority", 0)
					print("     - %s: file='%s', loop=%s, priority=%d" % [anim_name, motion_file, loop, priority])

			# Check which motion files actually exist
			print("\n   Motion File Verification:")
			var char_path = "res://assets/characters/character_4/"
			for anim_name in anim_config["animations"].keys():
				var anim = anim_config["animations"][anim_name]
				var motion_file = anim.get("motion_file", "")
				var motion_path = char_path + motion_file + ".motion3.json"
				var exists = FileAccess.file_exists(motion_path)
				var icon = "✓" if exists else "❌"
				print("     %s %s: %s" % [icon, anim_name, motion_path])

	# Start default animation
	print("\n▶️ Starting Default Animation:")
	if live2d_model.has_method("start_motion"):
		var default_action = Live2DAnimationConfig.get_default_animation(character_id)
		print("   Default action: %s" % default_action)
		current_animation = default_action

		print("   Calling Live2DAnimationConfig.play_animation()...")
		var success = Live2DAnimationConfig.play_animation(live2d_model, character_id, default_action)

		if success:
			print("   ✓ Default animation started successfully")

			# Check current motion state
			if live2d_model.has_method("get_motions"):
				var motions = live2d_model.get_motions()
				print("   Current motions playing: %s" % motions)
		else:
			print("   ❌ WARNING: Failed to start default animation")
	else:
		print("   ❌ ERROR: start_motion method not available")

	# Update UI
	var character_info = Live2DDebugger.get_character_info(character_id)
	var character_name = character_info.get("name", "Unknown")
	character_label.text = "Character: %s (ID: %d)" % [character_name, character_id]
	status_label.text = "Model loaded successfully!"
	status_label.add_theme_color_override("font_color", Color.GREEN)

	print("\n✅ SUCCESS: Model loaded and displayed")
	print("=".repeat(70) + "\n")

# Motion finished callback - handles animation transitions
var current_animation: String = "idle"

func _on_motion_finished():
	print("\n" + "=".repeat(60))
	print("🔔 Motion Finished Callback")
	print("=".repeat(60))
	print("   Current animation: %s" % current_animation)
	print("   Character ID: %d" % current_character_id)

	# Check if there's a transition defined for the current animation
	var transition = Live2DAnimationConfig.get_animation_transition(current_character_id, current_animation)
	print("   Transition config: %s" % transition)

	if not transition.is_empty() and transition.has("next_animation"):
		var next_anim = transition["next_animation"]
		var delay = transition.get("delay", 5)

		print("\n▶️ Animation Transition:")
		print("   From: %s" % current_animation)
		print("   To: %s" % next_anim)
		print("   Delay: %.2fs" % delay)

		if delay > 0.0:
			print("   ⏳ Waiting %.2fs before transition..." % delay)
			await get_tree().create_timer(delay).timeout
			print("   ✓ Delay complete")

		# Play the next animation
		if current_model and current_model.has_method("start_motion"):
			print("   🎬 Starting next animation: %s" % next_anim)
			current_animation = next_anim
			var success = Live2DAnimationConfig.play_animation(current_model, current_character_id, next_anim)
			if success:
				print("   ✓ Transition successful")
			else:
				print("   ❌ Transition failed")
		else:
			print("   ❌ ERROR: Model not available or missing start_motion method")
	else:
		print("   ℹ️ No transition defined for '%s'" % current_animation)

	print("=".repeat(60) + "\n")

# Button callbacks
func _on_character_3_pressed():
	load_character(4)

func _on_character_4_pressed():
	load_character(5)

func _on_character_5_pressed():
	load_character(6)

func _on_idle_animation_pressed():
	print("\n" + "=".repeat(60))
	print("🎮 IDLE Animation Button Pressed")
	print("=".repeat(60))

	if not current_model:
		print("   ❌ ERROR: current_model is null!")
		print("=".repeat(60) + "\n")
		return

	print("   ✓ current_model exists: %s" % current_model)
	print("   Character ID: %d" % current_character_id)

	if not current_model.has_method("start_motion"):
		print("   ❌ ERROR: start_motion method not available")
		print("=".repeat(60) + "\n")
		return

	print("   ✓ start_motion method available")
	print("\n▶️ Playing idle animation...")
	current_animation = "idle"
	var success = Live2DAnimationConfig.play_animation(current_model, current_character_id, "idle")

	if success:
		print("\n✅ Idle animation started successfully")
	else:
		print("\n❌ Failed to start idle animation")

	print("=".repeat(60) + "\n")

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

# ============================================================================
# DEBUG HELPER FUNCTIONS
# ============================================================================

## F1 - Inspect current model state
func debug_inspect_model_state():
	print("\n" + "=".repeat(70))
	print("🔍 MODEL STATE INSPECTION (F1)")
	print("=".repeat(70))

	if not current_model:
		print("❌ No model loaded")
		print("=".repeat(70) + "\n")
		return

	print("✓ Model loaded: %s" % current_model.get_class())
	print("Character ID: %d" % current_character_id)
	print("Current animation: %s" % current_animation)

	# Model properties
	print("\n📊 Model Properties:")
	if "assets" in current_model:
		print("   assets: %s" % current_model.assets)
	if "position" in current_model:
		print("   position: %s" % current_model.position)
	if "scale" in current_model:
		print("   scale: %s" % current_model.scale)
	if "visible" in current_model:
		print("   visible: %s" % current_model.visible)
	if "auto_scale" in current_model:
		print("   auto_scale: %s" % current_model.auto_scale)

	# Available methods
	print("\n🔧 Animation Methods:")
	var methods = ["start_motion", "start_motion_loop", "stop_motion", "get_motions", "get_cubism_motion_queue_entries"]
	for method in methods:
		var has_it = current_model.has_method(method)
		var icon = "✓" if has_it else "❌"
		print("   %s %s" % [icon, method])

	# Current motion queue
	if current_model.has_method("get_motions"):
		print("\n🎬 Current Motion Queue:")
		var motions = current_model.get_motions()
		print("   %s" % motions)

	if current_model.has_method("get_cubism_motion_queue_entries"):
		print("\n📋 Motion Queue Entries:")
		var entries = current_model.get_cubism_motion_queue_entries()
		if entries:
			for i in entries.size():
				print("   [%d] %s" % [i, entries[i]])
		else:
			print("   (empty)")

	# Canvas info
	if current_model.has_method("get_canvas_info"):
		print("\n📐 Canvas Info:")
		var canvas = current_model.get_canvas_info()
		print("   %s" % canvas)

	# Parameters
	if current_model.has_method("get_parameters"):
		print("\n🎛️ Model Parameters:")
		var params = current_model.get_parameters()
		if params:
			var count = min(10, params.size())  # Show first 10
			print("   Total parameters: %d (showing first %d)" % [params.size(), count])
			for i in count:
				print("   [%d] %s" % [i, params[i]])
		else:
			print("   (none)")

	print("=".repeat(70) + "\n")

## F2 - List available animations
func debug_list_animations():
	print("\n" + "=".repeat(70))
	print("🎬 AVAILABLE ANIMATIONS (F2)")
	print("=".repeat(70))

	if current_character_id == 0:
		print("❌ No character loaded")
		print("=".repeat(70) + "\n")
		return

	print("Character ID: %d" % current_character_id)
	print("Current animation: %s" % current_animation)

	var anim_config = Live2DAnimationConfig.load_animation_config(current_character_id)
	if anim_config.is_empty():
		print("❌ Failed to load animation config")
		print("=".repeat(70) + "\n")
		return

	print("\nCharacter: %s" % anim_config.get("character_name", "Unknown"))
	print("Default animation: %s" % anim_config.get("default_animation", "idle"))

	if anim_config.has("animations"):
		print("\n📋 Animation List:")
		var anims = anim_config["animations"]
		for anim_name in anims.keys():
			var anim = anims[anim_name]
			var motion_file = anim.get("motion_file", "N/A")
			var loop = anim.get("loop", false)
			var priority = anim.get("priority", 0)
			var fade_in = anim.get("fade_in", true)
			var desc = anim.get("description", "")

			var current_marker = " ◀" if anim_name == current_animation else ""
			print("\n   %s%s:" % [anim_name, current_marker])
			print("     motion_file: %s" % motion_file)
			print("     loop: %s, priority: %d, fade_in: %s" % [loop, priority, fade_in])
			if desc:
				print("     description: %s" % desc)

			# Check if file exists
			var char_path = "res://assets/characters/character_%d/" % current_character_id
			var motion_path = char_path + motion_file + ".motion3.json"
			var exists = FileAccess.file_exists(motion_path)
			var icon = "✓" if exists else "❌"
			print("     %s File: %s" % [icon, motion_path])

	if anim_config.has("animation_transitions"):
		print("\n🔄 Animation Transitions:")
		var transitions = anim_config["animation_transitions"]
		for anim_name in transitions.keys():
			var trans = transitions[anim_name]
			var next_anim = trans.get("next_animation", "N/A")
			var delay = trans.get("delay", 5)
			print("   %s → %s (delay: %.2fs)" % [anim_name, next_anim, delay])

	print("=".repeat(70) + "\n")

## F3 - Show current motion status
func debug_show_motion_status():
	print("\n" + "=".repeat(70))
	print("▶️ CURRENT MOTION STATUS (F3)")
	print("=".repeat(70))

	if not current_model:
		print("❌ No model loaded")
		print("=".repeat(70) + "\n")
		return

	print("Character ID: %d" % current_character_id)
	print("Current animation: %s" % current_animation)
	print("Model class: %s" % current_model.get_class())

	# Check what's currently playing
	if current_model.has_method("get_motions"):
		var motions = current_model.get_motions()
		print("\n🎬 Active Motions:")
		print("   %s" % motions)

		if motions is Array and motions.size() > 0:
			print("   ✓ %d motion(s) currently playing" % motions.size())
		elif motions is Dictionary and not motions.is_empty():
			print("   ✓ Motion data: %s" % motions)
		else:
			print("   ⚠️ No motions currently playing")

	# Check motion queue
	if current_model.has_method("get_cubism_motion_queue_entries"):
		var entries = current_model.get_cubism_motion_queue_entries()
		print("\n📋 Motion Queue:")
		if entries and entries.size() > 0:
			print("   Queue length: %d" % entries.size())
			for i in entries.size():
				print("   [%d] %s" % [i, entries[i]])
		else:
			print("   (empty)")

	# Animation config for current animation
	var anim_data = Live2DAnimationConfig.get_animation(current_character_id, current_animation)
	if not anim_data.is_empty():
		print("\n⚙️ Current Animation Config:")
		print("   Motion file: %s" % anim_data.get("motion_file", "N/A"))
		print("   Loop: %s" % anim_data.get("loop", false))
		print("   Priority: %s" % anim_data.get("priority", 0))
		print("   Fade in: %s" % anim_data.get("fade_in", true))

	# Check for transition
	var transition = Live2DAnimationConfig.get_animation_transition(current_character_id, current_animation)
	if not transition.is_empty():
		print("\n🔄 Next Transition:")
		print("   Next: %s" % transition.get("next_animation", "N/A"))
		print("   Delay: %.2fs" % transition.get("delay", 5))
	else:
		print("\n🔄 No transition defined for this animation")

	print("=".repeat(70) + "\n")
