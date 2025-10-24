extends Control

func _ready():
	# Make sure the button is properly sized
	pass

func _on_play_button_pressed():
	# Navigate to character selection
	get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")
