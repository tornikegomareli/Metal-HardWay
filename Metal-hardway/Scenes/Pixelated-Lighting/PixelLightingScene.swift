//
//  PixelLightingScene.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 08.01.25.
//

import Metal
import MetalKit
import simd

class PixelLightingScene: MetalScene {
  let name = "PixelLighting"
  let vertexFunctionName = "pixelLightingVertexShader"
  let fragmentFunctionName = "pixelLightingFragmentShader"
  let screenSize = (width: 200, height: 200)
  
  var uniforms: Any { return self.lightingUniforms }
  
  private lazy var lightingUniforms: PixelLightingUniforms = {
    return PixelLightingUniforms(
      lightPosition: SIMD2<Float>(Float(screenSize.width)/2, Float(screenSize.height)/2),
      time: 0,
      intensity: 0.4,
      range: 0.95,
      bounceRate: 0.9,
      flickerRate: 4,
      flickerAmplitude: 0.003,
      globalIllumination: 0.03,
      obstaclePosition: SIMD2<Float>(Float(screenSize.width)/4, Float(screenSize.height)/4),
      obstacleSize: SIMD2<Float>(10, 10)
    )
  }()
  
  // Debug info
  private var lastTime: CFTimeInterval = 0
  private var frameCount: Int = 0
  private var fps: Double = 0
  
  init(device: MTLDevice = MTLCreateSystemDefaultDevice()!) {
  }
  
  func update() {
    lightingUniforms.time += 1.0/60.0
    
    // Update FPS
    let currentTime = CACurrentMediaTime()
    frameCount += 1
    
    if currentTime - lastTime >= 1.0 {
      fps = Double(frameCount) / (currentTime - lastTime)
      frameCount = 0
      lastTime = currentTime
    }
  }
  
  func handleTouch(_ position: CGPoint) {
    let x = Float(position.x) / Float(3)
    let y = Float(position.y) / Float(3)
    lightingUniforms.obstaclePosition = SIMD2<Float>(x, y)
  }
  
  func getDebugInfo() -> String {
    return """
       FPS: \(Int(fps))
       Light Position: (\(Int(lightingUniforms.lightPosition.x)), \(Int(lightingUniforms.lightPosition.y)))
       Time: \(String(format: "%.2f", lightingUniforms.time))
       Intensity: \(String(format: "%.2f", lightingUniforms.intensity))
       Range: \(String(format: "%.2f", lightingUniforms.range))
       Flicker Rate: \(String(format: "%.2f", lightingUniforms.flickerRate))
       Screen Size: \(screenSize.width)x\(screenSize.height)
       """
  }
  
  func getLightPosition() -> SIMD2<Float> {
    return lightingUniforms.lightPosition
  }
  
  func getObstaclePosition() -> SIMD2<Float> {
    return lightingUniforms.obstaclePosition
  }
}
