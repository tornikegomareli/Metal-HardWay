# Metal Pixel Lighting Renderer

A real-time 2D lighting system implemented using Metal, featuring dynamic light propagation, shadows, and interactive light source control.

<img src="https://github.com/tornikegomareli/Pixelated-Lighting-Metal/blob/main/resources/pixel-lighting-demo.gif" alt="Pixel Lighting Demo" width="600" height="800">

2D lighting system where light emanates from a movable source (represented by a red dot) and interacts with the environment. 
The implementation uses Metal for efficient GPU-based rendering and SwiftUI for the user interface.

**Shader Implementation (`PixelLightingShaders.metal`)**
  - Vertex Shader: Creates a full-screen quad for rendering
  - Fragment Shader: Implements the lighting algorithm


### How it Works

For each pixel I cast ray to the light source, stepping across roughly 100 points. 
If any sample collides with the rectangle, I mark the pixel as shadowed. Otherwise, brightness ramps down with distance,
but I stick with a simple linear falloff instead of the physically accurate inverse-square—visually, it’s not worth the extra overhead

I add flickering to simulate an unsteady light source and apply a basic global illumination pass to bring out more detail. 
I also soften the shadow edges by looking at how many of the 100 samples can actually reach the light.
It’s not physically perfect, but it still looks convincing and runs efficiently in real-time.

