extends Control

# Dedicated test sandbox for Scyka (Character 4) animations
# Focus: Testing all animation states and transitions

@onready var model_container = $ModelContainer
@onready var status_label = $VBoxContainer/StatusLabel
@onready var animation_label = $VBoxContainer/AnimationLabel

var current_model = null
const CHARACTER_ID = 4  # Scyka

# Zoom settings
var zoom_level: float = 0.5
const ZOOM_MIN: float = 0.3
const ZOOM_MAX: float = 3.0
const ZOOM_STEP: float = 0.1

# Animation state tracking
var current_animation: String = "idle"

func _ready():
	print("=== Scyka Model Test Sandbox ===")
	print("Testing character 4 (Scyka) animations")
	print("Press F1 to inspect model state")
	print("Press F2 to list all animations")
	print("Press F3 to show motion status")
	load_scyka_model()

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

func load_scyka_model():
	print("\n" + "=".repeat(70))
	print("--- Loading Scyka (Character 4) ---")
	print("=".repeat(70))

	# Reset zoom level
	zoom_level = 0.3
	update_zoom()

	# Clear existing model
	if current_model:
		print("🧹 Cleaning up previous model...")
		if current_model.motion_finished.is_connected(_on_motion_finished):
			current_model.motion_finished.disconnect(_on_motion_finished)
		current_model.queue_free()
		current_model = null
		print("   ✓ Previous model cleaned up")

	# GDExtension diagnostics
	print("\n🔍 GDExtension Check:")
	if not ClassDB.class_exists("GDCubismUserModel"):
		print("   ❌ CRITICAL: GDCubismUserModel class not found!")
		status_label.text = "ERROR: GDCubism plugin not loaded!"
		status_label.add_theme_color_override("font_color", Color.RED)
		print("=".repeat(70))
		return
	print("   ✓ GDCubismUserModel available")

	# Get Scyka's model path
	print("\n📂 Loading Scyka Model:")
	var model_path = Live2DDebugger.get_model_path(CHARACTER_ID)
	if model_path.is_empty():
		print("   ❌ ERROR: Could not find Scyka model path")
		status_label.text = "ERROR: Scyka model not found"
		status_label.add_theme_color_override("font_color", Color.RED)
		return

	print("   Model path: %s" % model_path)

	if not FileAccess.file_exists(model_path):
		print("   ❌ ERROR: Model file does not exist!")
		status_label.text = "ERROR: Model file not found"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	print("   ✓ Model file exists")

	# Create Live2D model
	print("\n🎭 Creating Model Instance:")
	var live2d_model = ClassDB.instantiate("GDCubismUserModel")
	if not live2d_model:
		print("   ❌ ERROR: Failed to instantiate model")
		status_label.text = "ERROR: Failed to create model"
		status_label.add_theme_color_override("font_color", Color.RED)
		return

	print("   ✓ Model instance created")

	# Configure model
	print("\n⚙️ Configuring Model:")
	live2d_model.assets = model_path
	if "auto_scale" in live2d_model:
		live2d_model.auto_scale = 2  # AUTO_SCALE_FORCE_INSIDE
		print("   ✓ Auto-scale enabled")

	# Add to scene
	print("\n🏗️ Adding to Scene:")
	model_container.add_child(live2d_model)
	current_model = live2d_model
	print("   ✓ Model added to scene tree")

	# Position model
	await get_tree().process_frame
	var container_size = model_container.size
	var center_position = Vector2(container_size.x / 2.0, container_size.y / 2.0)
	live2d_model.position = center_position
	print("   ✓ Model centered at: %s" % center_position)

	# Connect signals
	print("\n🔔 Connecting Signals:")
	if live2d_model.has_signal("motion_finished"):
		live2d_model.motion_finished.connect(_on_motion_finished)
		print("   ✓ motion_finished signal connected")

	# Load animation configuration
	print("\n🎬 Loading Scyka Animation Config:")
	var anim_config = Live2DAnimationConfig.load_animation_config(CHARACTER_ID)
	if not anim_config.is_empty():
		print("   Character: %s" % anim_config.get("character_name", "Unknown"))
		print("   Available animations:")
		if anim_config.has("animations"):
			for anim_name in anim_config["animations"].keys():
				var anim = anim_config["animations"][anim_name]
				var motion_file = anim.get("motion_file", "N/A")
				var loop = anim.get("loop", false)
				print("     - %s: file='%s', loop=%s" % [anim_name, motion_file, loop])

	# Start idle animation
	print("\n▶️ Starting Idle Animation:")
	current_animation = "idle"
	var success = Live2DAnimationConfig.play_animation(live2d_model, CHARACTER_ID, "idle")
	if success:
		print("   ✓ Idle animation started")
		animation_label.text = "Current: idle"
	else:
		print("   ⚠️ Failed to start idle animation")

	# Update UI
	status_label.text = "Scyka model loaded!"
	status_label.add_theme_color_override("font_color", Color.GREEN)

	print("\n✅ SUCCESS: Scyka model ready for testing")
	print("=".repeat(70) + "\n")

func _on_motion_finished():
	print("\n🔔 Motion Finished: %s" % current_animation)

	# Check for automatic transitions
	var transition = Live2DAnimationConfig.get_animation_transition(CHARACTER_ID, current_animation)
	if not transition.is_empty() and transition.has("next_animation"):
		var next_anim = transition["next_animation"]
		var delay = transition.get("delay", 0.5)

		print("   → Transitioning to: %s (delay: %.2fs)" % [next_anim, delay])

		if delay > 0.0:
			await get_tree().create_timer(delay).timeout

		play_animation(next_anim)

# Animation button handlers
func play_animation(anim_name: String):
	print("\n🎮 Playing Animation: %s" % anim_name)

	if not current_model:
		print("   ❌ ERROR: No model loaded")
		return

	if not current_model.has_method("start_motion"):
		print("   ❌ ERROR: start_motion method not available")
		return

	current_animation = anim_name
	var success = Live2DAnimationConfig.play_animation(current_model, CHARACTER_ID, anim_name)

	if success:
		print("   ✓ Animation started successfully")
		animation_label.text = "Current: %s" % anim_name

		# Show current motions
		if current_model.has_method("get_motions"):
			var motions = current_model.get_motions()
			print("   Active motions: %s" % motions)
	else:
		print("   ❌ Failed to start animation")

# Individual animation button callbacks
func _on_idle_pressed():
	play_animation("idle")

func _on_hover_piece_pressed():
	play_animation("hover_piece")

func _on_select_piece_pressed():
	play_animation("select_piece")

func _on_piece_captured_pressed():
	play_animation("piece_captured")

func _on_check_pressed():
	play_animation("check")

func _on_win_enter_pressed():
	play_animation("win_enter")

func _on_win_idle_pressed():
	play_animation("win_idle")

func _on_lose_enter_pressed():
	play_animation("lose_enter")

func _on_lose_idle_pressed():
	play_animation("lose_idle")

# Debug functions
func debug_inspect_model_state():
	print("\n" + "=".repeat(70))
	print("🔍 SCYKA MODEL STATE (F1)")
	print("=".repeat(70))

	if not current_model:
		print("❌ No model loaded")
		return

	print("✓ Model loaded: %s" % current_model.get_class())
	print("Character: Scyka (ID: %d)" % CHARACTER_ID)
	print("Current animation: %s" % current_animation)
	print("Zoom level: %.2fx" % zoom_level)

	print("\n📊 Model Properties:")
	if "assets" in current_model:
		print("   assets: %s" % current_model.assets)
	if "position" in current_model:
		print("   position: %s" % current_model.position)
	if "scale" in current_model:
		print("   scale: %s" % current_model.scale)

	if current_model.has_method("get_motions"):
		print("\n🎬 Active Motions:")
		var motions = current_model.get_motions()
		print("   %s" % motions)

	print("=".repeat(70) + "\n")

func debug_list_animations():
	print("\n" + "=".repeat(70))
	print("🎬 SCYKA ANIMATIONS (F2)")
	print("=".repeat(70))

	var anim_config = Live2DAnimationConfig.load_animation_config(CHARACTER_ID)
	if anim_config.is_empty():
		print("❌ Failed to load animation config")
		return

	print("Character: %s" % anim_config.get("character_name", "Unknown"))
	print("Current animation: %s ◀" % current_animation)

	if anim_config.has("animations"):
		print("\n📋 Available Animations:")
		var anims = anim_config["animations"]
		for anim_name in anims.keys():
			var anim = anims[anim_name]
			var motion_file = anim.get("motion_file", "N/A")
			var loop = anim.get("loop", false)
			var priority = anim.get("priority", 0)
			var desc = anim.get("description", "")

			var current_marker = " ◀ PLAYING" if anim_name == current_animation else ""
			print("\n   %s%s:" % [anim_name, current_marker])
			print("     file: %s" % motion_file)
			print("     loop: %s, priority: %d" % [loop, priority])
			if desc:
				print("     desc: %s" % desc)

			# Verify file exists
			var char_path = "res://assets/characters/character_4/"
			var motion_path = char_path + motion_file + ".motion3.json"
			var exists = FileAccess.file_exists(motion_path)
			var icon = "✓" if exists else "❌"
			print("     %s File exists" % icon)

	if anim_config.has("animation_transitions"):
		print("\n🔄 Transitions:")
		var transitions = anim_config["animation_transitions"]
		for anim_name in transitions.keys():
			var trans = transitions[anim_name]
			var next_anim = trans.get("next_animation", "N/A")
			var delay = trans.get("delay", 0)
			print("   %s → %s (%.2fs)" % [anim_name, next_anim, delay])

	print("=".repeat(70) + "\n")

func debug_show_motion_status():
	print("\n" + "=".repeat(70))
	print("▶️ MOTION STATUS (F3)")
	print("=".repeat(70))

	if not current_model:
		print("❌ No model loaded")
		return

	print("Current animation: %s" % current_animation)

	if current_model.has_method("get_motions"):
		var motions = current_model.get_motions()
		print("\n🎬 Active Motions:")
		print("   %s" % motions)

		if motions is Array and motions.size() > 0:
			print("   ✓ %d motion(s) playing" % motions.size())
		else:
			print("   ⚠️ No motions playing")

	if current_model.has_method("get_cubism_motion_queue_entries"):
		var entries = current_model.get_cubism_motion_queue_entries()
		print("\n📋 Motion Queue:")
		if entries and entries.size() > 0:
			print("   Queue length: %d" % entries.size())
			for i in entries.size():
				print("   [%d] %s" % [i, entries[i]])
		else:
			print("   (empty)")

	# Show current animation config
	var anim_data = Live2DAnimationConfig.get_animation(CHARACTER_ID, current_animation)
	if not anim_data.is_empty():
		print("\n⚙️ Current Animation Config:")
		print("   motion_file: %s" % anim_data.get("motion_file", "N/A"))
		print("   loop: %s" % anim_data.get("loop", false))
		print("   priority: %s" % anim_data.get("priority", 0))

	# Show next transition
	var transition = Live2DAnimationConfig.get_animation_transition(CHARACTER_ID, current_animation)
	if not transition.is_empty():
		print("\n🔄 Next Transition:")
		print("   → %s (delay: %.2fs)" % [transition.get("next_animation", "N/A"), transition.get("delay", 0)])

	print("=".repeat(70) + "\n")
