//
//  MetalRenderer.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 07.01.25.
//

import MetalKit
import Metal
import simd

class UnifiedRenderer: NSObject, MTKViewDelegate {
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private var pipelineStates: [String: MTLRenderPipelineState] = [:]
  private var currentScene: MetalScene
  private var debugLabel: UILabel?
  
  init?(metalView: MTKView, initialScene: MetalScene) {
    guard let device = MTLCreateSystemDefaultDevice(),
          let commandQueue = device.makeCommandQueue() else {
      return nil
    }
    
    self.device = device
    self.commandQueue = commandQueue
    self.currentScene = initialScene
    
    metalView.device = device
    metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    metalView.colorPixelFormat = .bgra8Unorm
    
    // Setup debug label
    let label = UILabel(frame: CGRect(x: 100, y: -100, width: 200, height: 100))
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 14)
    label.textColor = .white
    label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    metalView.addSubview(label)
    
    super.init()
    
    self.debugLabel = label
    setupPipelines(metalView: metalView)
    metalView.delegate = self
  }
  
  private func setupPipelines(metalView: MTKView) {
    let scenes = [currentScene]  // Add more scenes as needed
    
    for scene in scenes {
      let pipelineDescriptor = MTLRenderPipelineDescriptor()
      pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
      
      guard let library = device.makeDefaultLibrary(),
            let vertexFunction = library.makeFunction(name: scene.vertexFunctionName),
            let fragmentFunction = library.makeFunction(name: scene.fragmentFunctionName) else {
        print("Failed to create functions for scene: \(scene.name)")
        continue
      }
      
      pipelineDescriptor.vertexFunction = vertexFunction
      pipelineDescriptor.fragmentFunction = fragmentFunction
      
      do {
        let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        pipelineStates[scene.name] = pipelineState
      } catch {
        print("Failed to create pipeline state for \(scene.name): \(error)")
      }
    }
  }
  
  func switchScene(to scene: MetalScene) {
    currentScene = scene
    if pipelineStates[scene.name] == nil {
      setupPipelines(metalView: MTKView())  // Create pipeline for new scene
    }
  }
  
  // MARK: - MTKViewDelegate
  
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
  
  func draw(in view: MTKView) {
    guard let commandBuffer = commandQueue.makeCommandBuffer(),
          let descriptor = view.currentRenderPassDescriptor,
          let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
          let pipelineState = pipelineStates[currentScene.name] else {
      return
    }
    
    currentScene.update()
    
    encoder.setRenderPipelineState(pipelineState)
    
    // Handle different scene types
    if let parallaxScene = currentScene as? ParallaxScene {
      // Set uniforms and textures for parallax scene
      var uniforms = parallaxScene.uniforms
      encoder.setFragmentBytes(&uniforms,
                               length: MemoryLayout<ParallexUniforms>.stride,
                               index: 0)
      
      let textures = parallaxScene.getTextures()
      for (index, texture) in textures.enumerated() {
        encoder.setFragmentTexture(texture, index: index)
      }
    } else if let lightingScene = currentScene as? PixelLightingScene {
      // Set uniforms for lighting scene
      var uniforms = lightingScene.uniforms
      encoder.setVertexBytes(&uniforms,
                             length: MemoryLayout<PixelLightingUniforms>.stride,
                             index: 1)
      encoder.setFragmentBytes(&uniforms,
                               length: MemoryLayout<PixelLightingUniforms>.stride,
                               index: 0)
    }
    
    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    encoder.endEncoding()
    
    if let drawable = view.currentDrawable {
      commandBuffer.present(drawable)
    }
    
    commandBuffer.commit()
  }
  
  func updateMousePosition(_ position: CGPoint) {
    currentScene.handleTouch(position)
  }
}
