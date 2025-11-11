extends Node

# Character selections
var player1_character: int = -1
var player2_character: int = -1

# Player names (username support)
var player1_name: String = ""
var player2_name: String = ""

# Game state
var player1_score: int = 0
var player2_score: int = 0
var move_count: int = 0
var captured_pieces: int = 0

# Timer settings (in seconds, 0 means no timer)
var player_time_limit: int = 0  # Time limit per player in seconds
var player1_time_remaining: float = 0.0
var player2_time_remaining: float = 0.0

# Move history for game summary
var move_history: Array = []
var game_result: String = ""  # "white_win", "black_win", "draw", "stalemate", ""

# Character data - can be expanded with more details
var character_data = [
	{
		"name": "Character 1",
		"description": "First playable character",
		"piece_style": "classic",
		"board_light_color": Color(0.93, 0.85, 0.71, 0.7),  # Beige/cream
		"board_dark_color": Color(0.55, 0.42, 0.29, 0.7)   # Warm brown
	},
	{
		"name": "Character 2",
		"description": "Second playable character",
		"piece_style": "modern",
		"board_light_color": Color(0.85, 0.92, 0.95, 0.7),  # Light cyan/blue
		"board_dark_color": Color(0.35, 0.50, 0.60, 0.7)   # Steel blue
	},
	{
		"name": "Character 3",
		"description": "Third playable character",
		"piece_style": "fantasy",
		"board_light_color": Color(0.95, 0.85, 0.60, 0.7),  # Golden yellow
		"board_dark_color": Color(0.65, 0.35, 0.25, 0.7)   # Rich red-brown
	},
	{
		"name": "Character 4 (Scyka)",
		"description": "Live2D character with mystical theme",
		"piece_style": "mystical",
		"board_light_color": Color(0.75, 0.65, 0.85, 0.7),  # Light purple/lavender
		"board_dark_color": Color(0.45, 0.35, 0.55, 0.7)   # Dark purple
	}
]

func _ready():
	print("GameState initialized")

func reset_game():
	player1_score = 0
	player2_score = 0
	move_count = 0
	captured_pieces = 0
	move_history = []
	game_result = ""
	# Reset timer to configured limit
	if player_time_limit > 0:
		player1_time_remaining = float(player_time_limit)
		player2_time_remaining = float(player_time_limit)
	else:
		player1_time_remaining = 0.0
		player2_time_remaining = 0.0

func reset_selections():
	player1_character = -1
	player2_character = -1

func get_character_name(character_id: int) -> String:
	if character_id >= 0 and character_id < character_data.size():
		return character_data[character_id]["name"]
	return "Unknown"

func get_character_piece_style(character_id: int) -> String:
	if character_id >= 0 and character_id < character_data.size():
		return character_data[character_id]["piece_style"]
	return "classic"

func get_character_board_colors(character_id: int) -> Dictionary:
	"""
	Returns the board colors for a given character.

	Args:
		character_id: The ID of the character (0-3)

	Returns:
		A dictionary with "light" and "dark" Color values
	"""
	if character_id >= 0 and character_id < character_data.size():
		return {
			"light": character_data[character_id]["board_light_color"],
			"dark": character_data[character_id]["board_dark_color"]
		}
	# Default to Character 4's mystical purple theme
	return {
		"light": Color(0.75, 0.65, 0.85, 0.7),
		"dark": Color(0.45, 0.35, 0.55, 0.7)
	}

func get_player_display_name(player_number: int) -> String:
	"""
	Returns the display name for a player.
	Uses username if available, otherwise returns "Player 1" or "Player 2".

	Args:
		player_number: 1 for player 1 (white), 2 for player 2 (black)

	Returns:
		The display name for the player
	"""
	if player_number == 1:
		return player1_name if player1_name != "" else "Player 1"
	elif player_number == 2:
		return player2_name if player2_name != "" else "Player 2"
	return "Unknown Player"
