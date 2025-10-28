# Live2D Cubism SDK for Native - Getting Started Guide

## What is Live2D Cubism SDK?

The Cubism SDK for Native allows you to integrate animated 2D characters (Live2D models) into your native applications. These characters can:
- Move smoothly with physics simulation (hair, clothes)
- Display facial expressions
- Sync lip movements with audio
- Respond to user interaction
- Play predefined animations

## Prerequisites

### Required Software

**For Windows:**
- Visual Studio 2015-2022
- CMake 3.16 or higher
- Git (optional)

**For macOS:**
- Xcode 16.3 or higher
- CMake 3.16 or higher

**For Linux:**
- GCC/Clang compiler
- CMake 3.16 or higher
- OpenGL development libraries

**For Android:**
- Android Studio
- Android NDK
- CMake

## SDK Structure Overview

```
CubismSdkForNative-5-r.4.1/
├── Core/           # Pre-compiled Live2D rendering engine
├── Framework/      # C++ framework for working with models
└── Samples/        # Example implementations for each platform
    ├── OpenGL/     # Cross-platform (Windows, Mac, Linux, iOS, Android)
    ├── D3D11/      # Windows DirectX 11
    ├── Metal/      # macOS/iOS native
    ├── Vulkan/     # Modern graphics API
    └── D3D9/       # Legacy Windows
```

## Quick Start: Running Your First Sample

### Step 1: Choose Your Platform

For beginners, we recommend starting with **OpenGL** samples as they work on most platforms.

### Step 2: Build the OpenGL Sample (Recommended)

#### On Windows:

```bash
cd Samples/OpenGL/Demo/proj.win.cmake
# Generate Visual Studio project
cmake .
# Open the generated .sln file in Visual Studio and build
```

#### On macOS:

```bash
cd Samples/OpenGL/Demo/proj.mac.cmake
# Generate Xcode project
cmake . -G Xcode
# Open the generated .xcodeproj and build
# OR build from command line:
cmake --build .
```

#### On Linux:

```bash
cd Samples/OpenGL/Demo/proj.linux.cmake
cmake .
make
# Run the demo
./Demo
```

### Step 3: Run the Demo

After building, you should see a window with animated Live2D characters. You can:
- **Click and drag** to interact with the character
- **Arrow keys** or **on-screen buttons** to switch between characters
- **Watch animations** play automatically

## Understanding the Included Models

The SDK comes with 7 sample characters in `Samples/Resources/`:
- **Haru** - Girl with short hair
- **Hiyori** - Girl in school uniform
- **Mao** - Girl with long hair
- **Mark** - Male character
- **Natori** - Girl with twin tails
- **Rice** - Chibi character
- **Wanko** - Dog character

Each character folder contains:
```
Haru/
├── haru.moc3               # Binary model file (the actual character)
├── haru.model3.json        # Model configuration
├── expressions/            # Facial expressions (JSON)
├── motions/                # Animations (JSON)
├── haru.2048/              # Texture files (PNG)
├── haru.physics3.json      # Physics settings (hair, clothing)
└── haru.pose3.json         # Pose constraints
```

## How to Use a Character in Your Project

### Basic Workflow

1. **Load the Model** - Read the `.model3.json` file
2. **Initialize Resources** - Load textures, motions, expressions
3. **Update Loop** - Update model parameters each frame
4. **Render** - Draw the character

### Example Code Structure

Here's a simplified example of how character integration works:

```cpp
#include "CubismFramework.hpp"
#include "Model/CubismUserModel.hpp"

// 1. Initialize Cubism Framework (do this once at startup)
void InitializeCubism() {
    CubismFramework::StartUp();
    CubismFramework::Initialize();
}

// 2. Load a model
class MyCharacter : public CubismUserModel {
public:
    void LoadModel(const char* modelJsonPath) {
        // Load model from .model3.json file
        LoadAssets(modelJsonPath);
    }

    void Update(float deltaTime) {
        // Update model state
        GetModel()->Update();
    }

    void Draw() {
        // Render the character
        GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->DrawModel();
    }
};

// 3. In your game loop
void GameLoop() {
    MyCharacter* character = new MyCharacter();
    character->LoadModel("Resources/Haru/haru.model3.json");

    while (running) {
        float deltaTime = CalculateDeltaTime();

        // Update
        character->Update(deltaTime);

        // Render
        glClear(GL_COLOR_BUFFER_BIT);
        character->Draw();
        SwapBuffers();
    }
}

// 4. Cleanup (at shutdown)
void Shutdown() {
    CubismFramework::Dispose();
}
```

## Key Concepts

### 1. Parameters
Parameters control character features like:
- Eye opening/closing
- Mouth shape
- Head rotation (X, Y, Z)
- Body position

```cpp
// Set parameter value (0.0 to 1.0 typically)
model->SetParameterValue("ParamAngleX", 30.0f);  // Turn head right
model->SetParameterValue("ParamEyeLOpen", 0.5f); // Half-close left eye
```

### 2. Motions
Motions are predefined animations stored in JSON files.

```cpp
// Load and play a motion
ACubismMotion* motion = LoadMotion("motions/idle_01.motion3.json");
motionManager->StartMotion(motion, false, userTimeSeconds);
```

### 3. Expressions
Expressions are sets of parameter changes for facial emotions.

```cpp
// Load and set expression
ACubismMotion* expression = LoadExpression("expressions/angry.exp3.json");
expressionManager->StartMotion(expression, false, userTimeSeconds);
```

### 4. Physics
Physics automatically moves parts like hair and clothes based on movement.

```cpp
// Update physics simulation
physics->Evaluate(model, deltaTime);
```

### 5. Eye Blink
Automatic eye blinking for natural appearance.

```cpp
// Update eye blink (call every frame)
eyeBlink->UpdateParameters(model, deltaTime);
```

### 6. Lip Sync
Synchronize mouth movement with audio.

```cpp
// Update lip sync with audio volume
lipSync->UpdateParameters(model, audioVolume, deltaTime);
```

## Step-by-Step: Adding Your Own Character

### Option 1: Use Existing Sample Characters

The easiest way is to use the included sample models:

1. Copy the model folder (e.g., `Samples/Resources/Haru/`)
2. Modify the sample code to load your chosen character
3. Experiment with different motions and expressions

### Option 2: Create Your Own Character

You'll need **Live2D Cubism Editor** (separate software):

1. **Download Cubism Editor** from Live2D official website
2. **Create or import artwork** (PSD file with separated layers)
3. **Rig the model** in Cubism Editor (set up meshes, deformers, parameters)
4. **Export as .moc3** file with:
   - Model file (.moc3)
   - Model JSON (.model3.json)
   - Textures (.png)
   - Optional: physics, poses, motions, expressions

5. **Place exported files** in your project's Resources folder
6. **Load in your application** using the SDK

### Option 3: Download Free Models

- Live2D official website offers free sample models
- Community sites like BOOTH.pm have free/paid models (check license!)
- VTuber model websites

## Platform-Specific Guides

### For Godot Integration

If you're using Godot Engine (based on your project), you might want to:

1. Build the SDK as a shared library
2. Create a GDNative/GDExtension wrapper
3. Load Live2D models as custom resources

**Note**: There are existing Godot plugins for Live2D you might want to explore first.

### For Unity or Unreal Engine

Live2D provides separate SDKs specifically for Unity and Unreal Engine which are easier to use than the native SDK.

## Common Tasks

### Switch Between Characters

```cpp
// Unload current model
currentCharacter->Release();

// Load new character
currentCharacter->LoadModel("Resources/Hiyori/hiyori.model3.json");
```

### Play Random Idle Animations

```cpp
if (!motionManager->IsFinished()) {
    // Previous motion still playing
} else {
    // Pick random idle motion
    int randomIndex = rand() % idleMotionCount;
    LoadAndStartMotion("motions/idle_" + to_string(randomIndex) + ".motion3.json");
}
```

### Make Character Follow Mouse

```cpp
// Get mouse position in screen space
float mouseX = GetMouseX();
float mouseY = GetMouseY();

// Convert to model coordinate space (-1 to 1)
float normalizedX = (mouseX / screenWidth) * 2.0f - 1.0f;
float normalizedY = -((mouseY / screenHeight) * 2.0f - 1.0f);

// Set head tracking parameters
model->SetParameterValue("ParamAngleX", normalizedX * 30.0f);
model->SetParameterValue("ParamAngleY", normalizedY * 30.0f);
model->SetParameterValue("ParamBodyAngleX", normalizedX * 10.0f);
```

### Trigger Expression on Click

```cpp
if (mouseClicked) {
    // Play surprised expression
    LoadAndStartExpression("expressions/surprised.exp3.json");
}
```

## Recommended Learning Path

1. **Week 1**: Build and run OpenGL sample, explore the demo
2. **Week 2**: Read through sample code in `Samples/OpenGL/Demo/proj.*/src/`
3. **Week 3**: Modify sample to add custom interactions
4. **Week 4**: Experiment with different motions and expressions
5. **Week 5**: Try integrating into your own project

## Important Files to Study

### Sample Code (OpenGL):
- `Samples/OpenGL/Demo/proj.*/src/LAppModel.cpp` - Model loading and management
- `Samples/OpenGL/Demo/proj.*/src/LAppLive2DManager.cpp` - Managing multiple models
- `Samples/OpenGL/Demo/proj.*/src/LAppView.cpp` - Rendering and interaction

### Framework Headers:
- `Framework/src/CubismFramework.hpp` - Main framework initialization
- `Framework/src/Model/CubismUserModel.hpp` - Base class for your models
- `Framework/src/Motion/CubismMotionManager.hpp` - Motion playback
- `Framework/src/Physics/CubismPhysics.hpp` - Physics simulation

## Troubleshooting

### Build Errors

**Missing GLFW/GLEW:**
- The SDK includes third-party libraries in `Samples/Thirdparty/`
- Make sure CMake can find them

**Shader errors:**
- Ensure shader files are copied to output directory
- Check `Samples/OpenGL/Demo/proj.*/scripts/` for setup scripts

### Runtime Errors

**Model not loading:**
- Check file paths are correct
- Ensure all referenced files (.moc3, textures, motions) exist
- Verify .model3.json references correct file names

**Character appears black:**
- Texture files might not be loaded
- Check texture paths in .model3.json

**No animation:**
- Call `model->Update()` every frame
- Ensure delta time is being passed correctly

## Resources

### Documentation:
- Main README: `README.md`
- Platform READMEs: `Samples/[Platform]/README.md`
- Framework docs: `Framework/README.md`

### Official Resources:
- Live2D Official: https://www.live2d.com/
- SDK Manual: https://docs.live2d.com/
- Community Forum: https://community.live2d.com/

### Sample Models Location:
- `Samples/Resources/Haru/`
- `Samples/Resources/Hiyori/`
- `Samples/Resources/Mao/`
- etc.

## Next Steps

1. **Build the OpenGL sample** following the instructions above
2. **Explore the demo** and interact with characters
3. **Read the sample code** to understand how it works
4. **Experiment with modifications** to learn the API
5. **Check platform-specific READMEs** for detailed build instructions

## License Note

The Live2D Cubism SDK is free for small-scale and personal projects. For commercial use or publishing applications, check the Live2D licensing terms:
- Free for development and testing
- Small indie games may qualify for free license
- Large commercial projects require a paid license

See `LICENSE.md` and `NOTICE.md` for full details.

---

**Happy character animating! If you have questions, check the sample code first - it's the best teacher!**
