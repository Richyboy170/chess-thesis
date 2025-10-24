extends Control

@onready var no_timer_button = $VBoxContainer/TimerSettings/TimerOptions/NoTimerButton
@onready var timer_5_button = $VBoxContainer/TimerSettings/TimerOptions/Timer5Button
@onready var timer_10_button = $VBoxContainer/TimerSettings/TimerOptions/Timer10Button
@onready var timer_15_button = $VBoxContainer/TimerSettings/TimerOptions/Timer15Button
@onready var timer_30_button = $VBoxContainer/TimerSettings/TimerOptions/Timer30Button

var timer_buttons: Array = []

func _ready():
	# Setup button group for timer selection
	timer_buttons = [no_timer_button, timer_5_button, timer_10_button, timer_15_button, timer_30_button]

	# Connect all timer buttons
	no_timer_button.pressed.connect(_on_timer_button_pressed.bind(0))
	timer_5_button.pressed.connect(_on_timer_button_pressed.bind(5))
	timer_10_button.pressed.connect(_on_timer_button_pressed.bind(10))
	timer_15_button.pressed.connect(_on_timer_button_pressed.bind(15))
	timer_30_button.pressed.connect(_on_timer_button_pressed.bind(30))

func _on_timer_button_pressed(minutes: int):
	# Unpress all other buttons
	for button in timer_buttons:
		button.button_pressed = false

	# Press the selected button
	match minutes:
		0:
			no_timer_button.button_pressed = true
		5:
			timer_5_button.button_pressed = true
		10:
			timer_10_button.button_pressed = true
		15:
			timer_15_button.button_pressed = true
		30:
			timer_30_button.button_pressed = true

	# Set timer in GameState (convert minutes to seconds)
	GameState.player_time_limit = minutes * 60

func _on_play_button_pressed():
	# Navigate to character selection
	get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")
