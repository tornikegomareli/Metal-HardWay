//
//  MetalRenderer.swift
//  pixel-lighting-metal
//
//  Created by Tornike Gomareli on 07.01.25.
//

import MetalKit
import Metal
import simd

class MetalRenderer: NSObject, MTKViewDelegate {
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let pipelineState: MTLRenderPipelineState
  
  private var lastTime: CFTimeInterval = 0
  private var frameCount: Int = 0
  private var fps: Double = 0
  
  private var debugLabel: UILabel?
  
  private var uniforms: Uniforms = {
    return Uniforms(
      lightPosition: SIMD2<Float>(Float(Constants.screenWidth)/2, Float(Constants.screenHeight)/2),
      time: 0,
      intensity: 0.4,
      range: 0.95,
      bounceRate: 0.9,
      flickerRate: 4,
      flickerAmplitude: 0.003,
      globalIllumination: 0.03,
      obstaclePosition: SIMD2<Float>(Float(Constants.screenWidth)/4, Float(Constants.screenHeight)/4),
      obstacleSize: SIMD2<Float>(10, 10)
    )
  }()
  
  init?(metalView: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice(),
          let commandQueue = device.makeCommandQueue() else {
      return nil
    }
    
    self.device = device
    self.commandQueue = commandQueue
    
    metalView.device = device
    metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    metalView.colorPixelFormat = .bgra8Unorm
    
    let label = UILabel(frame: CGRect(x: 100, y: -100, width: 200, height: 100))
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 14)
    label.textColor = .white
    label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    
    metalView.addSubview(label)
    self.debugLabel = label
    
    guard let library = device.makeDefaultLibrary(),
          let vertexFunction = library.makeFunction(name: "vertexShader"),
          let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
      return nil
    }
    
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
    
    do {
      pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch {
      print("Failed to create pipeline state: \(error)")
      return nil
    }
    
    super.init()
    metalView.delegate = self
  }
  
  func updateDebugInfo() {
    let currentTime = CACurrentMediaTime()
    frameCount += 1
    
    if currentTime - lastTime >= 1.0 {
      fps = Double(frameCount) / (currentTime - lastTime)
      frameCount = 0
      lastTime = currentTime
    }
    
    let debugText = """
    FPS: \(Int(fps))
    Light Position: (\(Int(uniforms.lightPosition.x)), \(Int(uniforms.lightPosition.y)))
    Time: \(String(format: "%.2f", uniforms.time))
    Intensity: \(String(format: "%.2f", uniforms.intensity))
    Range: \(String(format: "%.2f", uniforms.range))
    Flicker Rate: \(String(format: "%.2f", uniforms.flickerRate))
    Screen Size: \(Constants.screenWidth)x\(Constants.screenHeight)
    Scale: \(Constants.scaleFactor)x
    """
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.debugLabel?.text = debugText
    }
  }
  
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
  }
  
  func draw(in view: MTKView) {
    guard let commandBuffer = commandQueue.makeCommandBuffer(),
          let descriptor = view.currentRenderPassDescriptor,
          let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
      return
    }
    
    updateDebugInfo()
    
    uniforms.time += 1.0/60.0
    
    uniforms.lightPosition = SIMD2<Float>(
      Float(Constants.screenWidth)/2,
      Float(Constants.screenHeight)/2
    )
    
    encoder.setRenderPipelineState(pipelineState)
    encoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
    encoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 0)
    
    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    
    encoder.endEncoding()
    
    if let drawable = view.currentDrawable {
      commandBuffer.present(drawable)
    }
    
    commandBuffer.commit()
  }
  
  func updateMousePosition(_ position: CGPoint) {
    let x = Float(position.x) / Float(Constants.scaleFactor)
    let y = Float(position.y) / Float(Constants.scaleFactor)
    uniforms.obstaclePosition = SIMD2<Float>(x, y)
  }
}
