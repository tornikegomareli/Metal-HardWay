//
//  MetalViewRepresentable.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 07.01.25.
//

import SwiftUI
import UIKit
import MetalKit

struct MetalViewRepresentable: UIViewRepresentable {
  @Binding var currentScene: MetalScene
  
  public func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  public func makeUIView(context: Context) -> MTKView {
    let mtkView = context.coordinator.mtkView
    
    if context.coordinator.renderer == nil {
      context.coordinator.renderer = UnifiedRenderer(metalView: mtkView, initialScene: currentScene)
      mtkView.contentScaleFactor = UIScreen.main.scale
      mtkView.autoResizeDrawable = true
    }
    
    mtkView.preferredFramesPerSecond = 60
    let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
    mtkView.addGestureRecognizer(panGesture)
    
    let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
    mtkView.addGestureRecognizer(tapGesture)
    
    mtkView.isUserInteractionEnabled = true
    
    return mtkView
  }
  
  public func updateUIView(_ uiView: MTKView, context: Context) {
    // Switch scene when binding changes
    if let renderer = context.coordinator.renderer {
      renderer.switchScene(to: currentScene)
    }
  }
  
  public class Coordinator: NSObject {
    let mtkView: MTKView
    var renderer: UnifiedRenderer?
    
    override init() {
      self.mtkView = MTKView()
      super.init()
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
      let location = gesture.location(in: gesture.view)
      renderer?.updateMousePosition(location)
      
      if gesture.state == .ended || gesture.state == .cancelled {
        renderer?.handleMouseUp()
      }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
      let location = gesture.location(in: gesture.view)
      renderer?.updateMousePosition(location)
    }
  }
}