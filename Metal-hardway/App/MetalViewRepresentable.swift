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
  private let mtkView: MTKView
  private var renderer: UnifiedRenderer?
  
  init(scene: Binding<MetalScene>) {
    self._currentScene = scene
    self.mtkView = MTKView()
    self.renderer = UnifiedRenderer(metalView: mtkView, initialScene: scene.wrappedValue)
    
    mtkView.contentScaleFactor = UIScreen.main.scale
    mtkView.autoResizeDrawable = true
    
    ///TODO: Make possible to call it from outside, and not from here.
    self.renderer?.switchScene(to: currentScene)
  }
  
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public func makeUIView(context: Context) -> MTKView {
    mtkView.preferredFramesPerSecond = 60
    let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
    mtkView.addGestureRecognizer(panGesture)
    
    let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
    mtkView.addGestureRecognizer(tapGesture)
    
    mtkView.isUserInteractionEnabled = true
    
    return mtkView
  }
  
  public func updateUIView(_ uiView: MTKView, context: Context) {
    // Update view if needed
  }
  
  public class Coordinator: NSObject {
    var parent: MetalViewRepresentable
    
    init(_ parent: MetalViewRepresentable) {
      self.parent = parent
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
      let location = gesture.location(in: gesture.view)
      parent.renderer?.updateMousePosition(location)
      
      if gesture.state == .ended || gesture.state == .cancelled {
        parent.renderer?.handleMouseUp()
      }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
      let location = gesture.location(in: gesture.view)
      parent.renderer?.updateMousePosition(location)
    }
  }
}
