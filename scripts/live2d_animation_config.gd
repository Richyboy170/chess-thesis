extends Node

## Live2D Animation Configuration Loader
## Loads and manages JSON-based animation configurations for Live2D characters

class_name Live2DAnimationConfig

# Cache for loaded animation configs
static var _animation_configs: Dictionary = {}

# Character ID to character path mapping
const CHARACTER_PATHS = {
	3: "res://assets/characters/character_4/",  # Scyka
	4: "res://assets/characters/character_5/",  # Hiyori
	5: "res://assets/characters/character_6/"   # Mark
}

## Load animation configuration for a character
## Returns the animation config dictionary or null if failed
static func load_animation_config(character_id: int) -> Dictionary:
	# Return cached config if already loaded
	if _animation_configs.has(character_id):
		return _animation_configs[character_id]

	# Get character path
	if not CHARACTER_PATHS.has(character_id):
		push_error("Live2DAnimationConfig: Unknown character ID: " + str(character_id))
		return {}

	var char_path = CHARACTER_PATHS[character_id]
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

	# Start the motion
	live2d_model.start_motion(
		motion_file,
		params["group"],
		params["priority"],
		params["fade_in"]
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
