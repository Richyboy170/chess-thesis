# Live2D JSON Animation Configuration System

This document describes the JSON-based animation configuration system for Live2D characters in the Chess Thesis project.

## Overview

The JSON animation configuration system allows you to define character animations in a declarative way using JSON files, instead of hardcoding animation names in the game code. This makes it easier to:

- **Add new animations** without modifying game code
- **Customize animations** per character
- **Define animation transitions** (e.g., win_enter → win_idle)
- **Support animation variants** (random selection from multiple animations)
- **Maintain consistency** across the codebase

## File Structure

Each Live2D character has an `animations.json` file in their character folder:

```
assets/characters/
├── character_4/               # Scyka (Character ID: 3)
│   ├── animations.json        # ← Animation configuration
│   ├── Scyka.model3.json
│   ├── Idle.motion3.json
│   ├── Win (Enter).motion3.json
│   └── ...
├── character_5/               # Hiyori (Character ID: 4)
│   ├── animations.json        # ← Animation configuration
│   ├── Hiyori.model3.json
│   └── motions/
│       ├── Hiyori_m01.motion3.json
│       └── ...
└── character_6/               # Mark (Character ID: 5)
    ├── animations.json        # ← Animation configuration
    ├── Mark.model3.json
    └── motions/
        ├── mark_m01.motion3.json
        └── ...
```

## JSON Schema

### Basic Structure

```json
{
  "character_name": "Scyka",
  "character_id": 3,
  "version": "1.0",
  "animations": {
    "action_name": {
      "motion_file": "Motion Name",
      "group": 0,
      "priority": 2,
      "fade_in": true,
      "loop": true,
      "description": "Description of what this animation does",
      "variants": ["Motion1", "Motion2", "Motion3"]  // Optional
    }
  },
  "default_animation": "idle",
  "animation_transitions": {
    "action_name": {
      "next_animation": "next_action",
      "delay": 0.5
    }
  }
}
```

### Field Descriptions

#### Root Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `character_name` | String | Yes | Human-readable character name |
| `character_id` | Integer | Yes | Character ID (3, 4, or 5) |
| `version` | String | Yes | Config file version |
| `animations` | Object | Yes | Dictionary of animation definitions |
| `default_animation` | String | Yes | Default animation to play (usually "idle") |
| `animation_transitions` | Object | No | Automatic animation transitions |

#### Animation Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `motion_file` | String | Yes | Name of the .motion3.json file (without extension) |
| `group` | Integer | Yes | Motion group (usually 0) |
| `priority` | Integer | Yes | Motion priority (0=highest, 2=idle) |
| `fade_in` | Boolean | Yes | Whether to fade in smoothly |
| `loop` | Boolean | Yes | Whether to loop the animation |
| `description` | String | No | Human-readable description |
| `variants` | Array | No | Array of motion file names for random selection |

#### Transition Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `next_animation` | String | Yes | Action name to transition to |
| `delay` | Float | Yes | Delay in seconds before transitioning |

### Standard Action Names

These action names are used throughout the game code:

| Action Name | Game Event | Description |
|-------------|------------|-------------|
| `idle` | Default state | Character idle/breathing animation |
| `hover_piece` | Hovering over chess piece | Subtle reaction animation |
| `select_piece` | Selecting chess piece | Piece selection reaction |
| `piece_captured` | Piece is captured | Shock/surprised reaction |
| `win_enter` | Game won | Victory celebration start |
| `win_idle` | After win_enter | Looping victory pose |
| `lose_enter` | Game lost | Defeat reaction |
| `lose_idle` | After lose_enter | Looping defeated pose |

## Example Configurations

### Character 4 (Scyka) - Fully Animated

Scyka has dedicated animation files for each action:

```json
{
  "character_name": "Scyka",
  "character_id": 3,
  "version": "1.0",
  "animations": {
    "idle": {
      "motion_file": "Idle",
      "group": 0,
      "priority": 2,
      "fade_in": true,
      "loop": true,
      "description": "Default idle breathing animation"
    },
    "piece_captured": {
      "motion_file": "Shock (Been Eated)",
      "group": 0,
      "priority": 0,
      "fade_in": false,
      "loop": false,
      "description": "When a piece is captured"
    },
    "win_enter": {
      "motion_file": "Win (Enter)",
      "group": 0,
      "priority": 0,
      "fade_in": false,
      "loop": false,
      "description": "Victory celebration start"
    },
    "win_idle": {
      "motion_file": "Win (Idle)",
      "group": 0,
      "priority": 2,
      "fade_in": true,
      "loop": true,
      "description": "Victory idle loop"
    }
  },
  "default_animation": "idle",
  "animation_transitions": {
    "win_enter": {
      "next_animation": "win_idle",
      "delay": 0.5
    },
    "piece_captured": {
      "next_animation": "idle",
      "delay": 0.3
    }
  }
}
```

### Character 5 (Hiyori) - Multiple Variants

Hiyori has numbered animations that can be mapped to game actions:

```json
{
  "character_name": "Hiyori",
  "character_id": 4,
  "version": "1.0",
  "animations": {
    "idle": {
      "motion_file": "Hiyori_m01",
      "group": 0,
      "priority": 2,
      "fade_in": true,
      "loop": true,
      "description": "Default idle animation",
      "variants": [
        "Hiyori_m01", "Hiyori_m02", "Hiyori_m03",
        "Hiyori_m05", "Hiyori_m06", "Hiyori_m07",
        "Hiyori_m08", "Hiyori_m09", "Hiyori_m10"
      ]
    },
    "piece_captured": {
      "motion_file": "Hiyori_m04",
      "group": 0,
      "priority": 0,
      "fade_in": false,
      "loop": false,
      "description": "TapBody animation"
    }
  },
  "default_animation": "idle"
}
```

## Code Usage

### GDScript API

The `Live2DAnimationConfig` class provides static methods for animation management:

```gdscript
# Load configuration (automatically cached)
var config = Live2DAnimationConfig.load_animation_config(character_id)

# Get animation data
var anim_data = Live2DAnimationConfig.get_animation(character_id, "idle")

# Get motion file name
var motion = Live2DAnimationConfig.get_motion_file(character_id, "win_enter")

# Play animation on a Live2D model
Live2DAnimationConfig.play_animation(live2d_model, character_id, "idle")

# Get animation parameters
var params = Live2DAnimationConfig.get_animation_params(character_id, "idle")
# Returns: {"group": 0, "priority": 2, "fade_in": true, "loop": true}

# Get transition info
var transition = Live2DAnimationConfig.get_animation_transition(character_id, "win_enter")
# Returns: {"next_animation": "win_idle", "delay": 0.5}

# Get random variant
var variant = Live2DAnimationConfig.get_random_variant(character_id, "idle")

# Clear cache (for hot-reloading)
Live2DAnimationConfig.clear_cache()
```

### Integration in Game Code

#### Loading a Character

```gdscript
# In main_game.gd
func load_live2d_character(display_node: Control, character_id: int) -> bool:
    var live2d_model = ClassDB.instantiate("GDCubismUserModel")
    live2d_model.assets = model_path

    # Store character ID for later animation triggers
    live2d_model.set_meta("character_id", character_id)

    # Start default animation using JSON config
    var default_action = Live2DAnimationConfig.get_default_animation(character_id)
    Live2DAnimationConfig.play_animation(live2d_model, character_id, default_action)

    display_node.add_child(live2d_model)
    return true
```

#### Playing Special Animations

```gdscript
# In play_special_animation()
func play_special_animation(display_node: Control, animation_type: String):
    var live2d_model = display_node.get_child(0)

    if live2d_model.has_method("start_motion"):
        var character_id = live2d_model.get_meta("character_id")

        # Map game event to action name
        var action = ""
        match animation_type:
            "character_victory":
                action = "win_enter"
            "character_defeat":
                action = "lose_enter"
            "piece_capture_effect":
                action = "piece_captured"

        # Play animation
        Live2DAnimationConfig.play_animation(live2d_model, character_id, action)

        # Handle automatic transition
        var transition = Live2DAnimationConfig.get_animation_transition(character_id, action)
        if not transition.is_empty():
            await get_tree().create_timer(transition["delay"]).timeout
            Live2DAnimationConfig.play_animation(
                live2d_model,
                character_id,
                transition["next_animation"]
            )
```

## Animation Priority System

The priority value determines which animation takes precedence:

| Priority | Use Case | Example |
|----------|----------|---------|
| 0 | Highest priority (game events) | Win, lose, piece captured |
| 1 | Medium priority (interactions) | Hover piece, select piece |
| 2 | Idle/default priority | Idle, breathing |

Lower numbers = higher priority. A priority 0 animation will interrupt any priority 1 or 2 animation.

## Animation Transitions

Transitions allow you to chain animations together automatically:

```json
"animation_transitions": {
  "win_enter": {
    "next_animation": "win_idle",
    "delay": 0.5
  }
}
```

This configuration will:
1. Play the "win_enter" animation
2. Wait 0.5 seconds after starting it
3. Automatically transition to "win_idle"

**Note:** Transitions are handled by the calling code, not automatically by the config loader.

## Adding New Animations

### Step 1: Add Animation File

Place your `.motion3.json` file in the character's folder:

```
assets/characters/character_4/
└── NewAnimation.motion3.json  ← Add your file here
```

### Step 2: Update animations.json

Add an entry to the `animations` object:

```json
{
  "animations": {
    "new_action": {
      "motion_file": "NewAnimation",
      "group": 0,
      "priority": 1,
      "fade_in": true,
      "loop": false,
      "description": "Description of new animation"
    }
  }
}
```

### Step 3: Trigger in Game Code

Use the action name in your game code:

```gdscript
Live2DAnimationConfig.play_animation(live2d_model, character_id, "new_action")
```

**No code changes required!** The animation system will automatically load and play your new animation.

## Troubleshooting

### Animation Not Playing

1. **Check the JSON file**: Ensure `animations.json` is valid JSON
2. **Verify motion_file name**: Must match the `.motion3.json` filename (without extension)
3. **Check character ID**: Must be 3, 4, or 5
4. **Check console output**: Look for error messages from `Live2DAnimationConfig`

### Common Issues

| Issue | Solution |
|-------|----------|
| `Animation 'X' not found` | Check spelling in `animations.json` |
| `Failed to parse JSON` | Validate JSON syntax |
| `Motion file not found` | Verify `.motion3.json` file exists |
| `Character ID not found` | Use character ID 3, 4, or 5 |

### Debug Output

Enable debug output by checking the console for messages like:

```
Live2DAnimationConfig: Loaded config for character 3 (Scyka)
Live2DAnimationConfig: Playing animation 'idle' (motion: Idle) on character 3
```

## Files Reference

| File | Description |
|------|-------------|
| `scripts/live2d_animation_config.gd` | Animation config loader class |
| `assets/characters/character_4/animations.json` | Scyka animation config |
| `assets/characters/character_5/animations.json` | Hiyori animation config |
| `assets/characters/character_6/animations.json` | Mark animation config |
| `scripts/main_game.gd` | Main game integration |
| `scripts/character_selection.gd` | Character preview integration |

## Version History

### Version 1.0 (2025-10-29)

- Initial implementation of JSON-based animation system
- Support for all Live2D characters (4, 5, 6)
- Animation transitions
- Animation variants
- Integration with main game and character selection

---

For more information about Live2D setup, see [LIVE2D_SETUP.md](LIVE2D_SETUP.md)
