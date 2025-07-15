# Metal Hardway

A learning project exploring Metal framework capabilities through interactive graphics demonstrations on iOS/macOS.

## Overview

Metal Hardway is an educational project designed to learn and demonstrate various Metal framework features through practical, interactive scenes. Each scene showcases different aspects of GPU programming, from basic rendering to complex physics simulations.

## Available Scenes

### 1. **Sand Simulation** 
- Cellular automaton-based falling sand simulation
- Interactive particle spawning with touch/mouse input
- Realistic physics with gravity and collision detection
- GPU-accelerated compute shaders for particle physics
- Draw sand in the air, then release to watch it fall
- Sand particles form natural piles
- Optimized for thousands of particles

### 2. **Pixel Lighting**
- Real-time 2D pixel-perfect lighting system
- Dynamic light source that follows input
- Shadows and light bouncing effects
- Demonstrates fragment shader techniques
- Flickering light effects
- Obstacle shadows
- Adjustable light intensity and range

### 3. **Parallax Background**
- Multi-layer scrolling background effect
- Demonstrates texture sampling and movement
- Creates depth perception through layer speeds
- Shows efficient texture rendering techniques

## Technical Details

### Architecture
- **Unified Renderer**: Single rendering pipeline supporting multiple scenes
- **Scene Protocol**: Flexible scene system for easy addition of new demonstrations
- **Compute Shaders**: Used for physics calculations in sand simulation
- **Double Buffering**: Prevents visual artifacts and ensures smooth updates

### Technologies Used
- **Metal**: Apple's low-level graphics API
- **Swift**: Primary programming language
- **SwiftUI**: User interface framework
- **MetalKit**: Higher-level Metal utilities

### Project Structure
```
Metal-hardway/
├── Engine/
│   ├── Core/          # Core engine components
│   ├── Renderer/      # Unified rendering system
│   └── Shaders/       # Metal shader files
├── Scenes/
│   ├── Sand-Simulation/
│   ├── Pixelated-Lighting/
│   └── Parallex-Background-Scroll/
└── App/               # Application entry point
```

## Learning Goals

This project serves as a practical exploration of:
- GPU programming concepts
- Shader development (vertex, fragment, compute)
- Real-time physics simulation
- Performance optimization techniques
- Interactive graphics programming

## Requirements

- iOS 14.0+ / macOS 11.0+
- Xcode 13.0+
- Device with Metal support

## Getting Started

1. Clone the repository
2. Open `Metal-hardway.xcodeproj` in Xcode
3. Build and run on a Metal-capable device or simulator
4. Use the menu button to explore different scenes

## License

This is a learning project intended for educational purposes.

---

*Created as part of learning Metal framework the hard way - by building interactive demonstrations from scratch.*