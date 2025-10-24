extends Button
class_name VisualChessPiece

var piece_data: ChessPiece
var board_position: Vector2i

signal piece_clicked(piece: VisualChessPiece)

func _ready():
	custom_minimum_size = Vector2(40, 40)
	flat = true
	pressed.connect(_on_pressed)

func setup(piece: ChessPiece):
	piece_data = piece
	board_position = piece.position
	update_display()

func update_display():
	if piece_data:
		text = piece_data.get_piece_symbol()

		# Style based on character theme
		var style_colors = {
			"classic": {"white": Color(1, 1, 1), "black": Color(0.2, 0.2, 0.2)},
			"modern": {"white": Color(0.8, 0.9, 1), "black": Color(0.1, 0.2, 0.4)},
			"fantasy": {"white": Color(1, 0.9, 0.7), "black": Color(0.4, 0.1, 0.3)}
		}

		var style = piece_data.character_style
		if not style in style_colors:
			style = "classic"

		var color_key = "white" if piece_data.piece_color == ChessPiece.PieceColor.WHITE else "black"

		# Create a StyleBoxFlat for the button
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0, 0, 0, 0)  # Transparent background
		add_theme_stylebox_override("normal", style_box)
		add_theme_stylebox_override("hover", style_box)
		add_theme_stylebox_override("pressed", style_box)

		# Set text color
		add_theme_color_override("font_color", style_colors[style][color_key])
		add_theme_color_override("font_hover_color", style_colors[style][color_key].lightened(0.2))
		add_theme_color_override("font_pressed_color", style_colors[style][color_key].darkened(0.2))

		# Set font size
		add_theme_font_size_override("font_size", 36)

func _on_pressed():
	piece_clicked.emit(self)

func highlight(enable: bool):
	if enable:
		var highlight_style = StyleBoxFlat.new()
		highlight_style.bg_color = Color(1, 1, 0, 0.3)
		highlight_style.border_color = Color(1, 1, 0, 1)
		highlight_style.border_width_left = 2
		highlight_style.border_width_right = 2
		highlight_style.border_width_top = 2
		highlight_style.border_width_bottom = 2
		add_theme_stylebox_override("normal", highlight_style)
	else:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0, 0, 0, 0)
		add_theme_stylebox_override("normal", style_box)
