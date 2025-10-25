#!/usr/bin/env python3
"""
Generate placeholder PNG images for missing chess game assets.
This creates simple colored rectangles with text labels to serve as placeholders
until the actual artwork is provided.
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_placeholder(width, height, text, filename, bg_color=(200, 200, 200), text_color=(50, 50, 50)):
    """
    Create a placeholder image with centered text.

    Args:
        width: Image width in pixels
        height: Image height in pixels
        text: Text to display on the image
        filename: Output filename
        bg_color: Background color as RGB tuple
        text_color: Text color as RGB tuple
    """
    # Create image with light gray background
    img = Image.new('RGBA', (width, height), bg_color + (255,))
    draw = ImageDraw.Draw(img)

    # Try to use a larger font, fall back to default if not available
    try:
        font_size = min(width, height) // 10
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except:
        font = ImageFont.load_default()

    # Draw centered text
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (width - text_width) / 2
    y = (height - text_height) / 2

    # Draw border
    border_width = max(2, min(width, height) // 100)
    draw.rectangle([border_width, border_width, width - border_width, height - border_width],
                   outline=text_color, width=border_width)

    # Draw text
    draw.text((x, y), text, fill=text_color, font=font)

    # Ensure directory exists
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    # Save image
    img.save(filename)
    print(f"Created: {filename}")

def main():
    base_path = "/home/user/chess-thesis/assets/characters"

    # Generate for all 3 characters
    for char_num in range(1, 4):
        char_path = f"{base_path}/character_{char_num}"

        # Character background (512x512)
        create_placeholder(
            512, 512,
            f"Character {char_num}\nBackground",
            f"{char_path}/backgrounds/character_background.png",
            bg_color=(180, 180, 200)
        )

        # Chessboard half background (1024x512)
        create_placeholder(
            1024, 512,
            f"Character {char_num} Board Background",
            f"{char_path}/backgrounds/chessboard_half.png",
            bg_color=(220, 200, 180)
        )

        # Chess pieces (256x256)
        pieces = ['king', 'queen', 'rook', 'bishop', 'knight', 'pawn']
        for piece in pieces:
            create_placeholder(
                256, 256,
                piece.upper(),
                f"{char_path}/pieces/white_{piece}.png",
                bg_color=(240, 240, 240)
            )

    print("\n✓ All placeholder images generated successfully!")
    print("\nGenerated files:")
    print("- 3 character_background.png (512x512)")
    print("- 3 chessboard_half.png (1024x512)")
    print("- 18 chess piece images (256x256)")
    print("\nYou can now replace these placeholders with your actual artwork.")

if __name__ == "__main__":
    main()
