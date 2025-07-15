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
            
            // Configure for instanced rendering if cellular sand simulation
            if scene is CellularSandScene {
                let vertexDescriptor = MTLVertexDescriptor()
                pipelineDescriptor.vertexDescriptor = vertexDescriptor
            }
            
            do {
                let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
                pipelineStates[scene.name] = pipelineState
            } catch {
                print("Failed to create pipeline state for \(scene.name): \(error)")
            }
        }
    }
    
    func switchScene(to scene: MetalScene) {
        currentScene.willExitScene()
        
        currentScene = scene
        if pipelineStates[scene.name] == nil {
            // Create a temporary MTKView just for pipeline setup
            let tempView = MTKView(frame: .zero, device: device)
            tempView.colorPixelFormat = .bgra8Unorm
            setupPipelines(metalView: tempView)
        }
        
        currentScene.didEnterScene()
    }
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        currentScene.update()
        
        // Handle cellular sand simulation with compute shader
        if let cellularScene = currentScene as? CellularSandScene,
                  let computePipeline = cellularScene.getComputePipelineState(),
                  let gridBuffer = cellularScene.getGridBuffer(),
                  let nextGridBuffer = cellularScene.getNextGridBuffer() {
            
            // Run compute shader for cellular automaton
            if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
                computeEncoder.setComputePipelineState(computePipeline)
                computeEncoder.setBuffer(gridBuffer, offset: 0, index: 0)
                computeEncoder.setBuffer(nextGridBuffer, offset: 0, index: 1)
                
                var uniforms = cellularScene.uniforms as! CellularSandUniforms
                computeEncoder.setBytes(&uniforms,
                                       length: MemoryLayout<CellularSandUniforms>.stride,
                                       index: 2)
                
                let threadsPerGroup = MTLSize(width: 16, height: 16, depth: 1)
                let numThreadGroups = MTLSize(
                    width: (Int(uniforms.gridWidth) + 15) / 16,
                    height: (Int(uniforms.gridHeight) + 15) / 16,
                    depth: 1
                )
                computeEncoder.dispatchThreadgroups(numThreadGroups, threadsPerThreadgroup: threadsPerGroup)
                computeEncoder.endEncoding()
            }
        }
        
        // Render pass
        guard let descriptor = view.currentRenderPassDescriptor,
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
              let pipelineState = pipelineStates[currentScene.name] else {
            commandBuffer.commit()
            return
        }
        
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
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        } else if let lightingScene = currentScene as? PixelLightingScene {
            // Set uniforms for lighting scene
            var uniforms = lightingScene.uniforms
            encoder.setVertexBytes(&uniforms,
                                   length: MemoryLayout<PixelLightingUniforms>.stride,
                                   index: 1)
            encoder.setFragmentBytes(&uniforms,
                                     length: MemoryLayout<PixelLightingUniforms>.stride,
                                     index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        } else if let cellularScene = currentScene as? CellularSandScene {
            // Render cellular sand grid
            if let gridBuffer = cellularScene.getGridBuffer() {
                encoder.setVertexBuffer(gridBuffer, offset: 0, index: 0)
                
                var uniforms = cellularScene.uniforms as! CellularSandUniforms
                encoder.setVertexBytes(&uniforms,
                                       length: MemoryLayout<CellularSandUniforms>.stride,
                                       index: 1)
                
                // Draw instanced quads for grid cells
                let gridSize = Int(uniforms.gridWidth * uniforms.gridHeight)
                encoder.drawPrimitives(type: .triangle,
                                       vertexStart: 0,
                                       vertexCount: 6,
                                       instanceCount: gridSize)
            }
        }
        
        encoder.endEncoding()
        
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        
        commandBuffer.commit()
    }
    
    func updateMousePosition(_ position: CGPoint) {
        currentScene.handleTouch(position)
    }
    
    func handleMouseUp() {
        if let cellularScene = currentScene as? CellularSandScene {
            cellularScene.handleTouchEnd()
        }
    }
}
