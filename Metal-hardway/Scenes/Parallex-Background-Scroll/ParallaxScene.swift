//
//  ParallaxScene.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 08.01.25.
//

import Metal
import MetalKit
import simd

class ParallaxScene: MetalScene {
  let name = "Parallax"
  let vertexFunctionName = "parallaxVertexShader"
  let fragmentFunctionName = "parallaxFragmentShader"
  let screenSize = (width: 800, height: 450)
  
  var uniforms: ParallexUniforms = ParallexUniforms()

  private var backgroundTexture: MTLTexture?
  private var midgroundTexture: MTLTexture?
  private var foregroundTexture: MTLTexture?
  
  init(device: MTLDevice = MTLCreateSystemDefaultDevice()!) {
    self.backgroundTexture = TextureLoader.loadTexture(
      device: device,
      imageName: "cyberpunk_street_background"
    )
    self.midgroundTexture = TextureLoader.loadTexture(
      device: device,
      imageName: "cyberpunk_street_midground"
    )
    self.foregroundTexture = TextureLoader.loadTexture(
      device: device,
      imageName: "cyberpunk_street_foreground"
    )
  }
  
  func update() {
    uniforms.scrollingBack += 1.0
    uniforms.scrollingMid += 2.0
    uniforms.scrollingFore += 3.0
  }
  
  func handleTouch(_ position: CGPoint) {}
  
  func getTextures() -> [MTLTexture?] {
    [backgroundTexture, midgroundTexture, foregroundTexture]
  }
}
