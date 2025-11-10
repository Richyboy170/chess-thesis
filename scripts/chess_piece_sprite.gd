extends Node
class_name ChessPieceSprite

## Chess Piece Sprite Manager
##
## This script manages the creation of chess piece visual representations using Sprite2D nodes.
## It handles two types of piece art:
## 1. PNG-based pieces: Simple image files loaded as textures
## 2. Scene-based pieces: Complex animated scenes (like character 4's white_knight)

## Helper function to find scene file in a piece folder
## Searches for .tscn files in the scene subdirectory
##
## Args:
##     piece_type: The type of piece (e.g., "knight", "queen", "pawn")
##     character_id: The character ID (1-4)
##     is_held: Whether to check held or board piece folder
##
## Returns:
##     The path to the scene file, or empty string if not found
static func find_piece_scene(piece_type: String, character_id: int, is_held: bool) -> String:
	var base_path = ""

	# Determine base path for piece folder
	if is_held:
		base_path = "res://assets/characters/character_%d/pieces/held/white_%s" % [character_id, piece_type]
	else:
		base_path = "res://assets/characters/character_%d/pieces/white_%s" % [character_id, piece_type]

	# Check if the piece folder exists (it should be a directory, not a PNG)
	var scene_dir = base_path + "/scene"

	# Common scene file names to check
	var scene_names = ["hovereffect_scyka.tscn", "scene.tscn", "piece.tscn", "white_%s.tscn" % piece_type]

	for scene_name in scene_names:
		var scene_path = scene_dir + "/" + scene_name
		if FileAccess.file_exists(scene_path):
			return scene_path

	return ""


## Creates a Sprite2D node for a chess piece with proper art loading
## Handles both PNG files and scene-based pieces (like white_knight)
##
## Args:
##     piece_type: The type of piece (e.g., "knight", "queen", "pawn")
##     character_id: The character ID (1-4)
##     is_held: Whether this is a held piece (defaults to false for board pieces)
##
## Returns:
##     A Node2D containing the piece visual (Sprite2D with texture or scene)
static func create_piece_sprite(piece_type: String, character_id: int, is_held: bool = false) -> Node2D:
	var container = Node2D.new()
	container.name = "PieceSprite_%s" % piece_type

	# Normalize piece type to lowercase
	piece_type = piece_type.to_lower()

	# IF-ELSE LOGIC: Check if piece is a scene folder or PNG file
	var scene_path = find_piece_scene(piece_type, character_id, is_held)

	if scene_path != "":
		# SCENE-BASED PIECE: Load and instantiate the scene
		var piece_scene = load(scene_path)
		if piece_scene:
			var scene_instance = piece_scene.instantiate()
			scene_instance.name = "%sScene" % piece_type.capitalize()
			container.add_child(scene_instance)
			print("Created scene-based piece: %s (Character %d, is_held: %s)" % [piece_type, character_id, is_held])
			return container
		else:
			push_error("Failed to load scene: %s" % scene_path)
			# Fall through to PNG loading as fallback

	# PNG-BASED PIECE: Standard image file loading
	var sprite = Sprite2D.new()
	sprite.name = "PieceSprite"

	# Determine the path based on whether it's a held piece or board piece
	var piece_path = ""
	if is_held:
		# Check for held piece PNG
		piece_path = "res://assets/characters/character_%d/pieces/held/white_%s.png" % [character_id, piece_type]

		# If held piece doesn't exist, fall back to regular piece
		if not FileAccess.file_exists(piece_path):
			piece_path = "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id, piece_type]
			print("No held piece found, using regular piece for %s" % piece_type)
	else:
		# Regular board piece
		piece_path = "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id, piece_type]

	# Load and apply the texture
	if FileAccess.file_exists(piece_path):
		var texture = load(piece_path)
		if texture:
			sprite.texture = texture
			sprite.centered = true
			container.add_child(sprite)
			print("Created PNG-based piece: %s (Character %d)" % [piece_type, character_id])
			return container
		else:
			push_error("Failed to load texture: %s" % piece_path)
	else:
		push_error("Piece image not found: %s" % piece_path)

	# Return empty container if loading failed (better than null)
	return container


## Creates a piece sprite specifically for held pieces
## This is a convenience wrapper that calls create_piece_sprite with is_held=true
##
## Args:
##     piece_type: The type of piece (e.g., "knight", "queen", "pawn")
##     character_id: The character ID (1-4)
##
## Returns:
##     A Node2D containing the held piece visual
static func create_held_piece_sprite(piece_type: String, character_id: int) -> Node2D:
	return create_piece_sprite(piece_type, character_id, true)


## Checks if a piece uses a scene instead of a PNG
##
## Args:
##     piece_type: The type of piece
##     character_id: The character ID
##     is_held: Whether checking for held piece
##
## Returns:
##     true if the piece uses a scene file, false if it uses a PNG
static func is_scene_based_piece(piece_type: String, character_id: int, is_held: bool = false) -> bool:
	piece_type = piece_type.to_lower()

	# Check if a scene file exists for this piece
	var scene_path = find_piece_scene(piece_type, character_id, is_held)
	return scene_path != ""


## Gets the appropriate path for a piece (PNG or scene)
##
## Args:
##     piece_type: The type of piece
##     character_id: The character ID
##     is_held: Whether to get held piece path
##
## Returns:
##     The file path as a string
static func get_piece_path(piece_type: String, character_id: int, is_held: bool = false) -> String:
	piece_type = piece_type.to_lower()

	# Check for scene-based piece first
	var scene_path = find_piece_scene(piece_type, character_id, is_held)
	if scene_path != "":
		return scene_path

	# Return PNG path
	if is_held:
		var held_path = "res://assets/characters/character_%d/pieces/held/white_%s.png" % [character_id, piece_type]
		if FileAccess.file_exists(held_path):
			return held_path
		# Fallback to board piece if held doesn't exist
		return "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id, piece_type]
	else:
		return "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id, piece_type]
