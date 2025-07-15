//
//  CellularSandScene.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 14.01.25.
//

import Metal
import MetalKit
import simd

struct CellType: OptionSet {
  let rawValue: UInt8
  
  static let empty = CellType(rawValue: 0)
  static let sand = CellType(rawValue: 1)
  static let wall = CellType(rawValue: 2)
}

struct Cell {
  var type: Float
  var color: SIMD4<Float>
}

struct CellularSandUniforms {
  var gridWidth: Int32
  var gridHeight: Int32
  var time: Float
  var mousePosition: SIMD2<Float>
  var isMouseDown: Float
  var brushSize: Float
  var frameCounter: Int32
}

class CellularSandScene: MetalScene {
  let name = "CellularSand"
  let vertexFunctionName = "cellularSandVertexShader"
  let fragmentFunctionName = "cellularSandFragmentShader"
  let computeFunctionName = "cellularSandCompute"
  let screenSize = (width: 200, height: 200)
  
  var uniforms: Any { return self.simulationUniforms }
  
  private let cellSize: Float = 2.0
  private let gridWidth = 100
  private let gridHeight = 100
  private var viewSize: CGSize = CGSize(width: 1, height: 1)
  
  private var gridBuffer: MTLBuffer?
  private var nextGridBuffer: MTLBuffer?
  private var computePipelineState: MTLComputePipelineState?
  private let device: MTLDevice
  
  private lazy var simulationUniforms: CellularSandUniforms = {
    return CellularSandUniforms(
      gridWidth: Int32(gridWidth),
      gridHeight: Int32(gridHeight),
      time: 0,
      mousePosition: SIMD2<Float>(0, 0),
      isMouseDown: 0,
      brushSize: 5,
      frameCounter: 0
    )
  }()
  
  private var isMouseDown = false
  
  init(device: MTLDevice = MTLCreateSystemDefaultDevice()!) {
    self.device = device
    setupComputePipeline()
    setupGridBuffers()
  }
  
  private func setupComputePipeline() {
    guard let library = device.makeDefaultLibrary(),
          let computeFunction = library.makeFunction(name: computeFunctionName) else {
      print("Failed to create compute function")
      return
    }
    
    do {
      computePipelineState = try device.makeComputePipelineState(function: computeFunction)
    } catch {
      print("Failed to create compute pipeline state: \(error)")
    }
  }
  
  private func setupGridBuffers() {
    let gridSize = gridWidth * gridHeight
    let bufferSize = MemoryLayout<Cell>.stride * gridSize
    
    gridBuffer = device.makeBuffer(length: bufferSize, options: .storageModeShared)
    nextGridBuffer = device.makeBuffer(length: bufferSize, options: .storageModeShared)
    
    if let buffer = gridBuffer {
      let pointer = buffer.contents().bindMemory(to: Cell.self, capacity: gridSize)
      for i in 0..<gridSize {
        pointer[i] = Cell(
          type: 0,
          color: SIMD4<Float>(0, 0, 0, 0)
        )
      }
    }
    
    if let current = gridBuffer, let next = nextGridBuffer {
      memcpy(next.contents(), current.contents(), bufferSize)
    }
  }
  
  func willExitScene() {
    setupGridBuffers()
  }
  
  func didEnterScene() {
  }
  
  func update() {
    simulationUniforms.time += 1.0/60.0
    simulationUniforms.frameCounter += 1
    
    let temp = gridBuffer
    gridBuffer = nextGridBuffer
    nextGridBuffer = temp
  }
  
  func handleTouch(_ position: CGPoint) {
    let x = Float(position.x)
    let y = Float(position.y)
    simulationUniforms.mousePosition = SIMD2<Float>(x, y)
    
    if !isMouseDown {
      isMouseDown = true
      simulationUniforms.isMouseDown = 1.0
    }
    
    spawnSuspendedSandAt(position: simulationUniforms.mousePosition)
  }
  
  func setViewSize(_ size: CGSize) {
    viewSize = size
  }
  
  func handleTouchEnd() {
    isMouseDown = false
    simulationUniforms.isMouseDown = 0.0
    
    convertSuspendedToFallingSand()
  }
  
  private func spawnSandAt(position: SIMD2<Float>) {
    guard let buffer = gridBuffer else { 
      print("No grid buffer available")
      return 
    }
    
    let gridX = Int(position.x / Float(viewSize.width) * Float(gridWidth))
    let gridY = Int(position.y / Float(viewSize.height) * Float(gridHeight))
    let brushSize = Int(simulationUniforms.brushSize)
    
    print("Spawning sand at grid position: \(gridX), \(gridY)")
    
    let pointer = buffer.contents().bindMemory(to: Cell.self, capacity: gridWidth * gridHeight)
    var spawnedCount = 0
    
    for dy in -brushSize...brushSize {
      for dx in -brushSize...brushSize {
        let dist = sqrt(Float(dx * dx + dy * dy))
        if dist <= Float(brushSize) {
          let x = gridX + dx
          let y = gridY + dy
          
          if x >= 0 && x < gridWidth && y >= 0 && y < gridHeight {
            let index = y * gridWidth + x
            
            if pointer[index].type == 0 {
              pointer[index] = Cell(
                type: 1,
                color: SIMD4<Float>(
                  Float.random(in: 0.85...0.95),
                  Float.random(in: 0.75...0.85),
                  Float.random(in: 0.45...0.55),
                  1.0
                )
              )
              spawnedCount += 1
            }
          }
        }
      }
    }
    
    print("Spawned \(spawnedCount) sand cells")
  }
  
  func getGridBuffer() -> MTLBuffer? {
    return gridBuffer
  }
  
  func getNextGridBuffer() -> MTLBuffer? {
    return nextGridBuffer
  }
  
  func getComputePipelineState() -> MTLComputePipelineState? {
    return computePipelineState
  }
  
  private func spawnSuspendedSandAt(position: SIMD2<Float>) {
    guard let buffer = gridBuffer else { return }
    
    let gridX = Int(position.x / Float(viewSize.width) * Float(gridWidth))
    let gridY = Int(position.y / Float(viewSize.height) * Float(gridHeight))
    let brushSize = Int(simulationUniforms.brushSize)
    
    let pointer = buffer.contents().bindMemory(to: Cell.self, capacity: gridWidth * gridHeight)
    
    for dy in -brushSize...brushSize {
      for dx in -brushSize...brushSize {
        let dist = sqrt(Float(dx * dx + dy * dy))
        if dist <= Float(brushSize) {
          let x = gridX + dx
          let y = gridY + dy
          
          if x >= 0 && x < gridWidth && y >= 0 && y < gridHeight {
            let index = y * gridWidth + x
            
            if pointer[index].type == 0 {
              pointer[index] = Cell(
                type: 3,
                color: SIMD4<Float>(
                  Float.random(in: 0.85...0.95),
                  Float.random(in: 0.75...0.85),
                  Float.random(in: 0.45...0.55),
                  1.0
                )
              )
            }
          }
        }
      }
    }
  }
  
  private func convertSuspendedToFallingSand() {
    guard let buffer = gridBuffer else { return }
    
    let pointer = buffer.contents().bindMemory(to: Cell.self, capacity: gridWidth * gridHeight)
    var convertedCount = 0
    
    for i in 0..<(gridWidth * gridHeight) {
      if pointer[i].type == 3 {
        pointer[i].type = 1
        convertedCount += 1
      }
    }
    
    print("Converted \(convertedCount) suspended sand particles to falling")
    
    if let nextBuffer = nextGridBuffer {
      memcpy(nextBuffer.contents(), buffer.contents(), MemoryLayout<Cell>.stride * gridWidth * gridHeight)
    }
  }
  
  func countSandParticles() -> (suspended: Int, falling: Int, total: Int) {
    guard let buffer = gridBuffer else { return (0, 0, 0) }
    
    let pointer = buffer.contents().bindMemory(to: Cell.self, capacity: gridWidth * gridHeight)
    var suspended = 0
    var falling = 0
    
    for i in 0..<(gridWidth * gridHeight) {
      if pointer[i].type == 3 {
        suspended += 1
      } else if pointer[i].type == 1 {
        falling += 1
      }
    }
    
    return (suspended, falling, suspended + falling)
  }
}