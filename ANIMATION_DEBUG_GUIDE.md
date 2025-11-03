# Animation Debug Guide for model_test

This guide explains how to use the enhanced debugging features added to `model_test.gd` to diagnose why `check` and `piece_captured` animations may not be playing.

## Overview

The debugger has been enhanced to provide detailed logging at multiple levels:
1. **Button press level** - Verifies the button callback is triggered
2. **Model validation level** - Checks if the Live2D model is valid
3. **Animation config level** - Verifies animation configuration is loaded
4. **File path level** - Confirms motion files exist on disk
5. **API call level** - Logs the actual GDCubism API calls

## How to Use the Debugger

### Step 1: Run the model_test Scene

1. Open the project in Godot
2. Run the `model_test.tscn` scene (located in `scenes/sandbox/`)
3. Open the Output console (bottom panel in Godot)

### Step 2: Test the Animations

Click the following buttons and observe the console output:
- **Idle Animation** - Should work (baseline test)
- **Piece Captured** - The animation we're debugging
- **Check** - The animation we're debugging

### Step 3: Analyze the Debug Output

The debug output will show:

```
============================================================
DEBUG: piece_captured button pressed
============================================================
✓ current_model exists: <GDCubismUserModel#...>
✓ current_model has start_motion method
✓ current_model has start_motion_loop method
Animation data: { motion_file: "Shock (Been Eated)", ... }
Motion file name: 'Shock (Been Eated)'
Looking for motion file at: res://assets/characters/character_4/Shock (Been Eated).motion3.json
Motion file exists: true
Animation params: { group: 0, priority: 0, fade_in: false, loop: false }

>>> Live2DAnimationConfig.play_animation() called
    action: 'piece_captured', character_id: 4
    ✓ live2d_model is valid: <GDCubismUserModel#...>
    ✓ start_motion method exists
    ✓ start_motion_loop method exists
    Motion file from config: 'Shock (Been Eated)'
    ✓ Motion file name is valid
    Animation params:
      - group: 0
      - priority: 0
      - loop: false
      - fade_in: false
    Full motion path: res://assets/characters/character_4/Shock (Been Eated).motion3.json
    Motion file exists on disk: true
    Calling start_motion_loop with:
      1. motion_file: 'Shock (Been Eated)'
      2. group: 0
      3. priority: 0
      4. loop: false
      5. fade_in: false
    start_motion_loop returned: <return_value>
<<< Live2DAnimationConfig.play_animation() complete

Animation play result: SUCCESS
============================================================
```

## Common Issues to Look For

### Issue 1: Motion File Path Problem

**Symptom:**
```
Motion file exists: false
```

**Cause:** The motion file name in `animations.json` doesn't match the actual file name on disk.

**Solution:**
1. Check the actual filename: `ls assets/characters/character_4/`
2. Verify the "motion_file" field in `animations.json` matches exactly (including spaces and case)
3. Current files:
   - `Shock (Been Eated).motion3.json` ✓
   - Config specifies: `"Shock (Been Eated)"` ✓

### Issue 2: Priority Conflict

**Symptom:**
- Debug shows `SUCCESS` but animation doesn't play
- `start_motion_loop returned: <some_value>`

**Cause:** The current idle animation has a higher priority than the new animation.

**Check:**
- Idle animation priority: `2`
- piece_captured priority: `0`
- check priority: `1`

**Solution:** In GDCubism, priority `0` is the HIGHEST priority. Your configuration is correct:
- `piece_captured` uses priority `0` (highest - should override anything)
- `check` uses priority `1` (high - should override idle)
- `idle` uses priority `2` (normal - lowest of the three)

**If animations still don't play**, the issue might be:
1. The priority system works opposite to what we expect
2. The `fade_in: false` is causing issues
3. The GDCubism extension requires a specific API call pattern

### Issue 3: GDCubism API Signature Mismatch

**Symptom:**
- Debug shows all checks pass
- `start_motion_loop` is called
- But no visible animation

**Possible Causes:**
1. **Wrong argument order** - The GDCubism API might expect arguments in a different order
2. **Wrong method** - Should use `start_motion()` instead of `start_motion_loop()`
3. **Motion file format** - Need to pass full path vs. just filename

**To investigate:**
Check the GDCubism documentation:
- Look in `gd_cubism-0.9.1/docs-src/modules/ROOT/pages/en/api/gd_cubism_user_model.adoc`
- Check method signatures in `gd_cubism-0.9.1/src/gd_cubism_user_model.hpp`

### Issue 4: Animation Transition Conflict

**Symptom:**
- Animation plays briefly then immediately switches back to idle
- `motion_finished` signal fires immediately

**Cause:** The animation transition system is interfering.

**Check the console for:**
```
Motion finished for animation: piece_captured
Transitioning to: idle (delay: 0.3s)
```

**If this happens too quickly**, the animation might be:
1. Too short (check the .motion3.json file)
2. Not loading properly (corrupt file)
3. Being cancelled by another animation

### Issue 5: Loop Setting Issue

**Symptom:**
- Animation plays once and stops
- No transition back to idle

**Current Settings:**
- `piece_captured`: `loop: false` ✓ (correct - should play once)
- `check`: `loop: false` ✓ (correct - should play once)

**Expected Behavior:**
1. Animation plays once
2. `motion_finished` signal fires
3. Transitions back to idle after 0.3s delay

## Debugging the GDCubism API

If all checks pass but animation still doesn't play, you may need to:

### 1. Check GDCubism Return Value

Look at the output line:
```
start_motion_loop returned: <value>
```

- If `null` or `0` or `false`: The call failed
- If `1` or `true` or an object: The call succeeded

### 2. Verify Method Signature

The current code calls:
```gdscript
live2d_model.start_motion_loop(motion_file, group, priority, loop, fade_in)
```

According to GDCubism docs, the correct signature might be:
```gdscript
start_motion(motion: String, group: int, priority: int) -> int
```
or
```gdscript
start_motion_loop(motion: String, group: int, priority: int, loop: bool, loop_fade_in: bool) -> int
```

### 3. Check for Error Messages

Look for GDCubism-specific errors in the console:
- "Motion not found"
- "Invalid motion group"
- "Failed to load motion"

## Alternative Test: Use start_motion Instead

If `start_motion_loop` doesn't work, try using the simpler `start_motion()` method:

```gdscript
# In live2d_animation_config.gd, replace start_motion_loop with:
live2d_model.start_motion(motion_file, params["group"], params["priority"])
```

This might work if:
- The loop parameter is causing issues
- The fade_in parameter is incompatible
- Your GDCubism version doesn't support `start_motion_loop`

## Summary Checklist

When debugging, verify:
- [ ] Button press is detected (debug output starts)
- [ ] Model exists and is valid
- [ ] Model has required methods
- [ ] Animation config loads correctly
- [ ] Motion file name matches exactly
- [ ] Motion file exists on disk
- [ ] Animation parameters are correct
- [ ] Priority settings are appropriate
- [ ] `start_motion_loop` is called successfully
- [ ] Return value from `start_motion_loop` is checked
- [ ] No GDCubism errors in console
- [ ] Motion transition system works correctly

## Next Steps

After running the debugger:

1. **If motion file not found**: Fix the path or filename
2. **If priority conflict**: Adjust priority values
3. **If API call fails**: Check GDCubism documentation for correct method signature
4. **If animation plays but transitions immediately**: Check transition timing in `animations.json`
5. **If all else fails**: Try using `start_motion()` instead of `start_motion_loop()`

## Files Modified

The following files have enhanced debugging:
- `scripts/model_test.gd` - Button callbacks with detailed logging
- `scripts/live2d_animation_config.gd` - Animation playback with detailed logging

To remove debugging later, search for `print("DEBUG:` and `print(">>>` and remove those sections.
