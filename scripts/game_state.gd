extends Node

# Character selections
var player1_character: int = -1
var player2_character: int = -1

# Game state
var player1_score: int = 0
var player2_score: int = 0
var move_count: int = 0
var captured_pieces: int = 0

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
