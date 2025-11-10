extends Node
class_name ChessPieceSprite

## Chess Piece Sprite Manager
##
## This script manages the creation of chess piece visual representations using Sprite2D nodes.
## It handles two types of piece art:
## 1. PNG-based pieces: Simple image files loaded as textures
## 2. Scene-based pieces: Complex animated scenes (like character 4's white_knight)

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

	# Check if this is a special scene-based piece
	if is_held and piece_type == "knight" and character_id == 4:
		# WHITE KNIGHT SCENE (Character 4 held piece)
		var knight_scene_path = "res://assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn"

		if FileAccess.file_exists(knight_scene_path):
			var knight_scene = load(knight_scene_path)
			if knight_scene:
				# Instantiate the scene
				var scene_instance = knight_scene.instantiate()
				scene_instance.name = "WhiteKnightScene"
				container.add_child(scene_instance)
				print("Created scene-based piece: white_knight (Character 4)")
				return container
			else:
				push_error("Failed to load white_knight scene: %s" % knight_scene_path)
		else:
			push_warning("White knight scene not found at: %s" % knight_scene_path)

	# PNG-BASED PIECE (Standard for all other pieces)
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

	# Currently only white_knight for character 4 held piece is scene-based
	if is_held and piece_type == "knight" and character_id == 4:
		var scene_path = "res://assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn"
		return FileAccess.file_exists(scene_path)

	return false


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

	# Check for scene-based piece
	if is_scene_based_piece(piece_type, character_id, is_held):
		return "res://assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn"

	# Return PNG path
	if is_held:
		return "res://assets/characters/character_%d/pieces/held/white_%s.png" % [character_id, piece_type]
	else:
		return "res://assets/characters/character_%d/pieces/white_%s.png" % [character_id, piece_type]
