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
		"piece_style": "classic"
	},
	{
		"name": "Character 2",
		"description": "Second playable character",
		"piece_style": "modern"
	},
	{
		"name": "Character 3",
		"description": "Third playable character",
		"piece_style": "fantasy"
	},
	{
		"name": "Character 4 (Scyka)",
		"description": "Live2D character with mystical theme",
		"piece_style": "mystical"
	},
	{
		"name": "Character 5 (Hiyori)",
		"description": "Live2D character with elegant theme",
		"piece_style": "elegant"
	},
	{
		"name": "Character 6 (Mark)",
		"description": "Live2D character with cool theme",
		"piece_style": "professional"
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
