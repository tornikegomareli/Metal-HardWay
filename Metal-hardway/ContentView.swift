//
//  ContentView.swift
//  Metal-hardway
//
//  Created by Tornike Gomareli on 07.01.25.
//

import SwiftUI

struct ContentView: View {
  @State private var currentScene: MetalScene = CellularSandScene()

  var body: some View {
    MetalViewRepresentable(scene: $currentScene)
      .ignoresSafeArea(.all)
  }
}
