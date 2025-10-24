extends Control

var player1_character = -1
var player2_character = -1

func _ready():
	update_start_button()

func _on_player1_character_selected(character_id: int):
	player1_character = character_id
	# Store in game state
	GameState.player1_character = character_id
	print("Player 1 selected character: ", character_id)
	update_start_button()
	# Visual feedback could be added here (highlight selected character)

func _on_player2_character_selected(character_id: int):
	player2_character = character_id
	# Store in game state
	GameState.player2_character = character_id
	print("Player 2 selected character: ", character_id)
	update_start_button()
	# Visual feedback could be added here (highlight selected character)

func update_start_button():
	var start_button = $VBoxContainer/ButtonContainer/StartButton
	start_button.disabled = (player1_character == -1 or player2_character == -1)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/login_page.tscn")

func _on_start_button_pressed():
	if player1_character != -1 and player2_character != -1:
		get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")
