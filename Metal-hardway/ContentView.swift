//
//  ContentView.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 07.01.25.
//

import SwiftUI

struct ContentView: View {
  @State private var currentScene: MetalScene = ParallaxScene()

  var body: some View {
    VStack {
      MetalViewRepresentable(scene: $currentScene)
    }.ignoresSafeArea(.all)
  }
}
