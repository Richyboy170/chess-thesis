extends Control

@onready var chessboard = $MainContainer/GameArea/ChessboardContainer/MarginContainer/VBoxContainer/AspectRatioContainer/Chessboard
@onready var player1_character_label = $MainContainer/BottomPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/CharacterName
@onready var player2_character_label = $MainContainer/TopPlayerArea/MarginContainer/HBoxContainer/PlayerInfo/CharacterName

func _ready():
	setup_chessboard()
	update_character_displays()

func setup_chessboard():
	# Create 8x8 grid of chess squares
	for row in range(8):
		for col in range(8):
			var square = ColorRect.new()
			square.custom_minimum_size = Vector2(50, 50)

			# Alternate colors for chessboard pattern
			if (row + col) % 2 == 0:
				square.color = Color(0.9, 0.9, 0.8, 1)  # Light square
			else:
				square.color = Color(0.5, 0.4, 0.3, 1)  # Dark square

			chessboard.add_child(square)

func update_character_displays():
	# Update character names based on selection
	var character_names = ["Character 1", "Character 2", "Character 3"]

	if GameState.player1_character >= 0 and GameState.player1_character < character_names.size():
		player1_character_label.text = "Character: " + character_names[GameState.player1_character]

	if GameState.player2_character >= 0 and GameState.player2_character < character_names.size():
		player2_character_label.text = "Character: " + character_names[GameState.player2_character]

func _on_menu_button_pressed():
	# Return to character selection or main menu
	get_tree().change_scene_to_file("res://scenes/ui/login_page.tscn")
