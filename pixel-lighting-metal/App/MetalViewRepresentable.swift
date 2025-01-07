//
//  MetalViewRepresentable.swift
//  pixel-lighting-metal
//
//  Created by Tornike Gomareli on 07.01.25.
//

import SwiftUI
import UIKit
import MetalKit

struct MetalViewRepresentable: UIViewRepresentable {
  let mtkView: MTKView
  var renderer: MetalRenderer?
  
  public init() {
    self.mtkView = MTKView()
    self.renderer = MetalRenderer(metalView: mtkView)
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public func makeUIView(context: Context) -> MTKView {
    mtkView.preferredFramesPerSecond = 60
    let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
    mtkView.addGestureRecognizer(panGesture)
    
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
    }
  }
}
