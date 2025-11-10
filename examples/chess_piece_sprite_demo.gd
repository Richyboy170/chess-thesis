extends Node2D

## Demo script showing how to use the ChessPieceSprite system
## This demonstrates creating chess pieces with both PNG and scene-based art

func _ready():
	print("=== Chess Piece Sprite Demo ===")
	print("Creating various chess pieces using ChessPieceSprite system...\n")

	# Example 1: Create regular board pieces (PNG-based)
	create_board_pieces_example()

	# Example 2: Create held pieces (PNG-based)
	create_held_pieces_example()

	# Example 3: Create white_knight with scene (Character 4)
	create_white_knight_scene_example()

	# Example 4: Check if pieces are scene-based
	check_piece_types_example()


## Example 1: Creating regular board pieces
func create_board_pieces_example():
	print("--- Example 1: Regular Board Pieces (PNG) ---")

	# Create a pawn from Character 1
	var pawn = ChessPieceSprite.create_piece_sprite("pawn", 1, false)
	pawn.position = Vector2(100, 100)
	add_child(pawn)
	print("Created Character 1 pawn at (100, 100)")

	# Create a queen from Character 2
	var queen = ChessPieceSprite.create_piece_sprite("queen", 2, false)
	queen.position = Vector2(200, 100)
	add_child(queen)
	print("Created Character 2 queen at (200, 100)")

	# Create a rook from Character 3
	var rook = ChessPieceSprite.create_piece_sprite("rook", 3, false)
	rook.position = Vector2(300, 100)
	add_child(rook)
	print("Created Character 3 rook at (300, 100)")

	print()


## Example 2: Creating held pieces (PNG-based, but from held folder)
func create_held_pieces_example():
	print("--- Example 2: Held Pieces (PNG) ---")

	# Create held bishop from Character 1
	var bishop = ChessPieceSprite.create_held_piece_sprite("bishop", 1)
	bishop.position = Vector2(100, 250)
	add_child(bishop)
	print("Created Character 1 held bishop at (100, 250)")

	# Create held king from Character 3
	var king = ChessPieceSprite.create_held_piece_sprite("king", 3)
	king.position = Vector2(200, 250)
	add_child(king)
	print("Created Character 3 held king at (200, 250)")

	print()


## Example 3: Creating white_knight with scene (Character 4 special case)
func create_white_knight_scene_example():
	print("--- Example 3: White Knight Scene (Character 4) ---")

	# This is the special case - white_knight for Character 4 uses a scene
	var white_knight = ChessPieceSprite.create_held_piece_sprite("knight", 4)
	white_knight.position = Vector2(400, 100)
	add_child(white_knight)
	print("Created Character 4 white_knight (SCENE-BASED) at (400, 100)")
	print("This piece has animated eyes, ghost particles, and effects!")

	# For comparison, create a regular knight from Character 1 (PNG-based)
	var regular_knight = ChessPieceSprite.create_held_piece_sprite("knight", 1)
	regular_knight.position = Vector2(400, 250)
	add_child(regular_knight)
	print("Created Character 1 knight (PNG-BASED) at (400, 250)")

	print()


## Example 4: Checking if pieces are scene-based or PNG-based
func check_piece_types_example():
	print("--- Example 4: Checking Piece Types ---")

	# Check various pieces
	var pieces_to_check = [
		{"type": "knight", "char": 4, "held": true, "desc": "Character 4 held knight"},
		{"type": "knight", "char": 1, "held": true, "desc": "Character 1 held knight"},
		{"type": "queen", "char": 4, "held": true, "desc": "Character 4 held queen"},
		{"type": "pawn", "char": 2, "held": false, "desc": "Character 2 board pawn"},
	]

	for piece_info in pieces_to_check:
		var is_scene = ChessPieceSprite.is_scene_based_piece(
			piece_info.type,
			piece_info.char,
			piece_info.held
		)

		var type_str = "SCENE-BASED" if is_scene else "PNG-BASED"
		print("%s: %s" % [piece_info.desc, type_str])

		# Also show the path
		var path = ChessPieceSprite.get_piece_path(
			piece_info.type,
			piece_info.char,
			piece_info.held
		)
		print("  Path: %s" % path)

	print()
	print("=== Demo Complete ===")


## Example showing the if-else pattern for handling pieces
func example_if_else_pattern(piece_type: String, character_id: int, is_held: bool):
	"""
	This function demonstrates the if-else pattern for handling
	PNG vs scene-based pieces.
	"""

	# Check if the piece is scene-based or PNG-based
	if ChessPieceSprite.is_scene_based_piece(piece_type, character_id, is_held):
		# SCENE-BASED PIECE (like white_knight)
		print("Loading scene-based piece: %s" % piece_type)
		var piece_node = ChessPieceSprite.create_piece_sprite(piece_type, character_id, is_held)

		# Scene-based pieces have built-in effects, animations, and particles
		# No need to add additional visual effects
		add_child(piece_node)

	else:
		# PNG-BASED PIECE (standard for most pieces)
		print("Loading PNG-based piece: %s" % piece_type)
		var piece_node = ChessPieceSprite.create_piece_sprite(piece_type, character_id, is_held)

		# PNG-based pieces are simple Sprite2D nodes
		# You can add effects, animations, or shaders here
		add_child(piece_node)

		# Example: Add a simple scale animation
		var tween = create_tween()
		tween.tween_property(piece_node, "scale", Vector2(1.2, 1.2), 0.5)
		tween.tween_property(piece_node, "scale", Vector2(1.0, 1.0), 0.5)
