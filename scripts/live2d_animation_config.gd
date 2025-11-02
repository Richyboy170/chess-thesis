extends Node

## Live2D Animation Configuration Loader
## Loads and manages JSON-based animation configurations for Live2D characters

class_name Live2DAnimationConfig

# Cache for loaded animation configs
static var _animation_configs: Dictionary = {}

# Dynamically detected character paths and metadata
static var _character_paths: Dictionary = {}  # ID -> path mapping
static var _character_folders: Dictionary = {} # ID -> folder name mapping
static var _folder_to_id: Dictionary = {}      # folder name -> ID mapping
static var _paths_initialized: bool = false

# Auto-detect available characters by scanning assets/characters/ folder
# Accepts ANY folder name, assigns IDs based on alphabetical order
static func _initialize_character_paths():
	if _paths_initialized:
		return

	_paths_initialized = true
	_character_paths.clear()
	_character_folders.clear()
	_folder_to_id.clear()

	var characters_dir = "res://assets/characters/"
	var dir = DirAccess.open(characters_dir)

	if not dir:
		push_error("Live2DAnimationConfig: Failed to open characters directory: " + characters_dir)
		return

	# Collect all character folders
	var folders_with_animations = []
	dir.list_dir_begin()
	var folder_name = dir.get_next()

	while folder_name != "":
		if dir.current_is_dir() and not folder_name.begins_with("."):
			var char_path = characters_dir + folder_name + "/"

			# Check if animations.json exists to confirm it's a valid Live2D character
			if FileAccess.file_exists(char_path + "animations.json"):
				folders_with_animations.append({
					"name": folder_name,
					"path": char_path
				})

		folder_name = dir.get_next()

	dir.list_dir_end()

	# Sort folders alphabetically for consistent ID assignment
	folders_with_animations.sort_custom(func(a, b): return a["name"] < b["name"])

	# Assign IDs starting from 1 (to maintain compatibility with character_1, character_2 naming)
	var char_id = 1
	for folder_data in folders_with_animations:
		_character_paths[char_id] = folder_data["path"]
		_character_folders[char_id] = folder_data["name"]
		_folder_to_id[folder_data["name"]] = char_id
		print("Live2DAnimationConfig: Found character %d '%s' at %s" % [char_id, folder_data["name"], folder_data["path"]])
		char_id += 1

	print("Live2DAnimationConfig: Detected %d Live2D characters" % _character_paths.size())

# Get all available character IDs
static func get_available_characters() -> Array:
	_initialize_character_paths()
	var ids = _character_paths.keys()
	ids.sort()
	return ids

# Get character folder name from ID
static func get_character_folder(character_id: int) -> String:
	_initialize_character_paths()
	return _character_folders.get(character_id, "")

# Get character ID from folder name
static func get_character_id_from_folder(folder_name: String) -> int:
	_initialize_character_paths()
	return _folder_to_id.get(folder_name, -1)

# Get all character folders (sorted alphabetically)
static func get_character_folders() -> Array:
	_initialize_character_paths()
	var folders = []
	var ids = _character_paths.keys()
	ids.sort()
	for id in ids:
		folders.append(_character_folders[id])
	return folders

## Load animation configuration for a character
## Returns the animation config dictionary or null if failed
static func load_animation_config(character_id: int) -> Dictionary:
	# Initialize paths on first use
	_initialize_character_paths()

	# Return cached config if already loaded
	if _animation_configs.has(character_id):
		return _animation_configs[character_id]

	# Get character path
	if not _character_paths.has(character_id):
		push_error("Live2DAnimationConfig: Unknown character ID: " + str(character_id))
		return {}

	var char_path = _character_paths[character_id]
	var config_path = char_path + "animations.json"

	# Load the JSON file
	var file = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("Live2DAnimationConfig: Failed to open animation config: " + config_path)
		return {}

	var json_text = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_text)

	if parse_result != OK:
		push_error("Live2DAnimationConfig: Failed to parse JSON at line " + str(json.get_error_line()) + ": " + json.get_error_message())
		return {}

	var config = json.get_data()

	# Validate config structure
	if not config.has("animations"):
		push_error("Live2DAnimationConfig: Config missing 'animations' key: " + config_path)
		return {}

	# Cache and return
	_animation_configs[character_id] = config
	print("Live2DAnimationConfig: Loaded config for character " + str(character_id) + " (" + config.get("character_name", "Unknown") + ")")

	return config

## Get animation data for a specific action
## Returns animation data dictionary or null if not found
static func get_animation(character_id: int, action: String) -> Dictionary:
	var config = load_animation_config(character_id)
	if config.is_empty():
		return {}

	if not config["animations"].has(action):
		push_warning("Live2DAnimationConfig: Animation '" + action + "' not found for character " + str(character_id))
		# Try to return default animation
		var default_action = config.get("default_animation", "idle")
		if config["animations"].has(default_action):
			return config["animations"][default_action]
		return {}

	return config["animations"][action]

## Get the motion file name for an action
static func get_motion_file(character_id: int, action: String) -> String:
	var anim_data = get_animation(character_id, action)
	if anim_data.is_empty():
		return ""
	return anim_data.get("motion_file", "")

## Get animation parameters (group, priority, fade_in)
static func get_animation_params(character_id: int, action: String) -> Dictionary:
	var anim_data = get_animation(character_id, action)
	if anim_data.is_empty():
		return {"group": 0, "priority": 2, "fade_in": true}

	return {
		"group": anim_data.get("group", 0),
		"priority": anim_data.get("priority", 2),
		"fade_in": anim_data.get("fade_in", true),
		"loop": anim_data.get("loop", true)
	}

## Play an animation on a Live2D model using the action name
## Returns true if animation was started successfully
static func play_animation(live2d_model: Node, character_id: int, action: String) -> bool:
	if live2d_model == null:
		push_error("Live2DAnimationConfig: live2d_model is null")
		return false

	if not live2d_model.has_method("start_motion"):
		push_error("Live2DAnimationConfig: live2d_model doesn't have start_motion method")
		return false

	var motion_file = get_motion_file(character_id, action)
	if motion_file.is_empty():
		push_error("Live2DAnimationConfig: No motion file found for action '" + action + "' on character " + str(character_id))
		return false

	var params = get_animation_params(character_id, action)

	print("Live2DAnimationConfig: Playing animation '" + action + "' (motion: " + motion_file + ") on character " + str(character_id))

	# Start the motion (GDCubism start_motion expects 3 arguments: motion_file, group, priority)
	live2d_model.start_motion(
		motion_file,
		params["group"],
		params["priority"]
	)

	return true

## Get transition info for an animation (what should play next)
## Returns a dictionary with "next_animation" and "delay" keys, or empty dict if no transition
static func get_animation_transition(character_id: int, action: String) -> Dictionary:
	var config = load_animation_config(character_id)
	if config.is_empty():
		return {}

	if not config.has("animation_transitions"):
		return {}

	if not config["animation_transitions"].has(action):
		return {}

	return config["animation_transitions"][action]

## Get a random variant of an animation (if variants are defined)
static func get_random_variant(character_id: int, action: String) -> String:
	var anim_data = get_animation(character_id, action)
	if anim_data.is_empty():
		return ""

	if anim_data.has("variants") and anim_data["variants"].size() > 0:
		var variants = anim_data["variants"]
		return variants[randi() % variants.size()]

	return anim_data.get("motion_file", "")

## Get the default animation name for a character
static func get_default_animation(character_id: int) -> String:
	var config = load_animation_config(character_id)
	if config.is_empty():
		return "idle"
	return config.get("default_animation", "idle")

## Clear cached configs (useful for hot-reloading)
static func clear_cache():
	_animation_configs.clear()
	print("Live2DAnimationConfig: Cache cleared")
