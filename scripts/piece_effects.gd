extends Node

# ============================================================================
# CHESS PIECE HELD EFFECTS SYSTEM - SCENE-BASED
# ============================================================================
# This script manages visual effects for chess pieces when held/dragged.
# It uses scene-based held pieces (like hovereffect_scyka.tscn) which contain
# their own built-in animations, particles, and visual effects.
#
# USAGE:
# 1. Add this script as an autoload singleton in Project Settings
# 2. Call PieceEffects.apply_drag_effects(piece_node, piece_data) when drag starts
# 3. Call PieceEffects.remove_drag_effects(piece_node) when drag ends
#
# SCENE-BASED HELD PIECES:
# - Create scene files in: assets/characters/character_X/pieces/held/white_TYPE/scene/
# - Scenes can contain animations, particles, shaders, and any visual effects
# - Example: assets/characters/character_4/pieces/held/white_knight/scene/hovereffect_scyka.tscn
# ============================================================================

# Store original piece nodes for restoration
var original_piece_nodes = {}

# ============================================================================
# MAIN EFFECT FUNCTIONS
# ============================================================================

func apply_drag_effects(piece_node: Node, piece_data: Dictionary = {}):
	"""
	Swaps the piece to its scene-based held version (if available).
	The scene-based version contains built-in animations and effects.

	Args:
		piece_node: The current piece node (Node2D container with sprite/scene)
		piece_data: Dictionary with piece info (type, color, character_id)
	"""
	if not piece_node:
		return

	# Get piece information
	var piece_type = piece_data.get("type", "").to_lower()
	var character_id = piece_data.get("character_id", 1)

	if piece_type == "":
		return

	print("[PieceEffects] Applying held effect for %s (Character %d)" % [piece_type, character_id])

	# Check if a scene-based held piece exists
	if ChessPieceSprite.is_scene_based_piece(piece_type, character_id, true):
		# Store the original piece node
		original_piece_nodes[piece_node] = {
			"children": piece_node.get_children().duplicate(),
			"piece_type": piece_type,
			"character_id": character_id
		}

		# Remove existing children (the board piece)
		for child in piece_node.get_children():
			piece_node.remove_child(child)
			child.queue_free()

		# Create and add the held piece scene
		var held_scene_path = ChessPieceSprite.find_piece_scene(piece_type, character_id, true)
		if held_scene_path != "":
			var held_scene = load(held_scene_path)
			if held_scene:
				var scene_instance = held_scene.instantiate()
				scene_instance.name = "%sHeldScene" % piece_type.capitalize()
				piece_node.add_child(scene_instance)
				print("[PieceEffects] ✓ Swapped to scene-based held piece: %s" % held_scene_path)
			else:
				push_error("[PieceEffects] ✗ Failed to load held scene: %s" % held_scene_path)
	else:
		print("[PieceEffects] No scene-based held piece found for %s (Character %d)" % [piece_type, character_id])

func remove_drag_effects(piece_node: Node):
	"""
	Removes the held piece scene and restores the original board piece.

	Args:
		piece_node: The piece node to restore
	"""
	if not piece_node:
		return

	# Check if we stored the original for this piece
	if piece_node in original_piece_nodes:
		var stored_data = original_piece_nodes[piece_node]
		var piece_type = stored_data["piece_type"]
		var character_id = stored_data["character_id"]

		# Remove the held scene children
		for child in piece_node.get_children():
			piece_node.remove_child(child)
			child.queue_free()

		# Recreate the original board piece
		var board_piece = ChessPieceSprite.create_piece_sprite(piece_type, character_id, false)

		# Transfer the children from the recreated board piece to our piece_node
		for child in board_piece.get_children():
			board_piece.remove_child(child)
			piece_node.add_child(child)

		# Clean up the temporary container
		board_piece.queue_free()

		# Clean up stored data
		original_piece_nodes.erase(piece_node)

		print("[PieceEffects] ✓ Restored original board piece for %s" % piece_type)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

func get_piece_data_from_node(piece_node: Node) -> Dictionary:
	"""
	Extracts piece information from metadata.
	Helper function to get piece type, color, character_id.
	"""
	var data = {}

	# Try to get from metadata
	if piece_node.has_meta("piece_type"):
		data["type"] = piece_node.get_meta("piece_type")
	if piece_node.has_meta("piece_color"):
		data["color"] = piece_node.get_meta("piece_color")
	if piece_node.has_meta("character_id"):
		data["character_id"] = piece_node.get_meta("character_id")

	return data
